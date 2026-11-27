-- ============================================================================
-- Database: DB_INCAR_FCA
-- Target DBMS: Microsoft SQL Server 2022 (v16.x)
-- Description: FCA Incar DB Structure DDL Script
-- ============================================================================

USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'DB_INCAR_FCA')
BEGIN
    CREATE DATABASE [DB_INCAR_FCA];
END
GO

USE [DB_INCAR_FCA];
GO

-- ============================================================================
-- 1. 공통 테이블 (Common Code & Master)
-- ============================================================================

-- 그룹 공통코드
IF OBJECT_ID('dbo.TB_GROUP_COMM_CODE', 'U') IS NOT NULL DROP TABLE dbo.TB_GROUP_COMM_CODE;
GO
CREATE TABLE dbo.TB_GROUP_COMM_CODE (
    Group_CD            VARCHAR(10)     NOT NULL,   -- 그룹 공통코드
    Group_NM            VARCHAR(20)     NOT NULL,   -- 그룹 공통코드명
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_GROUP_COMM_CODE_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_GROUP_COMM_CODE_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_GROUP_COMM_CODE_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_GROUP_COMM_CODE PRIMARY KEY CLUSTERED (Group_CD)
);
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'그룹 공통코드', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TB_GROUP_COMM_CODE';
GO

-- 공통코드
IF OBJECT_ID('dbo.TB_COMM_CODE', 'U') IS NOT NULL DROP TABLE dbo.TB_COMM_CODE;
GO
CREATE TABLE dbo.TB_COMM_CODE (
    Group_CD            VARCHAR(10)     NOT NULL,   -- 그룹 공통코드
    Code                VARCHAR(10)     NOT NULL,   -- 공통코드
    Name                VARCHAR(20)     NOT NULL,   -- 공통명
    Disp_NO             INT             NOT NULL,   -- 화면표시 순서 (order by)
    Value1              VARCHAR(50)     NULL,       -- 예비값1
    Value2              VARCHAR(50)     NULL,       -- 예비값2
    Value3              VARCHAR(50)     NULL,       -- 예비값3    
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_COMM_CODE_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_COMM_CODE_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_COMM_CODE_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)    NULL,       -- 설명
    CONSTRAINT PK_TB_COMM_CODE PRIMARY KEY CLUSTERED (Group_CD, Code)
);
GO

-- 모델 마스터
IF OBJECT_ID('dbo.TB_MODEL', 'U') IS NOT NULL DROP TABLE dbo.TB_MODEL;
GO
CREATE TABLE dbo.TB_MODEL (
    Model_CD            VARCHAR(10)     NOT NULL,   -- 모델코드
    Model_NM            VARCHAR(30)     NOT NULL,   -- 모델명
    Model_Type          VARCHAR(10)     NULL,       -- 모델 종류
    Color_CD            VARCHAR(10)     NOT NULL,   -- 색상코드 (CLR001)
    Model_Revision      VARCHAR(10)     NOT NULL,   -- 모델 사양 개정번호 (REV001)
    Effective_From_DT   DATETIME2(0)    NOT NULL,   -- 적용 시작일
    Effective_To_DT     DATETIME2(0)    NULL,       -- 적용 종료일
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_MODEL_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_MODEL_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_MODEL_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_MODEL PRIMARY KEY CLUSTERED (Model_CD)
);
GO

-- 포장 사양
IF OBJECT_ID('dbo.TB_PACKING_SPEC', 'U') IS NOT NULL DROP TABLE dbo.TB_PACKING_SPEC;
GO
CREATE TABLE dbo.TB_PACKING_SPEC (
    Packing_Spec_ID     VARCHAR(10)     NOT NULL,   -- 포장규격 ID
    Model_CD            VARCHAR(10)     NOT NULL,   -- 모델코드
    Packing_Type_CD     VARCHAR(10)     NOT NULL,   -- 포장 유형 (PCK001)
    UOM_CD              VARCHAR(10)     NOT NULL,   -- 포장 단위 (PCK002)
    Packing_Unit_Qty    INT             NOT NULL,   -- 포장 단위당 수량
    Label_Template_ID   VARCHAR(10)     NULL,       -- 적용 라벨 양식 ID
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_PACKING_SPEC_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_PACKING_SPEC_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_PACKING_SPEC_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_PACKING_SPEC PRIMARY KEY CLUSTERED (Packing_Spec_ID)
);
GO

-- 라벨 템플릿
IF OBJECT_ID('dbo.TB_LABEL_TEMPLATE', 'U') IS NOT NULL DROP TABLE dbo.TB_LABEL_TEMPLATE;
GO
CREATE TABLE dbo.TB_LABEL_TEMPLATE (
    Lable_Template_ID   VARCHAR(20)     NOT NULL,   -- 라벨 양식 ID
    Model_CD            VARCHAR(20)     NOT NULL,   -- 모델코드
    Contents_Len        INT             NOT NULL,   -- 파일 길이
    Contents            VARBINARY(MAX)  NOT NULL,   -- 파일 내용
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_LABEL_TEMPLATE_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_LABEL_TEMPLATE_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_LABEL_TEMPLATE_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_LABEL_TEMPLATE PRIMARY KEY CLUSTERED (Lable_Template_ID)
);
GO

-- 공정 마스터
IF OBJECT_ID('dbo.TB_PROCESS', 'U') IS NOT NULL DROP TABLE dbo.TB_PROCESS;
GO
CREATE TABLE dbo.TB_PROCESS (
    Process_ID          VARCHAR(10)     NOT NULL,   -- 공정 ID
    Process_CD          VARCHAR(20)     NOT NULL,   -- 공정코드
    Process_Type_CD     VARCHAR(10)     NOT NULL,   -- 공정유형 (PRS001)
    Process_NM          VARCHAR(30)     NOT NULL,   -- 공정명
    Use_Table_NM        VARCHAR(50)     NOT NULL,   -- 사용 테이블명
    Sequence_NO         INT             NOT NULL,   -- 공정 순서
    Inspection_YN       CHAR(1)         NOT NULL,   -- 검사/판정 공정 여부 (Y, N)
    STD_Cycle_Time      INT             NOT NULL,   -- 표준 사이클타임(초)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_PROCESS_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_PROCESS_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_PROCESS_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_PROCESS PRIMARY KEY CLUSTERED (Process_ID),
    CONSTRAINT UQ_TB_PROCESS_Process_CD UNIQUE (Process_CD)
);
GO

-- 공정 라우팅 마스터
IF OBJECT_ID('dbo.TB_PROCESS_ROUTE', 'U') IS NOT NULL DROP TABLE dbo.TB_PROCESS_ROUTE;
GO
CREATE TABLE dbo.TB_PROCESS_ROUTE (
    Route_ID            VARCHAR(20)     NOT NULL,   -- 라우팅 ID
    Route_NM            VARCHAR(20)     NOT NULL,   -- 표준 생산공정명
    Model_CD            VARCHAR(20)     NOT NULL,   -- 적용 모델
    Revision_CD         VARCHAR(10)     NOT NULL,   -- 개정버전 코드  (PRS002)
    Effective_From_DT   DATETIME2(0)    NOT NULL,   -- 적용 시작일
    Effective_To_DT     DATETIME2(0)    NULL,       -- 적용 종료일
    Status_CD           VARCHAR(10)     NOT NULL,   -- 라우팅 상태
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_PROCESS_ROUTE_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_PROCESS_ROUTE_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_PROCESS_ROUTE_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_PROCESS_ROUTE PRIMARY KEY CLUSTERED (Route_ID)
);
GO

-- 공정 라우팅 상세
IF OBJECT_ID('dbo.TB_PROCESS_ROUTE_DETAIL', 'U') IS NOT NULL DROP TABLE dbo.TB_PROCESS_ROUTE_DETAIL;
GO
CREATE TABLE dbo.TB_PROCESS_ROUTE_DETAIL (
    RouteD_ID           VARCHAR(20)     NOT NULL,   -- 라우팅 상세 ID
    Route_ID            VARCHAR(20)     NOT NULL,   -- 라우팅 ID
    Process_CD          VARCHAR(10)     NOT NULL,   -- 공정코드
    Process_NM          VARCHAR(30)     NOT NULL,   -- 공정명
    Sequence_NO         INT             NOT NULL,   -- 공정 순서
    Required_YN         CHAR(1)         NOT NULL,   -- 필수 수행 여부 (Y, N)
    Inspection_YN       CHAR(1)         NOT NULL,   -- 검사/판정 공정 여부 (Y, N)
    PreProcess_CD       VARCHAR(10)     NULL,       -- 직전 필수 공정코드
    Line_NO             VARCHAR(10)     NOT NULL,   -- 사용 라인
    STD_Cycle_Time      INT             NOT NULL,   -- 표준 사이클타임(초)
    Rework_Allowed_YN   CHAR(1)         NOT NULL,   -- 재작업 허용 여부 (Y, N)
    Rework_Process_CD   VARCHAR(10)     NULL,       -- 재작업 시 복귀 공정코드
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_PRCESS_ROUTED_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_PRCESS_ROUTED_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_PRCESS_ROUTED_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_PRCESS_ROUTE_DETAIL PRIMARY KEY CLUSTERED (RouteD_ID, Line_NO)
);
GO

