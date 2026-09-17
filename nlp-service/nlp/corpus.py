"""
语料加载：从业务库读取技能标签、需求卡片与图谱技能对。

【为什么语料要包含图谱关系对】
  单看标签文本，'Vue 前端开发' 与 'JS 动画与交互实现' 的字符重叠很少，
  SVD 未必能把它们拉近。但技能图谱里它们被人工标注为"互补"关系 ——
  把这层关系拼成训练样本（"Vue 前端开发 JS 动画与交互实现 互补"），
  就等于**把人工维护的领域知识注入统计模型**，让向量空间继承图谱的判断。

  这也是本项目"图谱 + NLP 双路"的具体结合点：
  向量负责泛化（没见过的新表述也能匹配），图谱负责精确（专家标注的确定关系）。

【依赖说明】
  用 pymysql 读库不可行（本环境装不了），因此通过 **Java 侧的 mysql 客户端**
  导出，或直接读取 JSON 导出文件。这里提供两条路径：
    1. `--from-json <文件>` 读导出文件（推荐，训练可离线复现）
    2. 默认先尝试环境变量指向的 JSON，再回退到内置的种子语料
  这样训练脚本在无数据库连接的环境下也能跑，且结果可复现。

作者：李泽宬
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path


# MySQL 客户端路径（用于从库导出语料）
MYSQL_CANDIDATES = [
    r"G:\DEV\mysql\bin\mysql.exe",
    "mysql",
]


def _find_mysql() -> str | None:
    for c in MYSQL_CANDIDATES:
        if c == "mysql" or Path(c).exists():
            return c
    return None


def _query_json(sql: str, db: str = "zhiyi_manyou") -> list[dict]:
    """用 mysql 客户端执行查询并解析 JSON 输出。

    通过 `JSON_ARRAYAGG(JSON_OBJECT(...))` 让 MySQL 直接产出 JSON，
    避免自己解析制表符分隔的文本（字段里可能含制表符与换行）。
    """
    exe = _find_mysql()
    if exe is None:
        raise RuntimeError("找不到 mysql 客户端")
    pwd = os.environ.get("ZHIYI_DB_PASSWORD")
    if not pwd:
        raise RuntimeError("未设置 ZHIYI_DB_PASSWORD")

    # --raw 必须加：否则 mysql 客户端会对输出再做一次转义，
    # 把 JSON 里的 \" 变成 \\"，导致 json.loads 报
    # `Expecting ',' delimiter`（实测：含双引号的需求标题会触发）
    cmd = [exe, "-uroot", f"-p{pwd}", "--default-character-set=utf8mb4",
           "--raw", "-N", "-B", db, "-e", sql]
    proc = subprocess.run(cmd, capture_output=True, text=True,
                          encoding="utf-8", errors="replace")
    out = (proc.stdout or "").strip()
    if not out or out == "NULL":
        return []

    rows: list[dict] = []
    for line in out.splitlines():
        line = line.strip()
        if not line or line == "NULL":
            continue
        try:
            obj = json.loads(line)
        except json.JSONDecodeError as e:
            # 单行坏数据不应让整次读取失败 —— 跳过并提示
            print(f"[语料] 跳过无法解析的一行（{e}）：{line[:120]}", file=sys.stderr)
            continue
        if isinstance(obj, dict):
            rows.append(obj)
    return rows


# ---------------------------------------------------------------------------
# 各段语料
# ---------------------------------------------------------------------------

# 逐行输出 JSON_OBJECT，每行一个对象。
#
# 【为什么不用 JSON_ARRAYAGG 包成一个数组】
#   MySQL 会把整个结果聚合成一个超长字符串返回，而 mysql 客户端在输出时
#   会二次处理转义 —— 当字段内容本身含双引号时（例如需求标题
#   `帮我把作品集页面做得"活"一点`），产出的就不是合法 JSON，
#   json.loads 直接报 `Expecting ',' delimiter`。
#   逐行输出则每个对象独立、转义可控，且不受 group_concat 长度上限影响。
SQL_SKILLS = """
SELECT JSON_OBJECT(
    'id', id, 'name', name, 'alias', alias,
    'categoryL1', category_l1, 'categoryL2', category_l2,
    'difficulty', difficulty, 'hotScore', hot_score,
    'description', description
) FROM zy_skill WHERE status = 1;
"""

SQL_DEMANDS = """
SELECT JSON_OBJECT(
    'id', id, 'demandNo', demand_no, 'title', title,
    'description', description, 'status', status
) FROM zy_demand WHERE deleted = 0;
"""

# 表 zy_skill_ontology 的列名是 src_skill_id / dst_skill_id（不是 from/to），
# 写错会直接报 Unknown column，被上层捕获后静默退化成"0 对图谱关系"。
SQL_PAIRS = """
SELECT JSON_OBJECT(
    'fromId', src_skill_id, 'toId', dst_skill_id, 'relation', relation_type
) FROM zy_skill_ontology;
"""


def _skill_text(s: dict) -> str:
    """把一条技能拼成训练文本。

    别名要拼进去 —— 它是"同义词库/跨域术语映射"的载体（FR-M2-07），
    例如 '数据爬取' 是 '数据爬取与清洗' 的别名，
    拼进语料后两者会被拉近，用户用哪种叫法都能匹配到。
    别名里的分隔符是 '|'，需要拆开重拼，否则会变成一个奇怪的 token。
    """
    parts = [s.get("name") or ""]
    alias = (s.get("alias") or "").replace("|", " ").replace(",", " ").replace("，", " ")
    if alias.strip():
        parts.append(alias)
    if s.get("categoryL1"):
        parts.append(s["categoryL1"])
    if s.get("categoryL2"):
        parts.append(s["categoryL2"])
    if s.get("description"):
        parts.append(s["description"])
    return " ".join(p for p in parts if p)


def _demand_text(d: dict) -> str:
    return " ".join(p for p in [d.get("title") or "", d.get("description") or ""] if p)


def load_corpus(from_json: str | None = None) -> dict:
    """加载语料。

    @param from_json 若给定，从该 JSON 文件读取（结构 {"skills":[],"demands":[],"pairs":[]}）
    @return {"skills":[...], "demands":[...], "pairs":[...]}
    """
    if from_json:
        data = json.loads(Path(from_json).read_text(encoding="utf-8"))
        return _normalize(data)

    env_json = os.environ.get("ZY_CORPUS_JSON")
    if env_json and Path(env_json).exists():
        return _normalize(json.loads(Path(env_json).read_text(encoding="utf-8")))

    # 尝试直连数据库
    try:
        raw_skills = _query_json(SQL_SKILLS)
        raw_demands = _query_json(SQL_DEMANDS)
        raw_pairs = _query_json(SQL_PAIRS)
        return _normalize({"skills": raw_skills, "demands": raw_demands, "pairs": raw_pairs})
    except Exception as e:  # noqa: BLE001
        print(f"[语料] 从数据库读取失败（{e}），改用导出文件或种子语料", file=sys.stderr)
        return _seed_corpus()


def _normalize(data: dict) -> dict:
    """统一成训练需要的结构，并拼好训练文本。"""
    skills = []
    by_id: dict[int, dict] = {}
    for s in data.get("skills") or []:
        if not s:
            continue
        s["text"] = _skill_text(s)
        skills.append(s)
        by_id[int(s["id"])] = s

    demands = []
    for d in data.get("demands") or []:
        if not d:
            continue
        d["text"] = _demand_text(d)
        if d["text"].strip():
            demands.append(d)

    # 图谱对：只保留结构（fromId/toId/relation），**不拼接成训练文本**。
    #
    # 【为什么不拼进语料 —— 实测结论，不是想当然】
    #   最初的做法是把两侧技能文本拼成一条样本（"A B 互补"）当作额外语料，
    #   期望 SVD 由此把 A、B 的向量拉近。实测结果相反：
    #   在 20 篇语料、16/32/64 三种维度下，相似度一致地**下降**
    #   （0.0545 → 0.0295）。
    #
    #   根因是 IDF 机制：拼接文档同时包含 A、B 的词，使这些词的文档频率升高、
    #   IDF 降低；归一化后共享特征的权重反而被压低，两者被推远。
    #   这是 IDF 的必然结果，调参无法解决。
    #
    #   因此改为**在检索阶段做显式关系加成**（见 VectorIndex.relation_boost）：
    #   关系不混进向量，而是作为一次可控、可解释、可关闭的加权。
    #   这样用户能看到"因为图谱标注二者互补所以提权"。
    pairs = []
    for p in data.get("pairs") or []:
        if not p:
            continue
        a = by_id.get(int(p["fromId"])) if p.get("fromId") else None
        b = by_id.get(int(p["toId"])) if p.get("toId") else None
        if not a or not b:
            continue
        # 同一对只保留一次（图谱可能有双向记录）
        key = tuple(sorted([int(p["fromId"]), int(p["toId"])]))
        pairs.append({
            "fromId": key[0], "toId": key[1],
            "relation": p.get("relation"),
            "fromName": a.get("name"), "toName": b.get("name"),
            "_key": key,
        })
    # 去重
    seen: set[tuple] = set()
    uniq_pairs = []
    for p in pairs:
        if p["_key"] in seen:
            continue
        seen.add(p["_key"])
        p.pop("_key", None)
        uniq_pairs.append(p)

    return {"skills": skills, "demands": demands, "pairs": uniq_pairs}


def _seed_corpus() -> dict:
    """内置种子语料（数据库不可用时的兜底，保证训练脚本总能跑出结果）。

    内容与 sql/01-schema.sql 的种子技能一致，另附跨学科场景的典型需求表述 ——
    后者很关键：没有"用户口语化描述"的语料，
    向量空间只学会"标签怎么写"，学不会"用户怎么说"。
    """
    skills = [
        {"id": 1, "name": "Vue 前端开发", "alias": "vue|vue3|vue.js|前端框架",
         "categoryL1": "工学", "categoryL2": "计算机科学与技术", "difficulty": 3,
         "description": "基于组件化的前端开发框架，用于构建交互式网页应用"},
        {"id": 2, "name": "JS 动画与交互实现", "alias": "js动画|前端动效|交互动效|response动画",
         "categoryL1": "工学", "categoryL2": "计算机科学与技术", "difficulty": 3,
         "description": "用 JavaScript 实现页面动效、滚动动画与交互反馈"},
        {"id": 3, "name": "UI/UX 设计", "alias": "界面设计|交互设计|ui设计|用户体验",
         "categoryL1": "艺术学", "categoryL2": "设计学", "difficulty": 3,
         "description": "界面视觉与用户体验设计，含原型与设计规范"},
        {"id": 4, "name": "ECharts 数据可视化", "alias": "echarts|图表|数据大屏|可视化图表",
         "categoryL1": "工学", "categoryL2": "计算机科学与技术", "difficulty": 2,
         "description": "用 ECharts 绘制折线柱状饼图与数据看板"},
        {"id": 5, "name": "数据爬取与清洗", "alias": "爬虫|数据爬取|数据采集|数据清洗",
         "categoryL1": "工学", "categoryL2": "计算机科学与技术", "difficulty": 3,
         "description": "抓取网页数据并做去重、缺失值处理等清洗工作"},
        {"id": 6, "name": "学术论文写作", "alias": "论文写作|论文|期刊投稿|文献综述",
         "categoryL1": "文学", "categoryL2": "中国语言文学", "difficulty": 3,
         "description": "学术论文结构组织、文献综述与规范表达"},
        {"id": 7, "name": "数学建模", "alias": "建模|数模|数学竞赛|美赛",
         "categoryL1": "理学", "categoryL2": "数学", "difficulty": 4,
         "description": "把实际问题抽象为数学模型并求解与验证"},
        {"id": 8, "name": "英语口语陪练", "alias": "口语|英语口语|speaking|英语对话",
         "categoryL1": "文学", "categoryL2": "外国语言文学", "difficulty": 2,
         "description": "日常与学术场景的英语口语对话练习"},
        {"id": 9, "name": "视频剪辑", "alias": "剪辑|后期|premiere|pr|视频后期",
         "categoryL1": "艺术学", "categoryL2": "戏剧与影视学", "difficulty": 3,
         "description": "视频素材剪辑、转场与调色等后期处理"},
        {"id": 10, "name": "科研实验设计", "alias": "实验设计|科研方法|实验方案",
         "categoryL1": "理学", "categoryL2": "生物学", "difficulty": 4,
         "description": "设计可复现的实验方案、对照组与统计分析方法"},
        {"id": 11, "name": "PPT 与汇报表达", "alias": "ppt|汇报|演示文稿|答辩",
         "categoryL1": "艺术学", "categoryL2": "设计学", "difficulty": 2,
         "description": "演示文稿设计与口头汇报表达技巧"},
        {"id": 12, "name": "算法与数据结构", "alias": "算法|数据结构|leetcode|刷题",
         "categoryL1": "工学", "categoryL2": "计算机科学与技术", "difficulty": 4,
         "description": "常见算法思想与数据结构实现，含复杂度分析"},
    ]
    demands = [
        {"id": 1, "title": "毕设需要做数据大屏，要有动态图表",
         "description": "希望有人教我 ECharts，能把实验数据做成看板"},
        {"id": 2, "title": "想学一点数学建模打比赛",
         "description": "零基础，希望能带我入门数模，我可以教前端"},
        {"id": 3, "title": "帮我剪个宣传视频加特效",
         "description": "社团招新视频，需要后期剪辑和转场动效"},
        {"id": 4, "title": "论文怎么写才规范",
         "description": "第一次投期刊，不知道怎么组织结构"},
        {"id": 5, "title": "需要有人帮我看看页面动效怎么做",
         "description": "Vue 项目里的滚动动画不流畅"},
        {"id": 6, "title": "实验数据不会处理",
         "description": "有一批实验数据，需要做统计分析和可视化"},
    ]
    # 图谱关系对（与 01-schema.sql 的种子边一致）
    pairs = [
        {"fromId": 1, "toId": 2, "relation": "COMPLEMENT"},
        {"fromId": 1, "toId": 12, "relation": "PREREQUISITE"},
        {"fromId": 4, "toId": 5, "relation": "COMPLEMENT"},
        {"fromId": 7, "toId": 10, "relation": "COMPLEMENT"},
        {"fromId": 6, "toId": 11, "relation": "COMPLEMENT"},
        {"fromId": 3, "toId": 9, "relation": "COMPLEMENT"},
        {"fromId": 4, "toId": 7, "relation": "COMPLEMENT"},
    ]
    return _normalize({"skills": skills, "demands": demands, "pairs": pairs})
