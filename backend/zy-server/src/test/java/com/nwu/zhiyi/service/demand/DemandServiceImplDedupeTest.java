package com.nwu.zhiyi.service.demand;

import com.nwu.zhiyi.api.dto.demand.DemandCreateRequest;
import com.nwu.zhiyi.api.dto.demand.MarketCardVO;
import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.Demand;
import com.nwu.zhiyi.domain.entity.Skill;
import com.nwu.zhiyi.domain.mapper.DemandInterestMapper;
import com.nwu.zhiyi.domain.mapper.DemandMapper;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.security.RequestRateLimiter;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.time.Duration;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@DisplayName("M4 - 需求发布并发去重")
class DemandServiceImplDedupeTest {

    private DemandMapper demandMapper;
    private DemandInterestMapper interestMapper;
    private SkillMapper skillMapper;
    private StudentMapper studentMapper;
    private DemandCardAssembler assembler;
    private DemandContentAuditor auditor;
    private RequestRateLimiter rateLimiter;
    private DemandServiceImpl service;

    @BeforeEach
    void setUp() {
        demandMapper = mock(DemandMapper.class);
        interestMapper = mock(DemandInterestMapper.class);
        skillMapper = mock(SkillMapper.class);
        studentMapper = mock(StudentMapper.class);
        assembler = mock(DemandCardAssembler.class);
        auditor = new DemandContentAuditor();
        rateLimiter = mock(RequestRateLimiter.class);
        service = new DemandServiceImpl(demandMapper, interestMapper, skillMapper, studentMapper,
                assembler, auditor, rateLimiter);
    }

    @Test
    @DisplayName("三秒防抖拒绝时不再查询技能或写数据库")
    void shouldStopBeforeDatabaseWhenGuardRejects() {
        when(rateLimiter.tryAcquire(anyString(), eq(1), eq(Duration.ofSeconds(3)))).thenReturn(false);

        BusinessException error = assertThrows(BusinessException.class,
                () -> service.create("2024117420", request()));

        assertEquals(ErrorCode.DEMAND_DUPLICATE_OPEN, error.getErrorCode());
        verifyNoInteractions(skillMapper, demandMapper, assembler);
    }

    @Test
    @DisplayName("数据库开放卡片唯一索引冲突转成业务错误")
    void shouldTranslateDuplicateKeyToBusinessError() {
        when(rateLimiter.tryAcquire(anyString(), eq(1), eq(Duration.ofSeconds(3)))).thenReturn(true);
        when(skillMapper.selectById(12L)).thenReturn(activeSkill(12L));
        when(skillMapper.selectById(8L)).thenReturn(activeSkill(8L));
        when(demandMapper.insert(any(Demand.class)))
                .thenThrow(new org.springframework.dao.DuplicateKeyException("duplicate open demand"));

        BusinessException error = assertThrows(BusinessException.class,
                () -> service.create("2024117420", request()));

        assertEquals(ErrorCode.DEMAND_DUPLICATE_OPEN, error.getErrorCode());
        verify(assembler, never()).assembleOne(any(), anyString(), eq(false));
    }

    @Test
    @DisplayName("成功创建时写入 64 位小写内容指纹")
    void shouldPersistCanonicalFingerprint() {
        when(rateLimiter.tryAcquire(anyString(), eq(1), eq(Duration.ofSeconds(3)))).thenReturn(true);
        when(skillMapper.selectById(12L)).thenReturn(activeSkill(12L));
        when(skillMapper.selectById(8L)).thenReturn(activeSkill(8L));
        MarketCardVO expected = new MarketCardVO();
        when(assembler.assembleOne(any(Demand.class), eq("2024117420"), eq(false))).thenReturn(expected);

        service.create("2024117420", request());

        ArgumentCaptor<Demand> captor = ArgumentCaptor.forClass(Demand.class);
        verify(demandMapper).insert(captor.capture());
        assertNotNull(captor.getValue().getDedupeHash());
        assertEquals(64, captor.getValue().getDedupeHash().length());
        assertEquals(captor.getValue().getDedupeHash(), captor.getValue().getDedupeHash().toLowerCase());
    }

    private static DemandCreateRequest request() {
        DemandCreateRequest request = new DemandCreateRequest();
        request.setTitle("求 Java 后端辅导");
        request.setDescription("准备项目重构");
        request.setExpectedSkillId(12L);
        request.setOfferSkillId(8L);
        request.setExpectedHours(8);
        request.setExpectedPeriod("周末");
        request.setVisibility("PUBLIC");
        return request;
    }

    private static Skill activeSkill(Long id) {
        return new Skill().setId(id).setName("技能-" + id).setStatus(1);
    }
}