-- 설비 마스터
IF OBJECT_ID('dbo.TB_EQUIPMENT', 'U') IS NOT NULL DROP TABLE dbo.TB_EQUIPMENT;
GO
CREATE TABLE dbo.TB_EQUIPMENT (
    Equipment_ID        VARCHAR(20)     NOT NULL,   -- 설비 ID
    Equipment_CD        VARCHAR(20)     NOT NULL,   -- 설비코드
    Equipment_NM        VARCHAR(20)     NOT NULL,   -- 설비명
    Equipment_Type_CD   VARCHAR(10)     NOT NULL,   -- 설비종류
    Line_ID             VARCHAR(10)     NOT NULL,   -- LINE ID
    Station_NO          INT             NULL,       -- JIG 번호
    Serial_NO           VARCHAR(20)     NULL,       -- 설비 제조번호
    Maker_NM            VARCHAR(30)     NULL,       -- 제조사
    Model_NM            VARCHAR(30)     NULL,       -- 설비 모델명
    Purchase_DT         DATETIME2(0)    NULL,       -- 도입일자
    Status_CD           VARCHAR(50)     NOT NULL,   -- 설비 상태
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_EQUIPMENT_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_EQUIPMENT_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_EQUIPMENT_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_EQUIPMENT PRIMARY KEY CLUSTERED (Equipment_ID),
    CONSTRAINT UQ_TB_EQUIPMENT_Equipment_CD UNIQUE (Equipment_CD)
);
GO

-- 라인 마스터
IF OBJECT_ID('dbo.TB_LINE', 'U') IS NOT NULL DROP TABLE dbo.TB_LINE;
GO
CREATE TABLE dbo.TB_LINE (
    Line_ID             VARCHAR(10)     NOT NULL,   -- 라인 ID
    Line_NO             INT             NOT NULL,   -- LINE 번호
    Line_NM             VARCHAR(20)     NOT NULL,   -- LINE 명
    Plant_CD            VARCHAR(10)     NULL,       -- 공장/사업장 코드
    Line_Type           VARCHAR(10)     NOT NULL,   -- LINE 종류
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_LINE_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_LINE_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_LINE_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_LINE PRIMARY KEY CLUSTERED (Line_ID),
    CONSTRAINT UQ_TB_LINE_Line_NO UNIQUE (Line_NO)
);
GO

-- 작업자 마스터
IF OBJECT_ID('dbo.TB_WORKER', 'U') IS NOT NULL DROP TABLE dbo.TB_WORKER;
GO
CREATE TABLE dbo.TB_WORKER (
    User_ID             VARCHAR(10)     NOT NULL,   -- 작업자 ID
    User_PWD            VARCHAR(20)     NOT NULL CONSTRAINT DF_TB_WORKER_User_PWD DEFAULT '111111',   -- 패스워드
    Dept_CD             VARCHAR(30)     NULL,       -- 부서코드
    Position_CD         VARCHAR(30)     NULL,       -- 직급코드 (PMS001)
    Permission_CD       VARCHAR(10)     NOT NULL,   -- 권한코드 (PMT001)
    User_NM             VARCHAR(30)     NOT NULL,   -- 작업자명
    Last_Login_DT       VARCHAR(20)     NULL,       -- 마지막 접속일
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_WORKER_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_WORKER_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_WORKER_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_WORKER PRIMARY KEY CLUSTERED (User_ID)
);
INSERT INTO dbo.TB_WORKER　(User_ID, User_NM, Position_CD, Permission_CD) VALUES ('admin', 'admin', 'SMGR', 'SYSTEM')
GO

-- 로그인 정보
IF OBJECT_ID('dbo.TB_LOGIN_HISTORY', 'U') IS NOT NULL DROP TABLE dbo.TB_LOGIN_HISTORY;
GO
CREATE TABLE dbo.TB_LOGIN_HISTORY (
    Seq_NO              BIGINT IDENTITY(1,1) NOT NULL,  -- 로그인 식별 순번
    Login_ID            VARCHAR(20)          NOT NULL,  -- Login ID
    Client_IP           VARCHAR(45)          NULL,      -- 접속 IP
    QR_YN               CHAR(1)              NOT NULL CONSTRAINT DF_TB_TB_LOGIN_HISTORY_QR_YN DEFAULT 'N',   -- QR 로그인 여부 (Y, N)
    Created_By          VARCHAR(10)          NOT NULL CONSTRAINT DF_TB_TB_LOGIN_HISTORY_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)         NOT NULL CONSTRAINT DF_TB_TB_LOGIN_HISTORY_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Description         VARCHAR(50)          NULL,      -- 설명
    CONSTRAINT PK_TB_TB_LOGIN_HISTORY PRIMARY KEY CLUSTERED (Seq_NO)
);
GO

-- 로그인시 TB_WORKER.Last_Login_DT 자동 업데이트 트리거
IF OBJECT_ID('dbo.TRG_TB_WORKER_LOGIN_AFTER_INSERT', 'TR') IS NOT NULL DROP TRIGGER dbo.TRG_TB_WORKER_LOGIN_AFTER_INSERT;
GO
CREATE OR ALTER TRIGGER dbo.TRG_TB_WORKER_LOGIN_AFTER_INSERT
ON dbo.TB_LOGIN_HISTORY
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    WITH LatestLogins AS (
        SELECT Login_ID, MAX(Created_DT) AS MaxCreatedDT
        FROM inserted
        GROUP BY Login_ID
    )
    UPDATE W
    SET W.Last_Login_DT = L.MaxCreatedDT
    FROM dbo.TB_WORKER W
    INNER JOIN LatestLogins L ON W.User_ID = L.Login_ID
    WHERE (W.Last_Login_DT IS NULL OR W.Last_Login_DT < L.MaxCreatedDT);
END
GO

-- 작업 숙련도
IF OBJECT_ID('dbo.TB_WORK_SKILL', 'U') IS NOT NULL DROP TABLE dbo.TB_WORK_SKILL;
GO
CREATE TABLE dbo.TB_WORK_SKILL (
    Work_Skill_ID       VARCHAR(10)     NOT NULL,   -- 작업자 자격 ID
    User_ID             VARCHAR(10)     NOT NULL,   -- 작업자 ID
    Process_ID          VARCHAR(30)     NOT NULL,   -- 공정 ID
    Skill_Level_CD      VARCHAR(10)     NOT NULL,   -- 숙련도
    Certified_DT        DATETIME2(0)    NOT NULL,   -- 자격 취득일
    Expired_DT          DATETIME2(0)    NULL,       -- 자격 만료일
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_WORK_SKILL_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_WORK_SKILL_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_WORK_SKILL_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 교육/인증번호
    CONSTRAINT PK_TB_WORK_SKILL PRIMARY KEY CLUSTERED (Work_Skill_ID)
);
GO

