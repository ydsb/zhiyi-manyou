package com.nwu.zhiyi.service.exchange;

import com.nwu.zhiyi.common.api.ErrorCode;
import com.nwu.zhiyi.common.enums.DemandStatus;
import com.nwu.zhiyi.common.enums.ExchangeStatus;
import com.nwu.zhiyi.common.exception.BusinessException;
import com.nwu.zhiyi.domain.entity.Demand;
import com.nwu.zhiyi.domain.entity.ExchangeRecord;
import com.nwu.zhiyi.domain.mapper.DemandInterestMapper;
import com.nwu.zhiyi.domain.mapper.DemandMapper;
import com.nwu.zhiyi.domain.mapper.EvaluationGradeMapper;
import com.nwu.zhiyi.domain.mapper.ExchangeRecordMapper;
import com.nwu.zhiyi.domain.mapper.SkillMapper;
import com.nwu.zhiyi.domain.mapper.StudentMapper;
import com.nwu.zhiyi.service.collab.WorkspaceService;
import com.nwu.zhiyi.service.demand.DemandService;
import com.nwu.zhiyi.service.notify.NotificationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@DisplayName("M4 - 交换状态业务边界")
class ExchangeServiceImplStateTest {

    private ExchangeRecordMapper exchangeMapper;
    private DemandMapper demandMapper;
    private StudentMapper studentMapper;
    private EvaluationGradeMapper evaluationMapper;
    private ExchangeServiceImpl service;

    @BeforeEach
    void setUp() {
        exchangeMapper = mock(ExchangeRecordMapper.class);
        demandMapper = mock(DemandMapper.class);
        DemandInterestMapper interestMapper = mock(DemandInterestMapper.class);
        SkillMapper skillMapper = mock(SkillMapper.class);
        studentMapper = mock(StudentMapper.class);
        evaluationMapper = mock(EvaluationGradeMapper.class);
        DemandService demandService = mock(DemandService.class);
        WorkspaceService workspaceService = mock(WorkspaceService.class);
        NotificationService notificationService = mock(NotificationService.class);
        service = new ExchangeServiceImpl(exchangeMapper, demandMapper, interestMapper,
                skillMapper, studentMapper, evaluationMapper, demandService, workspaceService, notificationService);
    }

    @Test
    @DisplayName("通用状态接口不能绕过接受邀约直接把交换改为进行中")
    void shouldRejectInProgressBypass() {
        ExchangeRecord record = negotiatingRecord();
        when(exchangeMapper.selectById(1L)).thenReturn(record);

        BusinessException error = assertThrows(BusinessException.class,
                () -> service.changeStatus("giver", 1L, ExchangeStatus.IN_PROGRESS.name(), null));

        assertEquals(ErrorCode.EXCHANGE_STATUS_ILLEGAL, error.getErrorCode());
        verify(exchangeMapper, never()).updateById(any(ExchangeRecord.class));
    }

    @Test
    @DisplayName("互评完成时关闭来源需求并完成交换")
    void shouldCloseSourceDemandAfterEvaluation() {
        ExchangeRecord record = new ExchangeRecord()
                .setId(1L)
                .setRecordNo("ZY-TEST-1")
                .setGiverSno("giver")
                .setTakerSno("taker")
                .setSourceDemandId(10L)
                .setStatus(ExchangeStatus.PENDING_EVAL);
        Demand demand = new Demand().setId(10L).setStatus(DemandStatus.MATCHED);
        when(exchangeMapper.selectById(1L)).thenReturn(record);
        when(demandMapper.selectById(10L)).thenReturn(demand);
        when(evaluationMapper.countByRecord(1L)).thenReturn(2);
        when(studentMapper.selectBriefBySnos(anyCollection())).thenReturn(List.of());

        service.completeAfterEvaluation("giver", 1L);

        assertEquals(ExchangeStatus.COMPLETED, record.getStatus());
        ArgumentCaptor<Demand> captor = ArgumentCaptor.forClass(Demand.class);
        verify(demandMapper).updateById(captor.capture());
        assertEquals(DemandStatus.CLOSED, captor.getValue().getStatus());
    }

    private static ExchangeRecord negotiatingRecord() {
        return new ExchangeRecord()
                .setId(1L)
                .setRecordNo("ZY-TEST-1")
                .setGiverSno("giver")
                .setTakerSno("taker")
                .setStatus(ExchangeStatus.NEGOTIATING);
    }
}