-- 검사 항목
IF OBJECT_ID('dbo.TB_INSPECTION_ITEM', 'U') IS NOT NULL DROP TABLE dbo.TB_INSPECTION_ITEM;
GO
CREATE TABLE dbo.TB_INSPECTION_ITEM (
    Inspection_Item_ID  VARCHAR(10)     NOT NULL,   -- 검사 항목 ID
    Inspection_Item_CD  VARCHAR(10)     NOT NULL,   -- 검사 항목코드
    Inspection_Item_NM  VARCHAR(20)     NOT NULL,   -- 검사 항목명
    Attribute_NM        VARCHAR(20)     NOT NULL,   -- 속성명 (컬럼명)
    Data_Type_CD        VARCHAR(10)     NOT NULL,   -- 데이터 타입 (TYP001)
    UOM_CD              VARCHAR(10)     NOT NULL,   -- 단위코드 (UOM###)
    Decimal_Place       INT             NULL,       -- 소수점 자리수
    Mothed              VARCHAR(20)     NULL,       -- 측정방식/장비
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_INSPECTION_ITEM_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_INSPECTION_ITEM_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_INSPECTION_ITEM_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 교육/인증번호
    CONSTRAINT PK_TB_INSPECTION_ITEM PRIMARY KEY CLUSTERED (Inspection_Item_ID),
    CONSTRAINT UQ_TB_INSPECTION_ITEM_CD UNIQUE (Inspection_Item_CD)
);
GO

-- 검사 규격
IF OBJECT_ID('dbo.TB_INSPECTION_SPEC', 'U') IS NOT NULL DROP TABLE dbo.TB_INSPECTION_SPEC;
GO
CREATE TABLE dbo.TB_INSPECTION_SPEC (
    Inspection_Spec_ID  VARCHAR(10)     NOT NULL,   -- 검사 규격 ID
    Inspection_Item_ID  VARCHAR(10)     NOT NULL,   -- 검사 항목 ID
    Model_CD            VARCHAR(20)     NOT NULL,   -- 적용 모델
    Process_ID          VARCHAR(20)     NOT NULL,   -- 적용 공정
    Revision_NO         VARCHAR(10)     NOT NULL,   -- 개정번호 (REV003)
    Lower_Limit         VARCHAR(10)     NULL,       -- 하한값 (범위)
    Upper_Limit         VARCHAR(10)     NULL,       -- 상한값 (범위)
    Target_Value        VARCHAR(10)     NULL,       -- 목표값 (일치)
    Judgment_CD         VARCHAR(10)     NOT NULL,   -- 판정코드 (JDG001) - 외관판정인 경우 상하한값과 목표값 필요없음
    Effective_From_DT   DATETIME2(0)    NOT NULL,   -- 적용 시작일
    Effective_To_DT     DATETIME2(0)    NULL,       -- 적용 종료일
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_INSPECTION_SPEC_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_INSPECTION_SPEC_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_INSPECTION_SPEC_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 교육/인증번호
    CONSTRAINT PK_TB_INSPECTION_SPEC PRIMARY KEY CLUSTERED (Inspection_Spec_ID)
);
GO

-- 공정-설비 매핑
IF OBJECT_ID('dbo.TB_PROCESS_EQUIPMENT', 'U') IS NOT NULL DROP TABLE dbo.TB_PROCESS_EQUIPMENT;
GO
CREATE TABLE dbo.TB_PROCESS_EQUIPMENT (
    Process_Equipment_ID VARCHAR(20)    NOT NULL,   -- 공정-설비 매핑 ID
    Process_ID          VARCHAR(20)     NOT NULL,   -- 수행 공정
    Equipment_ID        VARCHAR(20)     NOT NULL,   -- 수행 가능 설비
    Model_CD            VARCHAR(20)     NULL,       -- 모델코드
    Priority_NO         INT             NOT NULL,   -- 설비 우선순위
    STD_Cycle_Time      INT             NULL,       -- 표준 사이클타임(초)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_PROCESS_EQUIPMENT_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_PROCESS_EQUIPMENT_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_PROCESS_EQUIPMENT_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 매핑 설명
    CONSTRAINT PK_TB_PROCESS_EQUIPMENT PRIMARY KEY CLUSTERED (Process_Equipment_ID)
);
GO

-- 불량 코드
IF OBJECT_ID('dbo.TB_DEFECT_CODE', 'U') IS NOT NULL DROP TABLE dbo.TB_DEFECT_CODE;
GO
CREATE TABLE dbo.TB_DEFECT_CODE (
    Defect_CD           VARCHAR(10)     NOT NULL,   -- 불량코드
    Defect_NM           VARCHAR(20)     NOT NULL,   -- 불량명
    Defect_Type_CD      VARCHAR(20)     NOT NULL,   -- 불량 종류 (DFT001)
    Process_ID          VARCHAR(10)     NOT NULL,   -- 주 발생 공정 ID
    Severity_CD         VARCHAR(10)     NOT NULL,   -- 심각도 코드 (SEV001)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_DEFECT_CODE_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_DEFECT_CODE_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_DEFECT_CODE_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_DEFECT_CODE PRIMARY KEY CLUSTERED (Defect_CD)
);
GO

-- 재작업 기준
IF OBJECT_ID('dbo.TB_REWORK_RULE', 'U') IS NOT NULL DROP TABLE dbo.TB_REWORK_RULE;
GO
CREATE TABLE dbo.TB_REWORK_RULE (
    Rework_Rule_ID      VARCHAR(10)     NOT NULL,   -- 재작업 기준 ID
    Model_CD            VARCHAR(20)     NOT NULL,   -- 적용 모델
    Defect_CD           VARCHAR(20)     NOT NULL,   -- 불량코드
    Process_ID          VARCHAR(10)     NOT NULL,   -- 불량 발생 공정코드
    Rework_Allowed_YN   CHAR(1)         NOT NULL,   -- 재작업 가능 여부 (Y, N)
    Rework_Process_ID   VARCHAR(10)     NULL,       -- 재작업 수행 공정
    Max_Rework_Count    INT             NOT NULL,   -- 최대 재작업 횟수
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_REWORK_RULE_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_REWORK_RULE_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_REWORK_RULE_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_REWORK_RULE PRIMARY KEY CLUSTERED (Rework_Rule_ID)
);
GO

-- 부적합 (NCR)
IF OBJECT_ID('dbo.TB_NONCONFORMANCE', 'U') IS NOT NULL DROP TABLE dbo.TB_NONCONFORMANCE;
GO
CREATE TABLE dbo.TB_NONCONFORMANCE (
    NCR_ID              VARCHAR(10)     NOT NULL,   -- 불량품 ID
    Product_ID          VARCHAR(20)     NOT NULL,   -- 생산품 ID
    Inspection_ID       VARCHAR(20)     NOT NULL,   -- 검사 ID
    Defect_CD           VARCHAR(10)     NOT NULL,   -- 불량코드
    Disposition_CD      VARCHAR(10)     NOT NULL,   -- 조치코드
    Status_CD           VARCHAR(10)     NOT NULL,   -- 불량품 상태
    Max_Rework_Count    INT             NOT NULL,   -- 최대 재작업 횟수
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_NONCONFORMANCE_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_NONCONFORMANCE_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_NONCONFORMANCE_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_NONCONFORMANCE PRIMARY KEY CLUSTERED (NCR_ID)
);
GO

-- 작업지시 마스터
IF OBJECT_ID('dbo.TB_WORK_ORDER', 'U') IS NOT NULL DROP TABLE dbo.TB_WORK_ORDER;
GO
CREATE TABLE dbo.TB_WORK_ORDER (
    WO_NO               VARCHAR(20)     NOT NULL,   -- 작업지시 번호
    Model_CD            VARCHAR(20)     NOT NULL,   -- 모델 번호
    Source_Type_CD      VARCHAR(10)     NOT NULL,   -- 등록 유형 (REG001)
    Ext_Order_NO        VARCHAR(20)     NOT NULL,   -- 외부 주문번호
    Plan_QTY            INT             NOT NULL,   -- 생산 계획 수량
    Start_Plan_DT       DATETIME2(0)    NOT NULL,   -- 계획 시작일
    End_Plan_DT         DATETIME2(0)    NOT NULL,   -- 계획 종료일
    Approve_DT          DATETIME2(0)    NULL,       -- 승인일 (확정/취소)
    Release_DT          DATETIME2(0)    NULL,       -- 생산 완료일
    Status_CD           VARCHAR(10)     NOT NULL,   -- 생산 상태 (STA001)
    Good_QTY            INT             NULL,       -- 정상품 수량
    Defect_QTY          INT             NULL,       -- 불량품 수량
    Completion_QTY      INT             NULL,       -- 총 생산 수량
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_WORK_ORDER_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_WORK_ORDER_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_WORK_ORDER_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_WORK_ORDER PRIMARY KEY CLUSTERED (WO_NO)
);
GO

-- LOT 마스터
IF OBJECT_ID('dbo.TB_LOT_MASTER', 'U') IS NOT NULL DROP TABLE dbo.TB_LOT_MASTER;
GO
CREATE TABLE dbo.TB_LOT_MASTER (
    Lot_NO              VARCHAR(20)     NOT NULL,   -- LOT 번호
    WO_NO               VARCHAR(20)     NOT NULL,   -- 작업지시 번호
    Plan_QTY            INT             NOT NULL,   -- 계획 수량
    Start_DT            DATETIME2(0)    NOT NULL,   -- 생산 시작일
    End_DT              DATETIME2(0)    NOT NULL,   -- 생산 종료일
    Good_QTY            INT             NULL,       -- 정상품 수량
    Defect_QTY          INT             NULL,       -- 불량품 수량
    Completion_QTY      INT             NULL,       -- 총 생산 수량
    Status_CD           VARCHAR(10)     NOT NULL,   -- 생산 상태 (STA003)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_LOT_MASTER_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_LOT_MASTER_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_LOT_MASTER_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_LOT_MASTER PRIMARY KEY CLUSTERED (Lot_NO)
);
GO

-- 작업지시 공정 매핑
IF OBJECT_ID('dbo.TB_WORK_ORDER_PROCESS', 'U') IS NOT NULL DROP TABLE dbo.TB_WORK_ORDER_PROCESS;
GO
CREATE TABLE dbo.TB_WORK_ORDER_PROCESS (
    WO_Process_ID       VARCHAR(10)     NOT NULL,   -- 작업 공정 ID
    WO_NO               VARCHAR(20)     NOT NULL,   -- 작업지시 번호
    Process_ID          VARCHAR(20)     NOT NULL,   -- 공정 ID
    Plan_QTY            INT             NOT NULL,   -- 계획 수량
    Start_Plan_DT       DATETIME2(0)    NOT NULL,   -- 계획 시작일
    End_Plan_DT         DATETIME2(0)    NOT NULL,   -- 계획 종료일
    Good_QTY            INT             NULL,       -- 정상품 수량
    Defect_QTY          INT             NULL,       -- 불량품 수량
    Completion_QTY      INT             NULL,       -- 총 생산 수량
    Status_CD           VARCHAR(10)     NOT NULL,   -- 생산 상태 (STA003)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_WORK_ORDER_PROCESS_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_WORK_ORDER_PROCESS_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_WORK_ORDER_PROCESS_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_WORK_ORDER_PROCESS PRIMARY KEY CLUSTERED (WO_Process_ID)
);
GO

-- 비가동 계획
IF OBJECT_ID('dbo.TB_DOWNTIME_PLAN', 'U') IS NOT NULL DROP TABLE dbo.TB_DOWNTIME_PLAN;
GO
CREATE TABLE dbo.TB_DOWNTIME_PLAN (
    Downtime_Plan_ID    VARCHAR(10)     NOT NULL,   -- 비가동 계획 ID
    Equipment_ID        VARCHAR(10)     NOT NULL,   -- 설비 ID
    Downtime_Type_CD    VARCHAR(10)     NOT NULL,   -- 비가동 유형 (DTT001)
    Period_Type_CD      VARCHAR(10)     NOT NULL,   -- 주기 유형 (DTT002)
    Start_Plan_DT       DATETIME2(0)    NOT NULL,   -- 계획 시작일
    End_Plan_DT         DATETIME2(0)    NOT NULL,   -- 계획 종료일
    Auto_Generater_YN   CHAR(1)         NOT NULL,   -- 자동생성 여부 (Y, N)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_DOWNTIME_PLAN_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_DOWNTIME_PLAN_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_DOWNTIME_PLAN_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_DOWNTIME_PLAN PRIMARY KEY CLUSTERED (Downtime_Plan_ID)
);
GO

-- 비가동 이력
IF OBJECT_ID('dbo.TB_DOWNTIME', 'U') IS NOT NULL DROP TABLE dbo.TB_DOWNTIME;
GO
CREATE TABLE dbo.TB_DOWNTIME (
    Downtime_ID         VARCHAR(10)     NOT NULL,   -- 비가동 ID
    WO_NO               VARCHAR(20)     NOT NULL,   -- 작업지시 번호
    Equipment_ID        VARCHAR(10)     NOT NULL,   -- 설비 ID
    Lot_NO              VARCHAR(20)     NOT NULL,   -- LOT 번호
    Downtime_Plan_YN    CHAR(1)         NOT NULL,   -- 비가동 계획 여부 (Y, N)
    Downtime_Type_CD    VARCHAR(10)     NOT NULL,   -- 비가동 유형 (DTT001)
    Period_Type_CD      VARCHAR(10)     NOT NULL,   -- 주기 유형 (DTT002)
    Start_Plan_DT       DATETIME2(0)    NOT NULL,   -- 계획 시작일
    End_Plan_DT         DATETIME2(0)    NOT NULL,   -- 계획 종료일
    Downtime_Min        INT             NOT NULL,   -- 비가동 시간(분)
    Is_Auto_Generated   CHAR(1)         NOT NULL,   -- 자동생성 여부
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_DOWNTIME_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_DOWNTIME_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_DOWNTIME_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_DOWNTIME PRIMARY KEY CLUSTERED (Downtime_ID)
);
GO

-- 설비 유지보수 이력
IF OBJECT_ID('dbo.TB_MAINTENANCE_HISTORY', 'U') IS NOT NULL DROP TABLE dbo.TB_MAINTENANCE_HISTORY;
GO
CREATE TABLE dbo.TB_MAINTENANCE_HISTORY (
    Maintenace_ID       VARCHAR(10)     NOT NULL,   -- 유지보수 ID
    Equipment_ID        VARCHAR(10)     NOT NULL,   -- 설비 ID
    Downtime_ID         VARCHAR(10)     NOT NULL,   -- 비가동 ID
    Maintenace_Type_CD  VARCHAR(10)     NOT NULL,   -- 유지보수 종류
    Symptom             VARCHAR(50)     NOT NULL,   -- 증상
    Cause               VARCHAR(100)    NOT NULL,   -- 원인
    Action              VARCHAR(100)    NOT NULL,   -- 조치
    Start_DT            DATETIME2(0)    NOT NULL,   -- 시작일시
    End_DT              DATETIME2(0)    NOT NULL,   -- 종료일시
    Maintenance_Min     INT             NOT NULL,   -- 유지보수 시간(분)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_MAINTENANCE_HISTORY_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_MAINTENANCE_HISTORY_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_MAINTENANCE_HISTORY_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_MAINTENANCE_HISTORY PRIMARY KEY CLUSTERED (Maintenace_ID)
);
GO

-- 품목 마스터
IF OBJECT_ID('dbo.TB_ITEM', 'U') IS NOT NULL DROP TABLE dbo.TB_ITEM;
GO
CREATE TABLE dbo.TB_ITEM (
    Item_ID             VARCHAR(10)     NOT NULL,   -- 품목 ID
    Item_CD             VARCHAR(10)     NOT NULL,   -- 품목코드
    Item_NM             VARCHAR(20)     NOT NULL,   -- 품목명
    Item_Type_CD        VARCHAR(10)     NOT NULL,   -- 품목 유형 (ITM001)
    Model_CD            VARCHAR(10)     NOT NULL,   -- 모델코드
    Base_UOM_CD         VARCHAR(10)     NOT NULL,   -- 기본 재고 단위
    Lot_Managed_YN      CHAR(1)         NOT NULL,   -- LOT 관리 여부 (Y, N)
    SN_Managed_YN       CHAR(1)         NOT NULL,   -- SN 관리 여부 (Y, N)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_ITEM_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_ITEM_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_ITEM_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_ITEM PRIMARY KEY CLUSTERED (Item_ID),
    CONSTRAINT UQ_TB_ITEM_Item_CD UNIQUE (Item_CD)
);
GO

-- 창고 마스터
IF OBJECT_ID('dbo.TB_WAREHOUSE', 'U') IS NOT NULL DROP TABLE dbo.TB_WAREHOUSE;
GO
CREATE TABLE dbo.TB_WAREHOUSE (
    Warehouse_ID        VARCHAR(10)     NOT NULL,   -- 창고 ID
    Warehouse_CD        VARCHAR(10)     NOT NULL,   -- 창고코드
    Warehouse_NM        VARCHAR(20)     NOT NULL,   -- 창고명
    Warehouse_Type_CD   VARCHAR(10)     NOT NULL,   -- 창고 유형 (WHT001)
    Stock_Count_YN      CHAR(1)         NOT NULL,   -- 실사여부 (Y, N)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_WAREHOUSE_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_WAREHOUSE_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_WAREHOUSE_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_WAREHOUSE PRIMARY KEY CLUSTERED (Warehouse_ID)
);
GO

-- 재고 수불 수불/이동
IF OBJECT_ID('dbo.TB_STOCK_TRANSACTION', 'U') IS NOT NULL DROP TABLE dbo.TB_STOCK_TRANSACTION;
GO
CREATE TABLE dbo.TB_STOCK_TRANSACTION (
    Stock_Trans_ID      VARCHAR(10)     NOT NULL,   -- 재고이동 ID
    Stock_Tran_NO       VARCHAR(10)     NOT NULL,   -- 재고이동 번호
    Trans_Type_CD       VARCHAR(10)     NOT NULL,   -- 이동 유형 (STO001)
    Trans_Status_CD     VARCHAR(10)     NOT NULL,   -- 이동 상태 (STA002)
    Trans_DT            DATETIME2(0)    NOT NULL,   -- 이동 일자
    Item_CD             VARCHAR(10)     NOT NULL,   -- 품목코드
    WO_NO               VARCHAR(20)     NOT NULL,   -- 작업지시 번호
    Lot_NO              VARCHAR(20)     NOT NULL,   -- LOT 번호
    Prodcut_ID          VARCHAR(20)     NOT NULL,   -- 제품 ID
    From_Warehouse_ID   VARCHAR(10)     NOT NULL,   -- 원 창고
    To_Warehouse_ID     VARCHAR(10)     NOT NULL,   -- 대상 창고
    QTY                 INT             NOT NULL,   -- 수량
    UOM_CD              VARCHAR(10)     NOT NULL,   -- 수량 단위 (PCK00#)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_STOCK_TRANSACTION_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_STOCK_TRANSACTION_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_STOCK_TRANSACTION_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_STOCK_TRANSACTION PRIMARY KEY CLUSTERED (Stock_Trans_ID),
    CONSTRAINT UQ_TB_STOCK_TRANSACTION_Stock_Tran_NO UNIQUE (Stock_Tran_NO)
);
GO

-- 재고 예약
IF OBJECT_ID('dbo.TB_STOCK_RESERVATION', 'U') IS NOT NULL DROP TABLE dbo.TB_STOCK_RESERVATION;
GO
CREATE TABLE dbo.TB_STOCK_RESERVATION (
    Reservation_ID          VARCHAR(10)     NOT NULL,   -- 예약 ID
    Shipment_NO             VARCHAR(10)     NOT NULL,   -- 출하 ID
    Lot_NO                  VARCHAR(20)     NOT NULL,   -- LOT 번호
    Product_ID              VARCHAR(10)     NOT NULL,   -- 상품 ID
    Item_CD                 VARCHAR(10)     NOT NULL,   -- 품목코드
    Reservation_Status_CD   VARCHAR(10)     NOT NULL,   -- 예약 상태
    Reserved_QTY            INT             NOT NULL,   -- 예약 수량
    UOM_CD                  VARCHAR(10)     NOT NULL,   -- 수량 단위 (PCK00#)
    Warehouse_ID            VARCHAR(10)     NOT NULL,   -- 창고 ID
    Reserved_DT             DATETIME2(0)    NOT NULL,   -- 예약 일자
    Released_DT             DATETIME2(0)    NULL,       -- 해제/완료 일자
    Use_YN                  CHAR(1)         NOT NULL CONSTRAINT DF_TB_STOCK_RESERVATION_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By              VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_STOCK_RESERVATION_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT              DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_STOCK_RESERVATION_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By             VARCHAR(10)     NULL,       -- 수정인
    Modified_DT             DATETIME2(0)    NULL,       -- 수정일자
    Description             VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_STOCK_RESERVATION PRIMARY KEY CLUSTERED (Reservation_ID)
);
GO

-- 현재고 원장
IF OBJECT_ID('dbo.TB_STOCK_BALANCE', 'U') IS NOT NULL DROP TABLE dbo.TB_STOCK_BALANCE;
GO
CREATE TABLE dbo.TB_STOCK_BALANCE (
    Stock_Balance_ID    VARCHAR(10)     NOT NULL,   -- 현재고 ID
    Item_ID             VARCHAR(10)     NOT NULL,   -- 품목 ID
    Lot_NO              VARCHAR(20)     NOT NULL,   -- LOT 번호
    Warehouse_ID        VARCHAR(10)     NOT NULL,   -- 창고 ID
    Onhand_QTY          INT             NOT NULL,   -- 실 보유 수량
    Available_QTY       INT             NOT NULL,   -- 가용재고 수량
    Reserverd_QTY       INT             NOT NULL,   -- 예약 수량
    UOM_CD              VARCHAR(10)     NOT NULL,   -- 수량 단위 (PCK00#)
    Updated_DT          DATETIME2(0)    NOT NULL,   -- 업데이트 일자
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_STOCK_BALANCE_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_STOCK_BALANCE_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_STOCK_BALANCE_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_STOCK_BALANCE PRIMARY KEY CLUSTERED (Stock_Balance_ID)
);
GO

-- 완제품/재공품 재고
IF OBJECT_ID('dbo.TB_PRODUCT_INVENTORY', 'U') IS NOT NULL DROP TABLE dbo.TB_PRODUCT_INVENTORY;
GO
CREATE TABLE dbo.TB_PRODUCT_INVENTORY (
    Product_ID          VARCHAR(20)     NOT NULL,   -- 생산품 ID (WIP_ID)
    Item_ID             VARCHAR(10)     NOT NULL,   -- 품목 ID
    Lot_NO              VARCHAR(20)     NOT NULL,   -- LOT 번호
    Warehouse_ID        VARCHAR(10)     NOT NULL,   -- 창고 ID
    Stock_Status_CD     VARCHAR(10)     NOT NULL,   -- 현재 재고 상태
    UOM_CD              VARCHAR(10)     NOT NULL,   -- 수량 단위
    Reserverd_QTY       INT             NOT NULL,   -- 예약 수량
    Packing_UOM_CD      VARCHAR(10)     NOT NULL,   -- 포장 단위 (PCK00#)
    Updated_DT          DATETIME2(0)    NOT NULL,   -- 업데이트 일자
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_PRODUCT_INVENTORY_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_PRODUCT_INVENTORY_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_PRODUCT_INVENTORY_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_PRODUCT_INVENTORY PRIMARY KEY CLUSTERED (Product_ID, Warehouse_ID)
);
GO

-- 재고 실사 마스터
IF OBJECT_ID('dbo.TB_STCOK_COUNT', 'U') IS NOT NULL DROP TABLE dbo.TB_STCOK_COUNT;
GO
CREATE TABLE dbo.TB_STCOK_COUNT (
    Stock_Count_ID      VARCHAR(20)     NOT NULL,   -- 실사 ID
    Stock_Count_NO      VARCHAR(30)     NOT NULL,   -- 실사 번호
    Warehouse_ID        VARCHAR(10)     NOT NULL,   -- 창고 ID
    Count_Type_CD       VARCHAR(30)     NOT NULL,   -- 실사 유형
    Count_Status_CD     VARCHAR(30)     NOT NULL,   -- 실사 상태
    Start_Count_DT      DATETIME2(0)    NOT NULL,   -- 실사 시작일
    End_Count_DT        DATETIME2(0)    NOT NULL,   -- 실사 완료일
    Approved_By         VARCHAR(10)     NULL,       -- 확정 승인자
    Approved_DT         DATETIME2(0)    NULL,       -- 확정일
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_STCOK_COUNT_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_STCOK_COUNT_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_STCOK_COUNT_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_STCOK_COUNT PRIMARY KEY CLUSTERED (Stock_Count_ID),
    CONSTRAINT UQ_TB_STCOK_COUNT_NO UNIQUE (Stock_Count_NO)
);
GO

-- 재고 실사 상세
IF OBJECT_ID('dbo.TB_STCOK_COUNT_DETAIL', 'U') IS NOT NULL DROP TABLE dbo.TB_STCOK_COUNT_DETAIL;
GO
CREATE TABLE dbo.TB_STCOK_COUNT_DETAIL (
    Stock_CountD_ID     VARCHAR(20)     NOT NULL,   -- 실사 상세 ID
    Stock_Count_ID      VARCHAR(20)     NOT NULL,   -- 실사 ID
    Item_ID             VARCHAR(20)     NOT NULL,   -- 품목 ID
    Warehouse_ID        VARCHAR(10)     NOT NULL,   -- 창고 ID
    Stock_Status_CD     VARCHAR(10)     NOT NULL,   -- 현재 재고 상태 (STA004)
    System_QTY          INT             NOT NULL,   -- 시스템 재고 수량
    Countd_QTY          INT             NOT NULL,   -- 실사 확인 수량
    Differnce_QTY       INT             NOT NULL,   -- 차이 수량
    Adjust_Stock_Trans_ID VARCHAR(20)   NOT NULL,   -- 조정 재고 원장 ID
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_STCOK_COUNTD_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_STCOK_COUNTD_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_STCOK_COUNTD_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명
    CONSTRAINT PK_TB_STCOK_COUNT_DETAIL PRIMARY KEY CLUSTERED (Stock_CountD_ID)
);
GO


-- ============================================================================
-- 2. 공정 관련 테이블
-- ============================================================================

-- 제품 마스터 (재공/WIP 상태)
IF OBJECT_ID('dbo.TB_PRODUCT_MASTER', 'U') IS NOT NULL DROP TABLE dbo.TB_PRODUCT_MASTER;
GO
CREATE TABLE dbo.TB_PRODUCT_MASTER (
    Inspection_ID       VARCHAR(20)     NOT NULL,   -- 공정 검사 ID
    Product_ID          VARCHAR(20)     NOT NULL,   -- 생산품 ID (WIP_ID)
    WO_NO               VARCHAR(20)     NOT NULL,   -- 작업지시 번호
    Lot_NO              VARCHAR(20)     NOT NULL,   -- LOT 번호
    Stator_Barcode      VARCHAR(30)     NULL,       -- Stator Barcode
    PCB_Barcode         VARCHAR(30)     NULL,       -- PCB Barcode
    Product_Label       VARCHAR(30)     NULL,       -- Product Label
    Housing_SN          VARCHAR(30)     NULL,       -- Housing Serial NO
    Impeller_SN         VARCHAR(30)     NULL,       -- Impeller Serial NO
    Process_ID          VARCHAR(30)     NOT NULL,   -- 진행중 공정 ID
    Process_State       VARCHAR(5)      NOT NULL,   -- 진행중 공정 상태
    Result_CD           VARCHAR(5)      NULL,       -- 결과코드
    Error_CD            VARCHAR(5)      NULL,       -- 에러코드
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_PRODUCT_MASTER_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_PRODUCT_MASTER_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_PRODUCT_MASTER_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    Description         VARCHAR(50)     NULL,       -- 설명    
    CONSTRAINT PK_TB_PRODUCT_MASTER PRIMARY KEY CLUSTERED (Product_ID, Inspection_ID)
);
GO

-- 공정 실행 실적 (X)
--IF OBJECT_ID('dbo.TB_PROCESS_EXECUTION', 'U') IS NOT NULL DROP TABLE dbo.TB_PROCESS_EXECUTION;
--GO
--CREATE TABLE dbo.TB_PROCESS_EXECUTION (
--    Execution_ID        VARCHAR(20)     NOT NULL,   -- 실적 ID
--    Prev_Execution_ID   VARCHAR(20)     NOT NULL,   -- 이전 실적 ID
--    Product_ID          VARCHAR(20)     NOT NULL,   -- 생산품 ID
--    WO_NO               VARCHAR(20)     NOT NULL,   -- 작업지시 번호
--    Lot_NO              VARCHAR(20)     NOT NULL,   -- LOT 번호
--    Start_DT            DATETIME2(0)    NOT NULL,   -- 생산 시작시간
--    End_DT              DATETIME2(0)    NULL,       -- 생산 완료시간
--    Result_CD           VARCHAR(5)      NULL,       -- 결과코드
--    Error_CD            VARCHAR(5)      NULL,       -- 에러코드
--    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_PROCESS_EXECUTION_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
--    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_PROCESS_EXECUTION_Created_By DEFAULT 'SYSTEM',   -- 생성인
--    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_PROCESS_EXECUTION_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
--    Modified_By         VARCHAR(10)     NULL,       -- 수정인
--    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
--    Description         VARCHAR(50)     NULL,       -- 설명    
--    CONSTRAINT PK_TB_PROCESS_EXECUTION PRIMARY KEY CLUSTERED (Execution_ID)
--);
--GO

-- 검사 결과 테이블 (X)
--IF OBJECT_ID('dbo.TB_INSPECTION_RESULT', 'U') IS NOT NULL DROP TABLE dbo.TB_INSPECTION_RESULT;
--GO
--CREATE TABLE dbo.TB_INSPECTION_RESULT (
--    Seq_NO              BIGINT IDENTITY(1,1) NOT NULL,  -- 검사 결과 순번
--    Inspection_ID       VARCHAR(20)     NOT NULL,   -- 공정 검사 ID
--    Execution_ID        VARCHAR(20)     NOT NULL,   -- 실적 ID
--    Product_ID          VARCHAR(20)     NOT NULL,   -- 생산품 ID
--    WO_NO               VARCHAR(20)     NOT NULL,   -- 작업지시 번호
--    Lot_NO              VARCHAR(20)     NOT NULL,   -- LOT 번호
--    Process_ID          VARCHAR(20)     NOT NULL,   -- 공정 ID
--    Equipment_ID        VARCHAR(10)     NOT NULL,   -- 설비 ID
--    Worker_ID           VARCHAR(10)     NOT NULL,   -- 작업자 ID
--    Values              VARCHAR(MAX)    NOT NULL,   -- 결과값 - 구분자';' (value1;value2;value3;...)
--    Start_DT            DATETIME2(0)    NOT NULL,   -- 검사 시작시간
--    End_DT              DATETIME2(0)    NULL,       -- 검사 종료시간
--    PCheck              VARCHAR(5)      NULL,       -- 이전공정 결과
--    Result_CD           VARCHAR(5)      NULL,       -- 결과코드
--    Error_CD            VARCHAR(5)      NULL,       -- 에러코드
--    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_INSPECTION_RESULT_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
--    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_INSPECTION_RESULT_Created_By DEFAULT 'SYSTEM',   -- 생성인
--    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_INSPECTION_RESULT_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
--    Modified_By         VARCHAR(10)     NULL,       -- 수정인
--    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
--    Description         VARCHAR(50)     NULL,       -- 설명 
--    CONSTRAINT PK_TB_INSPECTION_RESULT PRIMARY KEY CLUSTERED (Inspection_ID)
--);
--GO

-- 검사 이력을 남겨야 하는 구조인데, 아래 테이블을 사용할 경우 마지막 검사 이력만 남게됨.
-- INSPECTION_RESULT 가 쌓이는 구조로 변경해야함.
-- 1. 저항 검사 (TB_RESISTANCE_TEST)
IF OBJECT_ID('dbo.TB_RESISTANCE_TEST', 'U') IS NOT NULL DROP TABLE dbo.TB_RESISTANCE_TEST;
GO
CREATE TABLE dbo.TB_RESISTANCE_TEST (
    Inspection_ID       VARCHAR(20)     NOT NULL,   -- 공정 검사 ID
    Product_ID          VARCHAR(20)     NOT NULL,   -- 상품 ID
    Process_ID          VARCHAR(30)     NOT NULL,   -- 공정 ID
    Resistance          VARCHAR(10)     NOT NULL,   -- 저항값 (Ω)
    NCount              VARCHAR(10)     NOT NULL,   -- INSPECTION_RESULT 에서 Inspection_ID or Product_ID 의 count 로 업데이트
    Start_DT            VARCHAR(10)     NOT NULL,   -- 검사 시작시간
    End_DT              VARCHAR(10)     NULL,       -- 검사 종료시간
    PCheck              VARCHAR(5)      NULL,       -- 이전 공정결과
    Result_CD           VARCHAR(5)      NULL,       -- 결과코드 (RET001)
    Error_CD            VARCHAR(5)      NULL,       -- 에러코드 (DEF####)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_RESISTANCE_TEST_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_RESISTANCE_TEST_Created_By DEFAULT 'SYSTEM',   -- 생성인(작업자)
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_RESISTANCE_TEST_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자    
    CONSTRAINT PK_TB_RESISTANCE_TEST PRIMARY KEY CLUSTERED (Inspection_ID)
);
GO

-- 2. 오일 주입 (TB_OIL_INJECTION)
IF OBJECT_ID('dbo.TB_OIL_INJECTION', 'U') IS NOT NULL DROP TABLE dbo.TB_OIL_INJECTION;
GO
CREATE TABLE dbo.TB_OIL_INJECTION (
    Inspection_ID       VARCHAR(20)     NOT NULL,   -- 공정 검사 ID
    Product_ID          VARCHAR(20)     NOT NULL,   -- 상품 ID
    Process_ID          VARCHAR(30)     NOT NULL,   -- 공정 ID
    Oil_Weight          VARCHAR(10)     NOT NULL,   -- 주입 오일 무게 (㎎)
    Bearing_Hight       VARCHAR(10)     NOT NULL,   -- 베어링 높이 (㎜)
    Oil_Cap_Hight       VARCHAR(10)     NOT NULL,   -- 오일캡 높이 (㎜)
    NCount              VARCHAR(10)     NOT NULL,   -- INSPECTION_RESULT 에서 Inspection_ID or Product_ID 의 count 로 업데이트
    Start_DT            VARCHAR(10)     NOT NULL,   -- 검사 시작시간
    End_DT              VARCHAR(10)     NULL,       -- 검사 종료시간
    PCheck              VARCHAR(5)      NULL,       -- 이전 공정결과
    Result_CD           VARCHAR(5)      NULL,       -- 결과코드 (RET001)
    Error_CD            VARCHAR(5)      NULL,       -- 에러코드 (DEF####)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_OIL_INJECTION_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_OIL_INJECTION_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_OIL_INJECTION_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    
    CONSTRAINT PK_TB_OIL_INJECTION PRIMARY KEY CLUSTERED (Inspection_ID)
);
GO

-- 3. 열 융착 (TB_THERMAL_STICKING)
IF OBJECT_ID('dbo.TB_THERMAL_STICKING', 'U') IS NOT NULL DROP TABLE dbo.TB_THERMAL_STICKING;
GO
CREATE TABLE dbo.TB_THERMAL_STICKING (
    Inspection_ID       VARCHAR(20)     NOT NULL,   -- 공정 검사 ID
    Product_ID          VARCHAR(20)     NOT NULL,   -- 상품 ID
    Process_ID          VARCHAR(30)     NOT NULL,   -- 공정 ID
    PCB_Barcode         VARCHAR(30)     NOT NULL,   -- PCB Barcode
    Welding_Time        VARCHAR(10)     NOT NULL,   -- 접합 시간 (초)
    Welding_TEMP        VARCHAR(10)     NOT NULL,   -- 접합 온도 (℃)
    NCount              VARCHAR(10)     NOT NULL,   -- INSPECTION_RESULT 에서 Inspection_ID or Product_ID 의 count 로 업데이트
    Start_DT            VARCHAR(10)     NOT NULL,   -- 검사 시작시간
    End_DT              VARCHAR(10)     NULL,       -- 검사 종료시간
    PCheck              VARCHAR(5)      NULL,       -- 이전 공정결과
    Result_CD           VARCHAR(5)      NULL,       -- 결과코드 (RET001)
    Error_CD            VARCHAR(5)      NULL,       -- 에러코드 (DEF####)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_THERMAL_STICKING_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_THERMAL_STICKING_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_THERMAL_STICKING_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    
    CONSTRAINT PK_TB_THERMAL_STICKING PRIMARY KEY CLUSTERED (Inspection_ID)
);
GO

-- 4. 코일 납땜 (TB_COIL_SOLDERING)
IF OBJECT_ID('dbo.TB_COIL_SOLDERING', 'U') IS NOT NULL DROP TABLE dbo.TB_COIL_SOLDERING;
GO
CREATE TABLE dbo.TB_COIL_SOLDERING (
    Inspection_ID       VARCHAR(20)     NOT NULL,   -- 공정 검사 ID
    Product_ID          VARCHAR(20)     NOT NULL,   -- 상품 ID
    Process_ID          VARCHAR(30)     NOT NULL,   -- 공정 ID
    Soldering           VARCHAR(10)     NOT NULL,   -- 납땜 정상 여부 (OK, NG)
    NCount              VARCHAR(10)     NOT NULL,   -- INSPECTION_RESULT 에서 Inspection_ID or Product_ID 의 count 로 업데이트
    Start_DT            VARCHAR(10)     NOT NULL,   -- 검사 시작시간
    End_DT              VARCHAR(10)     NULL,       -- 검사 종료시간
    PCheck              VARCHAR(5)      NULL,       -- 이전 공정결과
    Result_CD           VARCHAR(5)      NULL,       -- 결과코드 (RET001)
    Error_CD            VARCHAR(5)      NULL,       -- 에러코드 (DEF####)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_COIL_SOLDERING_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_COIL_SOLDERING_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_COIL_SOLDERING_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    
    CONSTRAINT PK_TB_COIL_SOLDERING PRIMARY KEY CLUSTERED (Inspection_ID)
);
GO

-- 5. 납땜 AOI (TB_SOLDER_AOI)
IF OBJECT_ID('dbo.TB_SOLDER_AOI', 'U') IS NOT NULL DROP TABLE dbo.TB_SOLDER_AOI;
GO
CREATE TABLE dbo.TB_SOLDER_AOI (
    Inspection_ID       VARCHAR(20)     NOT NULL,   -- 공정 검사 ID
    Product_ID          VARCHAR(20)     NOT NULL,   -- 상품 ID
    Process_ID          VARCHAR(30)     NOT NULL,   -- 공정 ID
    Housing_SN          VARCHAR(30)     NOT NULL,   -- Housing Serial NO
    Soldering           VARCHAR(10)     NOT NULL,   -- 납땜 정상 여부 (OK, NG)
    NCount              VARCHAR(10)     NOT NULL,   -- INSPECTION_RESULT 에서 Inspection_ID or Product_ID 의 count 로 업데이트
    Start_DT            VARCHAR(10)     NOT NULL,   -- 검사 시작시간
    End_DT              VARCHAR(10)     NULL,       -- 검사 종료시간
    PCheck              VARCHAR(5)      NULL,       -- 이전 공정결과
    Result_CD           VARCHAR(5)      NULL,       -- 결과코드 (RET001)
    Error_CD            VARCHAR(5)      NULL,       -- 에러코드 (DEF####)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_SOLDER_AOI_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_SOLDER_AOI_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_SOLDER_AOI_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    
    CONSTRAINT PK_TB_SOLDER_AOI PRIMARY KEY CLUSTERED (Inspection_ID)
);
GO

-- 6. 몰드 납땜 (TB_MOLD_SOLDERING)
IF OBJECT_ID('dbo.TB_MOLD_SOLDERING', 'U') IS NOT NULL DROP TABLE dbo.TB_MOLD_SOLDERING;
GO
CREATE TABLE dbo.TB_MOLD_SOLDERING (
    Inspection_ID       VARCHAR(20)     NOT NULL,   -- 공정 검사 ID
    Product_ID          VARCHAR(20)     NOT NULL,   -- 상품 ID
    Process_ID          VARCHAR(30)     NOT NULL,   -- 공정 ID
    PCB_Barcode         VARCHAR(30)     NOT NULL,   -- PCB Barcode
    Soldering           VARCHAR(10)     NOT NULL,   -- 납땜 정상 여부 (OK, NG)
    NCount              VARCHAR(10)     NOT NULL,   -- INSPECTION_RESULT 에서 Inspection_ID or Product_ID 의 count 로 업데이트
    Start_DT            VARCHAR(10)     NOT NULL,   -- 검사 시작시간
    End_DT              VARCHAR(10)     NULL,       -- 검사 종료시간
    PCheck              VARCHAR(5)      NULL,       -- 이전 공정결과
    Result_CD           VARCHAR(5)      NULL,       -- 결과코드 (RET001)
    Error_CD            VARCHAR(5)      NULL,       -- 에러코드 (DEF####)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_MOLD_SOLDERING_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_MOLD_SOLDERING_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_MOLD_SOLDERING_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    
    CONSTRAINT PK_TB_MOLD_SOLDERING PRIMARY KEY CLUSTERED (Inspection_ID)
);
GO

-- 7. 밸런싱 (TB_BALANCING)
IF OBJECT_ID('dbo.TB_BALANCING', 'U') IS NOT NULL DROP TABLE dbo.TB_BALANCING;
GO
CREATE TABLE dbo.TB_BALANCING (
    Inspection_ID       VARCHAR(20)     NOT NULL,   -- 공정 검사 ID
    Product_ID          VARCHAR(20)     NOT NULL,   -- 상품 ID
    Process_ID          VARCHAR(30)     NOT NULL,   -- 공정 ID
    Impeller_SN         VARCHAR(30)     NOT NULL,   -- Impeller Serial NO
    Balance_Amount      VARCHAR(10)     NOT NULL,   -- 밸런싱 값
    NCount              VARCHAR(10)     NOT NULL,   -- INSPECTION_RESULT 에서 Inspection_ID or Product_ID 의 count 로 업데이트
    Start_DT            VARCHAR(10)     NOT NULL,   -- 검사 시작시간
    End_DT              VARCHAR(10)     NULL,       -- 검사 종료시간
    PCheck              VARCHAR(5)      NULL,       -- 이전 공정결과
    Result_CD           VARCHAR(5)      NULL,       -- 결과코드 (RET001)
    Error_CD            VARCHAR(5)      NULL,       -- 에러코드 (DEF####)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_BALANCING_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_BALANCING_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_BALANCING_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    
    CONSTRAINT PK_TB_BALANCING PRIMARY KEY CLUSTERED (Inspection_ID)
);
GO

-- 8. EOL 검사 (TB_EOL_TEST)
IF OBJECT_ID('dbo.TB_EOL_TEST', 'U') IS NOT NULL DROP TABLE dbo.TB_EOL_TEST;
GO
CREATE TABLE dbo.TB_EOL_TEST (
    Inspection_ID       VARCHAR(20)     NOT NULL,   -- 공정 검사 ID
    Product_ID          VARCHAR(20)     NOT NULL,   -- 상품 ID
    Process_ID          VARCHAR(30)     NOT NULL,   -- 공정 ID
    Voltage             VARCHAR(10)     NOT NULL,   -- 전압 (㎷)
    ICurrent            VARCHAR(10)     NOT NULL,   -- 전류 (㎷)
    RPM                 VARCHAR(10)     NOT NULL,   -- 회전수 (RPM)
    Thermistor_R        VARCHAR(10)     NOT NULL,   -- 저항값 (Ω)
    NCount              VARCHAR(10)     NOT NULL,   -- INSPECTION_RESULT 에서 Inspection_ID or Product_ID 의 count 로 업데이트
    Start_DT            VARCHAR(10)     NOT NULL,   -- 검사 시작시간
    End_DT              VARCHAR(10)     NULL,       -- 검사 종료시간
    PCheck              VARCHAR(5)      NULL,       -- 이전 공정결과
    Result_CD           VARCHAR(5)      NULL,       -- 결과코드 (RET001)
    Error_CD            VARCHAR(5)      NULL,       -- 에러코드 (DEF####)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_EOL_TEST_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_EOL_TEST_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_EOL_TEST_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    
    CONSTRAINT PK_TB_EOL_TEST PRIMARY KEY CLUSTERED (Inspection_ID)
);
GO

-- 9. NVH 검사 (TB_NVH_TEST)
IF OBJECT_ID('dbo.TB_NVH_TEST', 'U') IS NOT NULL DROP TABLE dbo.TB_NVH_TEST;
GO
CREATE TABLE dbo.TB_NVH_TEST (
    Inspection_ID       VARCHAR(20)     NOT NULL,   -- 공정 검사 ID
    Product_ID          VARCHAR(20)     NOT NULL,   -- 상품 ID
    Process_ID          VARCHAR(30)     NOT NULL,   -- 공정 ID
    NCount              VARCHAR(10)     NOT NULL,   -- INSPECTION_RESULT 에서 Inspection_ID or Product_ID 의 count 로 업데이트
    Start_DT            VARCHAR(10)     NOT NULL,   -- 검사 시작시간
    End_DT              VARCHAR(10)     NULL,       -- 검사 종료시간
    PCheck              VARCHAR(5)      NULL,       -- 이전 공정결과
    Result_CD           VARCHAR(5)      NULL,       -- 결과코드 (RET001)
    Error_CD            VARCHAR(5)      NULL,       -- 에러코드 (DEF####)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_NVH_TEST_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_NVH_TEST_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_NVH_TEST_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    
    CONSTRAINT PK_TB_NVH_TEST PRIMARY KEY CLUSTERED (Inspection_ID)
);
GO

-- 10. 핀 휘어짐 검사 (TB_PIN_BENT_TEST)
IF OBJECT_ID('dbo.TB_PIN_BENT_TEST', 'U') IS NOT NULL DROP TABLE dbo.TB_PIN_BENT_TEST;
GO
CREATE TABLE dbo.TB_PIN_BENT_TEST (
    Inspection_ID       VARCHAR(20)     NOT NULL,   -- 공정 검사 ID
    Product_ID          VARCHAR(20)     NOT NULL,   -- 상품 ID
    Process_ID          VARCHAR(30)     NOT NULL,   -- 공정 ID
    NCount              VARCHAR(10)     NOT NULL,   -- INSPECTION_RESULT 에서 Inspection_ID or Product_ID 의 count 로 업데이트
    Start_DT            VARCHAR(10)     NOT NULL,   -- 검사 시작시간
    End_DT              VARCHAR(10)     NULL,       -- 검사 종료시간
    PCheck              VARCHAR(5)      NULL,       -- 이전 공정결과
    Result_CD           VARCHAR(5)      NULL,       -- 결과코드 (RET001)
    Error_CD            VARCHAR(5)      NULL,       -- 에러코드 (DEF####)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_PIN_BENT_TEST_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_PIN_BENT_TEST_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_PIN_BENT_TEST_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    
    CONSTRAINT PK_TB_PIN_BENT_TEST PRIMARY KEY CLUSTERED (Inspection_ID)
);
GO

-- 11. 포장 (TB_PACKING)
IF OBJECT_ID('dbo.TB_PACKING', 'U') IS NOT NULL DROP TABLE dbo.TB_PACKING;
GO
CREATE TABLE dbo.TB_PACKING (
    Inspection_ID       VARCHAR(20)     NOT NULL,   -- 공정 검사 ID
    Product_ID          VARCHAR(20)     NOT NULL,   -- 상품 ID
    Process_ID          VARCHAR(30)     NOT NULL,   -- 공정 ID
    Product_QTY         VARCHAR(10)     NOT NULL,   -- 제품 수량 (EA)
    Packing_Weight      VARCHAR(10)     NOT NULL,   -- 포장 무게 (㎏/g)
    NCount              VARCHAR(10)     NOT NULL,   -- INSPECTION_RESULT 에서 Inspection_ID or Product_ID 의 count 로 업데이트
    Start_DT            VARCHAR(10)     NOT NULL,   -- 검사 시작시간
    End_DT              VARCHAR(10)     NULL,       -- 검사 종료시간
    PCheck              VARCHAR(5)      NULL,       -- 이전 공정결과
    Result_CD           VARCHAR(5)      NULL,       -- 결과코드 (RET001)
    Error_CD            VARCHAR(5)      NULL,       -- 에러코드 (DEF####)
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_PACKING_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_PACKING_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_PACKING_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    
    CONSTRAINT PK_TB_PACKING PRIMARY KEY CLUSTERED (Inspection_ID)
);
GO


-- ============================================================================
-- 3. 언어 테이블 (Language)
-- ============================================================================

-- 그룹 공통코드
IF OBJECT_ID('dbo.TB_LANG_DICT', 'U') IS NOT NULL DROP TABLE dbo.TB_LANG_DICT;
GO
CREATE TABLE dbo.TB_LANG_DICT (
    Msg_ID              VARCHAR(30)     NOT NULL,   -- 다국어 식별 ID
    Category            VARCHAR(20)     NULL,       -- 분류 (참고용)
    Text_EN             NVARCHAR(100)   NOT NULL,   -- 영어 (Default)
    Text_KO             NVARCHAR(100)   NULL,       -- 한국어 (기본 언어는 한글이나 없는 경우 영어를 가져옴)
    Text_VI             NVARCHAR(100)   NULL,       -- 베트남어 (언어가 없는 경우 영어를 가져옴)
    Text_ETC            NVARCHAR(100)   NULL,       -- 그외 외국어
    Use_YN              CHAR(1)         NOT NULL CONSTRAINT DF_TB_LANG_DICT_Use_YN DEFAULT 'Y',   -- 사용 여부 (Y, N)
    Created_By          VARCHAR(10)     NOT NULL CONSTRAINT DF_TB_LANG_DICT_Created_By DEFAULT 'SYSTEM',   -- 생성인
    Created_DT          DATETIME2(0)    NOT NULL CONSTRAINT DF_TB_LANG_DICT_Created_DT DEFAULT SYSUTCDATETIME(),  -- 생성일자
    Modified_By         VARCHAR(10)     NULL,       -- 수정인
    Modified_DT         DATETIME2(0)    NULL,       -- 수정일자
    CONSTRAINT PK_TB_LANG_DICT PRIMARY KEY CLUSTERED (Msg_ID)
);
GO
