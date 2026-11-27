-- ============================================================================
-- Database: DB_INCAR_FCA (MSSQL 16 / SQL Server 2022)
-- Description: External Data Ingestion Stored Procedures Script (UPSERT Logic)
-- ============================================================================

USE [DB_INCAR_FCA];
GO

-- ============================================================================
-- Error 처리 프로시저
-- ============================================================================
IF OBJECT_ID('USP_GetError', 'P') IS NOT NULL DROP PROCEDURE USP_GetError;
GO
CREATE PROCEDURE USP_GetError
    @P_Save_YN  BIT = 0     -- DB Save(1), No Save(0)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ErrNum         INT           = ERROR_NUMBER();
    DECLARE @ErrSeverity    INT           = ERROR_SEVERITY();
    DECLARE @ErrState       NVARCHAR(48)  = ERROR_STATE();
    DECLARE @ErrLine        INT           = ERROR_LINE();
    DECLARE @ErrProc        NVARCHAR(128) = ISNULL(ERROR_PROCEDURE(), N'Dynamic SQL');
    DECLARE @ErrMsg         NVARCHAR(4000)= ERROR_MESSAGE();

    if @P_Save_YN = 1
    BEGIN
        SELECT
            'NG' AS RESULT,
            @ErrNum AS ErrNo,
            @ErrSeverity AS ErrSevr,
            @ErrState AS ErrStat,
            @ErrLine AS ErrLine,
            @ErrProc AS ErrProc,
            @ErrMsg AS errMsg;
        -- [TODO] insert error
    END
    ELSE
    BEGIN
        IF @ErrNum IS NOT NULL
        BEGIN
            SELECT
                'NG' AS RESULT,
                @ErrNum AS ECODE,
                CONCAT(
                    N'[Procedure: ', @ErrProc,
                    N' | State: ', @ErrState,
                    N' | Line: ', @ErrLine,
                    N' | No: ', @ErrNum, 
                    N'] ', @ErrMsg
                ) AS MESSAGE;
        END
        ELSE
        BEGIN
            SELECT 'NG' AS RESULT, '알 수 없는 오류가 발생했습니다.' AS MESSAGE;
        END
    END
END;
GO

-- ============================================================================
-- 공통 코드 / 마스터 데이터 수신 프로시저
-- ============================================================================

-- 그룹 공통코드 등록/수정 (USP_SET_GROUP_COMM_CODE)
IF OBJECT_ID('dbo.USP_SET_GROUP_COMM_CODE', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_GROUP_COMM_CODE;
GO
CREATE PROCEDURE dbo.USP_SET_GROUP_COMM_CODE
    @P_Group_CD     VARCHAR(10),
    @P_Group_NM     VARCHAR(20),
    @P_Use_YN       CHAR(1)     = 'Y',
    @P_Description  VARCHAR(50) = NULL,
    @P_User_ID      VARCHAR(10) = 'SYSTEM'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        MERGE INTO dbo.TB_GROUP_COMM_CODE WITH (HOLDLOCK) AS T
        USING (SELECT @P_Group_CD AS Group_CD) AS S
        ON (T.Group_CD = S.Group_CD)
        WHEN MATCHED THEN
            UPDATE SET 
                Group_NM    = @P_Group_NM,
                Description = @P_Description,
                Use_YN      = @P_Use_YN,
                Modified_By = @P_User_ID,
                Modified_DT = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (Group_CD, Group_NM, Description, Use_YN, Created_By, Created_DT)
            VALUES (@P_Group_CD, @P_Group_NM, @P_Description, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 그룹 공통코드 조회 (USP_GET_GROUP_COMM_CODE)
IF OBJECT_ID('dbo.USP_GET_GROUP_COMM_CODE', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_GET_GROUP_COMM_CODE;
GO
CREATE PROCEDURE dbo.USP_GET_GROUP_COMM_CODE
    --@P_Group_CD     VARCHAR(10) = NULL
    @P_Keyword  VARCHAR(50) = '',
    @P_Use_YN   CHAR(1)     = ''
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Group_CD, Group_NM, Use_YN, Description
          FROM dbo.TB_GROUP_COMM_CODE
         --WHERE (Group_CD = @P_Group_CD OR @P_Group_CD IS NULL);
         WHERE (@P_Keyword = '' OR Group_CD LIKE '%' + @P_Keyword + '%' OR Group_NM LIKE '%' + @P_Keyword + '%')
           AND (@P_Use_YN  = '' OR Use_YN = @P_Use_YN)
        ORDER BY Group_CD ASC;
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 공통코드 등록/수정 (USP_SET_COMM_CODE)
IF OBJECT_ID('dbo.USP_SET_COMM_CODE', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_COMM_CODE;
GO
CREATE PROCEDURE dbo.USP_SET_COMM_CODE
    @P_Group_CD     VARCHAR(10),
    @P_Code         VARCHAR(20),
    @P_Name         VARCHAR(10),
    @P_Disp_NO      INT,
    @P_Value1       VARCHAR(10) = NULL,
    @P_Value2       VARCHAR(10) = NULL,
    @P_Value3       VARCHAR(10) = NULL,
    @P_Use_YN       CHAR(1)     = 'Y',
    @P_Description  VARCHAR(50) = NULL,
    @P_User_ID      VARCHAR(10) = 'SYSTEM'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        MERGE INTO dbo.TB_COMM_CODE WITH (HOLDLOCK) AS T
        USING (SELECT @P_Group_CD AS Group_CD, @P_Code AS Code) AS S
        ON (T.Group_CD = S.Group_CD AND T.Code = S.Code)
        WHEN MATCHED THEN
            UPDATE SET 
                Name        = @P_Name,
                Disp_NO     = @P_Disp_NO,
                Value1      = @P_Value1,
                Value2      = @P_Value2,
                Value3      = @P_Value3,
                Description = @P_Description,
                Use_YN      = @P_Use_YN,
                Modified_By = @P_User_ID,
                Modified_DT = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (Group_CD, Code, Name, Disp_NO, Value1, Value2, Value3, Description, Use_YN, Created_By, Created_DT)
            VALUES (@P_Group_CD, @P_Code, @P_Name, @P_Disp_NO, @P_Value1, @P_Value2, @P_Value3, @P_Description, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 공통코드 조회 (USP_GET_COMM_CODE)
IF OBJECT_ID('dbo.USP_GET_COMM_CODE', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_GET_COMM_CODE;
GO
CREATE PROCEDURE dbo.USP_GET_COMM_CODE
    @P_Group_CD     VARCHAR(10),
    @P_Code         VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Group_CD, Code, Name, Disp_NO, Value1, Value2, Value3, Use_YN, Description
          FROM dbo.TB_COMM_CODE
         WHERE (Group_CD = @P_Group_CD)
           AND (Code = @P_Code OR ISNULL(@P_Code, '') = '')
         ORDER BY Disp_NO, Code;
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 모델 마스터 등록/수정 (USP_SET_MODEL)
IF OBJECT_ID('dbo.USP_SET_MODEL', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_MODEL;
GO
CREATE PROCEDURE dbo.USP_SET_MODEL
    @P_Model_CD             VARCHAR(10),
    @P_Model_NM             VARCHAR(30),
    @P_Model_Type           VARCHAR(10) = NULL,
    @P_Color_CD             VARCHAR(10),
    @P_Model_Revision       VARCHAR(10),
    @P_Effective_From_DT    DATETIME2(0),
    @P_Effective_To_DT      DATETIME2(0) = NULL,
    @P_Use_YN               CHAR(1)      = 'Y',
    @P_Description          VARCHAR(50)  = NULL,
    @P_User_ID              VARCHAR(10)  = 'SYSTEM'
AS
BEGIN
    SET NOCOUNT ON;
    PRINT @P_Effective_From_DT;
    PRINT @P_Effective_To_DT;
    BEGIN TRY
        MERGE INTO dbo.TB_MODEL WITH (HOLDLOCK) AS T
        USING (SELECT @P_Model_CD AS Model_CD) AS S
        ON (T.Model_CD = S.Model_CD)
        WHEN MATCHED THEN
            UPDATE SET 
                Model_NM          = @P_Model_NM,
                Model_Type        = @P_Model_Type,
                Color_CD          = @P_Color_CD,
                Model_Revision    = @P_Model_Revision,
                Effective_From_DT = @P_Effective_From_DT,
                Effective_To_DT   = @P_Effective_To_DT,
                Description       = @P_Description,
                Use_YN            = @P_Use_YN,
                Modified_By       = @P_User_ID,
                Modified_DT       = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (Model_CD, Model_NM, Model_Type, Color_CD, Model_Revision, Effective_From_DT, Effective_To_DT, Description, Use_YN, Created_By, Created_DT)
            VALUES (@P_Model_CD, @P_Model_NM, @P_Model_Type, @P_Color_CD, @P_Model_Revision, @P_Effective_From_DT, @P_Effective_To_DT, @P_Description, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW
    END CATCH
END;
GO

-- 모델 마스터 기준정보 조회 (USP_GET_MODEL)
IF OBJECT_ID('dbo.USP_GET_MODEL', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_GET_MODEL;
GO
CREATE PROCEDURE dbo.USP_GET_MODEL
    @P_Keyword  VARCHAR(50) = '',
    @P_Use_YN   CHAR(1)     = ''
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Model_CD, Model_NM, Model_Type, Color_CD, Model_Revision, 
               CONVERT(VARCHAR(19), Effective_From_DT, 120) AS Effective_From_DT,
               CONVERT(VARCHAR(19), Effective_To_DT, 120)   AS Effective_To_DT,
               Use_YN, Description
          FROM dbo.TB_MODEL M
         --WHERE (Model_CD = @P_Model_CD OR @P_Model_CD IS NULL);
         WHERE (@P_Keyword = '' OR Model_CD LIKE '%' + @P_Keyword + '%' OR Model_NM LIKE '%' + @P_Keyword + '%')
           AND (@P_Use_YN  = '' OR Use_YN = @P_Use_YN)
        ORDER BY Model_CD;
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 공정 마스터 기준정보 등록/수정 (USP_SET_PROCESS)
IF OBJECT_ID('dbo.USP_SET_PROCESS', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_PROCESS;
GO
CREATE PROCEDURE dbo.USP_SET_PROCESS
    @P_Process_ID       VARCHAR(10),
    @P_Process_CD       VARCHAR(20),
    @P_Process_Type_CD  VARCHAR(10),
    @P_Process_NM       VARCHAR(30),
    @P_Sequence_NO      INT,
    @P_Inspection_YN    CHAR(1),
    @P_STD_Cycle_Time   INT,
    @P_Description      VARCHAR(50) = NULL,
    @P_Use_YN           CHAR(1)     = 'Y',
    @P_Login_ID         VARCHAR(10) = 'SYSTEM'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        MERGE INTO dbo.TB_PROCESS WITH (HOLDLOCK) AS T
        USING (SELECT @P_Process_ID AS Process_ID) AS S
        ON (T.Process_ID = S.Process_ID)
        WHEN MATCHED THEN
            UPDATE SET 
                Process_CD      = @P_Process_CD,
                Process_Type_CD = @P_Process_Type_CD,
                Process_NM      = @P_Process_NM,
                Sequence_NO     = @P_Sequence_NO,
                Inspection_YN   = @P_Inspection_YN,
                STD_Cycle_Time  = @P_STD_Cycle_Time,
                Description     = @P_Description,
                Use_YN          = @P_Use_YN,
                Modified_By     = @P_Login_ID,
                Modified_DT     = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (Process_ID, Process_CD, Process_Type_CD, Process_NM, Sequence_NO, Inspection_YN, STD_Cycle_Time, Description, Use_YN, Created_By, Created_DT)
            VALUES (@P_Process_ID, @P_Process_CD, @P_Process_Type_CD, @P_Process_NM, @P_Sequence_NO, @P_Inspection_YN, @P_STD_Cycle_Time, @P_Description, @P_Use_YN, @P_Login_ID, SYSUTCDATETIME());
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 공정 마스터 조회 (USP_GET_PROCESS)
IF OBJECT_ID('dbo.USP_GET_PROCESS', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_GET_PROCESS;
GO
CREATE PROCEDURE dbo.USP_GET_PROCESS
    @P_Process_ID       VARCHAR(10) = NULL,
    @P_Process_CD       VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Process_ID, Process_CD, Process_Type_CD, Process_NM, Sequence_NO, Inspection_YN, STD_Cycle_Time, Use_YN, Description
          FROM dbo.TB_PROCESS
         WHERE (Process_ID = @P_Process_ID OR @P_Process_ID IS NULL)
           AND (Process_CD = @P_Process_CD OR @P_Process_CD IS NULL)
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 설비 마스터 등록/수정 (USP_SET_EQUIPMENT)
IF OBJECT_ID('dbo.USP_SET_EQUIPMENT', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_EQUIPMENT;
GO
CREATE PROCEDURE dbo.USP_SET_EQUIPMENT
    @P_Equipment_ID      VARCHAR(20),
    @P_Equipment_CD      VARCHAR(20),
    @P_Equipment_NM      VARCHAR(20),
    @P_Equipment_Type_CD VARCHAR(10),
    @P_Line_ID           INT,
    @P_Station_NO        INT          = NULL,
    @P_Serial_NO         VARCHAR(20)  = NULL,
    @P_Maker_NM          VARCHAR(30)  = NULL,
    @P_Model_NM          VARCHAR(30)  = NULL,
    @P_Purchase_DT       DATETIME2(0) = NULL,
    @P_Status_CD         VARCHAR(50),
    @P_Description       VARCHAR(50)  = NULL,
    @P_Use_YN            CHAR(1)      = 'Y',
    @P_Login_ID          VARCHAR(10)  = 'SYSTEM'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        MERGE INTO dbo.TB_EQUIPMENT WITH (HOLDLOCK) AS T
        USING (SELECT @P_Equipment_ID AS Equipment_ID) AS S
        ON (T.Equipment_ID = S.Equipment_ID)
        WHEN MATCHED THEN
            UPDATE SET 
                Equipment_CD      = @P_Equipment_CD,
                Equipment_NM      = @P_Equipment_NM,
                Equipment_Type_CD = @P_Equipment_Type_CD,
                Line_ID           = @P_Line_ID,
                Station_NO        = @P_Station_NO,
                Serial_NO         = @P_Serial_NO,
                Maker_NM          = @P_Maker_NM,
                Model_NM          = @P_Model_NM,
                Purchase_DT       = @P_Purchase_DT,
                Status_CD         = @P_Status_CD,
                Description       = @P_Description,
                Use_YN            = @P_Use_YN,
                Modified_By       = @P_Login_ID,
                Modified_DT       = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (Equipment_ID, Equipment_CD, Equipment_NM, Equipment_Type_CD, Line_ID, Station_NO, Serial_NO, Maker_NM, Model_NM, Purchase_DT, Status_CD, Description, Use_YN, Created_By, Created_DT)
            VALUES (@P_Equipment_ID, @P_Equipment_CD, @P_Equipment_NM, @P_Equipment_Type_CD, @P_Line_ID, @P_Station_NO, @P_Serial_NO, @P_Maker_NM, @P_Model_NM, @P_Purchase_DT, @P_Status_CD, @P_Description, @P_Use_YN, @P_Login_ID, SYSUTCDATETIME());
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 설비 마스터 조회 (USP_GET_EQUIPMENT)
IF OBJECT_ID('dbo.USP_GET_EQUIPMENT', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_GET_EQUIPMENT;
GO
CREATE PROCEDURE dbo.USP_GET_EQUIPMENT
    @P_Equipment_ID     VARCHAR(10) = NULL,
    @P_Equipment_CD     VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Equipment_ID, Equipment_CD, Equipment_NM, Equipment_Type_CD, Line_ID, Station_NO, Serial_NO, Maker_NM, Model_NM, Purchase_DT, Status_CD, Use_YN, Description
          FROM dbo.TB_EQUIPMENT
         WHERE (Equipment_ID = @P_Equipment_ID OR @P_Equipment_ID IS NULL)
           AND (Equipment_CD = @P_Equipment_CD OR @P_Equipment_CD IS NULL)
        ORDER BY Line_ID ASC, Equipment_ID
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 작업지시 등록 (USP_SET_WORK_ORDER)
IF OBJECT_ID('dbo.USP_SET_WORK_ORDER', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_WORK_ORDER;
GO
CREATE PROCEDURE dbo.USP_SET_WORK_ORDER
    @P_WO_NO                 VARCHAR(20) = '',
    @P_Model_CD              VARCHAR(20),
    @P_Plan_QTY              INT,
    @P_Start_Plan_DT         DATETIME2(0),
    @P_End_Plan_DT           DATETIME2(0),
    @P_Source_Type_CD        VARCHAR(10) = 'MANUAL',
    @P_Ext_Order_NO          VARCHAR(20) = NULL,
    @P_Approve_DT            DATETIME2(0) = NULL,
    @P_Release_DT            DATETIME2(0) = NULL,
    @P_Status_CD             VARCHAR(10)  = NULL,
    @P_Good_QTY              INT          = NULL,
    @P_Defect_QTY            INT          = NULL,
    @P_Completion_QTY        INT          = NULL,
    @P_Description           VARCHAR(50)  = NULL,
    @P_Use_YN                CHAR(1)      = 'Y',
    @P_Login_ID              VARCHAR(20)  = 'SYSTEM'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 작업지시번호가 NULL이거나 공백인 경우, 신규 작업지시번호를 자동으로 생성
        DECLARE @Target_WO_NO VARCHAR(30) = NULLIF(LTRIM(RTRIM(@P_WO_NO)), '');

        IF @Target_WO_NO IS NOT NULL
        BEGIN
            -- 등록(REG), 확정(CFM), 생산중(PRD), 완료(CC), 취소(CN)
            IF EXISTS (SELECT 1 FROM dbo.TB_WORK_ORDER WHERE WO_NO = @Target_WO_NO AND Status_CD <> 'REG')
                THROW 51001, N'등록(REG) 상태의 작업지시만 수정할 수 있습니다.', 1;
        END
        ELSE
        BEGIN
            -- 신규 작업지시번호 자동 채번: WO-YYYYMMDD-0001
            --DECLARE @DatePrefix VARCHAR(15) = 'WO-' + CONVERT(VARCHAR(6), @P_Start_Plan_DT, 12) + '-';
            DECLARE @DatePrefix VARCHAR(15) = 'WO-' + LEFT(REPLACE(@P_Start_Plan_DT, '-', ''), 8) + '-';
            DECLARE @NextSeq INT;

            SELECT @NextSeq = ISNULL(MAX(CAST(RIGHT(WO_NO, 4) AS INT)), 0) + 1
              FROM dbo.TB_WORK_ORDER WITH (UPDLOCK, HOLDLOCK)
             WHERE WO_NO LIKE @DatePrefix + '%';

            SET @Target_WO_NO = @DatePrefix + RIGHT('0000' + CAST(@NextSeq AS VARCHAR(4)), 4);
            PRINT @Target_WO_NO;
        END

        PRINT @Target_WO_NO;

        MERGE INTO dbo.TB_WORK_ORDER WITH (HOLDLOCK) AS T
        USING (SELECT @Target_WO_NO AS WO_NO) AS S
        ON (T.WO_NO = S.WO_NO)
        WHEN MATCHED THEN
            UPDATE SET 
                Model_CD             = @P_Model_CD,
                Source_Type_CD       = @P_Source_Type_CD,
                Ext_Order_NO         = ISNULL(@P_Ext_Order_NO, ''),
                Plan_QTY             = @P_Plan_QTY,
                Start_Plan_DT        = @P_Start_Plan_DT,
                End_Plan_DT          = @P_End_Plan_DT,
                Approve_DT           = @P_Approve_DT,
                Release_DT           = @P_Release_DT,
                Status_CD            = ISNULL(NULLIF(@P_Status_CD, ''), T.Status_CD),
                Good_QTY             = ISNULL(@P_Good_QTY, T.Good_QTY),
                Defect_QTY           = ISNULL(@P_Defect_QTY, T.Defect_QTY),
                Completion_QTY       = ISNULL(@P_Completion_QTY, T.Completion_QTY),
                Description          = @P_Description,
                Use_YN               = @P_Use_YN,
                Modified_By          = @P_Login_ID,
                Modified_DT          = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (WO_NO, Model_CD, Source_Type_CD, Ext_Order_NO, Plan_QTY, Start_Plan_DT, End_Plan_DT, Approve_DT, Release_DT, Status_CD, Good_QTY, Defect_QTY, Completion_QTY, Description, Use_YN, Created_By, Created_DT)
            VALUES (@Target_WO_NO, @P_Model_CD, @P_Source_Type_CD, ISNULL(@P_Ext_Order_NO, ''), @P_Plan_QTY, @P_Start_Plan_DT, @P_End_Plan_DT, NULL, NULL, 'REG', 0, 0, 0, @P_Description, @P_Use_YN, @P_Login_ID, SYSUTCDATETIME());
    
        COMMIT TRANSACTION;

        SELECT 'OK' AS RESULT, @Target_WO_NO AS WO_NO, N'' AS MESSAGE;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 작업지시 조회 (USP_GET_WORK_ORDER)
IF OBJECT_ID('dbo.USP_GET_WORK_ORDER', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_GET_WORK_ORDER;
GO
CREATE PROCEDURE dbo.USP_GET_WORK_ORDER
    @P_Start_DT   VARCHAR(10) = '',
    @P_End_DT     VARCHAR(10) = '',
    @P_Status_CD    VARCHAR(20) = '',
    @P_Keyword      VARCHAR(50) = ''
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT W.WO_NO, W.Model_CD, M.Model_NM,
               W.Source_Type_CD, ISNULL(C_REG.Name, W.Source_Type_CD) AS Source_Type_NM,
               W.Ext_Order_NO, W.Plan_QTY,
               CONVERT(VARCHAR(19), W.Start_Plan_DT, 120) AS Start_Plan_DT,
               CONVERT(VARCHAR(19), W.End_Plan_DT, 120) AS End_Plan_DT,
               CONVERT(VARCHAR(19), W.Release_DT, 120) AS Release_DT,
               W.Status_CD, ISNULL(C_STA.Name, W.Status_CD) AS Status_NM,
               ISNULL(W.Good_QTY, 0) AS Good_QTY,
               ISNULL(W.Defect_QTY, 0) AS Defect_QTY,
               ISNULL(W.Completion_QTY, 0) AS Completion_QTY,
               W.Use_YN, W.Description,
               (SELECT COUNT(*) FROM dbo.TB_LOT_MASTER L WHERE L.WO_NO = W.WO_NO) AS Created_Lot_Cnt
          FROM dbo.TB_WORK_ORDER W
        LEFT JOIN dbo.TB_MODEL M ON W.Model_CD = M.Model_CD
        LEFT JOIN dbo.TB_COMM_CODE C_REG ON C_REG.Group_CD = 'REG001' AND C_REG.Code = W.Source_Type_CD
        LEFT JOIN dbo.TB_COMM_CODE C_STA ON C_STA.Group_CD = 'STA001' AND C_STA.Code = W.Status_CD
        WHERE (@P_Start_DT = '' OR CONVERT(VARCHAR(10), W.Start_Plan_DT, 120) >= @P_Start_DT)
          AND (@P_End_DT = '' OR CONVERT(VARCHAR(10), W.End_Plan_DT, 120) <= @P_End_DT)
          AND (@P_Status_CD = '' OR W.Status_CD  = @P_Status_CD)
          AND (@P_Keyword = '' OR W.WO_NO LIKE '%' + @P_Keyword + '%' OR W.Model_CD LIKE '%' + @P_Keyword + '%')
        ORDER BY W.Start_Plan_DT DESC, W.WO_NO DESC;
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 작업지시별 LOT 목록 조회 (USP_GET_WORK_ORDER_LOTS)
IF OBJECT_ID('dbo.USP_GET_WORK_ORDER_LOTS', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_GET_WORK_ORDER_LOTS;
GO
CREATE OR ALTER PROCEDURE dbo.USP_GET_WORK_ORDER_LOTS
    @P_WO_NO VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT L.Lot_NO, L.WO_NO, L.Plan_QTY,
           CONVERT(VARCHAR(19), L.Start_DT, 120) AS Start_DT, CONVERT(VARCHAR(19), L.End_DT, 120) AS End_DT,
           ISNULL(L.Good_QTY, 0) AS Good_QTY, ISNULL(L.Defect_QTY, 0) AS Defect_QTY, ISNULL(L.Completion_QTY, 0) AS Completion_QTY,
           L.Status_CD, ISNULL(C.Name, L.Status_CD) AS Status_NM, L.Use_YN, CONVERT(VARCHAR(19), L.Created_DT, 120) AS Created_DT
      FROM dbo.TB_LOT_MASTER L
      LEFT JOIN dbo.TB_COMM_CODE C ON C.Group_CD = 'STA003' AND C.Code = L.Status_CD
     WHERE L.WO_NO = @P_WO_NO
     ORDER BY L.Lot_NO ASC;
END;
GO

-- 작업지시 승인 (USP_APPROVE_WORK_ORDER)
IF OBJECT_ID('dbo.USP_APPROVE_WORK_ORDER', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_APPROVE_WORK_ORDER;
GO
CREATE OR ALTER PROCEDURE dbo.USP_APPROVE_WORK_ORDER
    @P_WO_NO        VARCHAR(10),
    @P_Action_YN    CHAR(1),    -- 확인(Y), 취소(N)
    @P_Login_ID     VARCHAR(10) = 'SYSTEM',
    @P_Lot_Size     INT         = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @Model_CD       VARCHAR(20),
                @Plan_QTY       INT,
                @Start_Plan_DT  DATETIME2(0),
                @End_Plan_DT    DATETIME2(0),
                @Status_CD      VARCHAR(10),
                @Route_ID       VARCHAR(20),
                @First_Proc     VARCHAR(20);
        DECLARE @CurrentDT      DATETIME2(0) = SYSUTCDATETIME();

        -- 1. 작업지시 유효성 및 상태('REG') 확인
        SELECT @Model_CD      = Model_CD,
               @Plan_QTY      = Plan_QTY,
               @Start_Plan_DT = Start_Plan_DT,
               @End_Plan_DT   = End_Plan_DT,
               @Status_CD     = Status_CD
          FROM dbo.TB_WORK_ORDER WITH (UPDLOCK, HOLDLOCK)
         WHERE WO_NO = @P_WO_NO;

        IF @Status_CD IS NULL
            THROW 51002, N'존재하지 않는 작업지시 번호입니다.', 1;

        -- 등록(REG), 확정(CFM), 생산중(PRD), 완료(CC), 취소(CN)
        IF @Status_CD = 'REG'
        BEGIN
            SET @Status_CD = CASE WHEN @P_Action_YN = 'Y' THEN 'CFM' ELSE 'CN' END;
            UPDATE dbo.TB_WORK_ORDER
               SET Status_CD   = @Status_CD,
                   Approve_DT  = @CurrentDT,
                   Modified_By = @P_Login_ID,
                   Modified_DT = @CurrentDT
             WHERE WO_NO = @P_WO_NO;
        END
        ELSE IF @Status_CD = 'CFM'
        BEGIN
            IF @P_Action_YN = 'N'
                THROW 51003, N'확정(CFM) 상태의 작업지시는 취소(CN)만 할 수 있습니다.', 1;

            SET @Status_CD = 'CN';
            UPDATE dbo.TB_WORK_ORDER
               SET Status_CD   = @Status_CD,
                   Approve_DT  = @CurrentDT,
                   Modified_By = @P_Login_ID,
                   Modified_DT = @CurrentDT
             WHERE WO_NO = @P_WO_NO
               AND @P_Action_YN = 'N';
        END
        ELSE IF @Status_CD = 'PRD'
        BEGIN
            IF @P_Action_YN = 'N'
                THROW 51003, N'생상중(PRD) 상태의 작업지시는 취소(CN)할 수 없습니다.', 1;

            SET @Status_CD = 'CC';
            UPDATE dbo.TB_WORK_ORDER
               SET Status_CD   = @Status_CD,
                   Approve_DT  = @CurrentDT,
                   Modified_By = @P_Login_ID,
                   Modified_DT = @CurrentDT
             WHERE WO_NO = @P_WO_NO
               AND @P_Action_YN = 'Y';
            -- TODO : 완료에 따른 LOT MASTER, PRODUCT MASTER 테이블의 양품/불량/완료일 등 처리
        END

        -- 2. 모델에 매핑된 활성 라우팅 및 첫 번째 공정(Process_ID) 조회
        SELECT TOP 1 @Route_ID = Route_ID
          FROM dbo.TB_PROCESS_ROUTE
         WHERE Model_CD = @Model_CD
           AND Use_YN = 'Y'
           AND @CurrentDT >= Effective_From_DT
           AND (Effective_To_DT IS NULL OR @CurrentDT <= Effective_To_DT)
         ORDER BY Effective_From_DT DESC;

        IF @Route_ID IS NULL
            THROW 51004, N'해당 모델에 유효한 활성 라우팅 정보가 없습니다.', 1;

        SELECT TOP 1 @First_Proc = Process_CD
          FROM dbo.TB_PROCESS_ROUTE_DETAIL
         WHERE Route_ID = @Route_ID AND Use_YN = 'Y'
         ORDER BY Sequence_NO ASC;

        IF @First_Proc IS NULL
            THROW 51005, N'해당 라우팅에 등록된 활성 공정 상세 정보가 없습니다.', 1;

        -- 3. LOT 분할 수량 계산 및 16자리 자동 채번 (LOT-YYYYMMDD-0001 = 16자리)
        DECLARE @Unit_Size   INT = CASE WHEN ISNULL(@P_Lot_Size, 0) <= 0 THEN @Plan_QTY ELSE @P_Lot_Size END;
        DECLARE @Remain_Qty  INT = @Plan_QTY;
        DECLARE @Current_Qty INT;
        --DECLARE @LotPrefix   VARCHAR(7) = 'LOT' + CONVERT(VARCHAR(8), SYSUTCDATETIME(), 12);
        DECLARE @LotPrefix   VARCHAR(20) = 'LOT-' + LEFT(REPLACE(SYSUTCDATETIME(), '-', ''), 8) + '-';
        DECLARE @NextLotSeq  INT;
        DECLARE @New_Lot_NO  VARCHAR(20);

        SELECT @NextLotSeq = ISNULL(MAX(CAST(RIGHT(Lot_NO, 4) AS INT)), 0) + 1
          FROM dbo.TB_LOT_MASTER WITH (UPDLOCK, HOLDLOCK)
         WHERE Lot_NO LIKE @LotPrefix + '%';

        -- LOT 생성수 = 계획량(Plan_QTY) / LOT 단위 수량(Lot_Size)
        WHILE @Remain_Qty > 0
        BEGIN
            SET @NextLotSeq = @NextLotSeq + 1;
            SET @Current_Qty = CASE WHEN @Remain_Qty >= @Unit_Size THEN @Unit_Size ELSE @Remain_Qty END;
            SET @New_Lot_NO = @LotPrefix + RIGHT('0000' + CAST(@NextLotSeq AS VARCHAR(4)), 4);

            INSERT INTO dbo.TB_LOT_MASTER (
                Lot_NO, WO_NO, Plan_QTY,
                Start_DT, End_DT, Good_QTY, Defect_QTY, Completion_QTY,
                Status_CD, Use_YN, Created_By, Created_DT
            ) VALUES (
                @New_Lot_NO, @P_WO_NO, @Current_Qty,
                @Start_Plan_DT, @End_Plan_DT, 0, 0, 0,
                'REG', 'Y', @P_Login_ID, SYSUTCDATETIME()
            );

            SET @Remain_Qty = @Remain_Qty - @Current_Qty;
        END

        -- 4. 작업지시 상태를 'CFM'(확정)으로 업데이트
        --UPDATE dbo.TB_WORK_ORDER
        --SET Status_CD   = 'CFM',
        --    Release_DT  = SYSUTCDATETIME(),
        --    Modified_By = @P_Login_ID,
        --    Modified_DT = SYSUTCDATETIME()
        --WHERE WO_NO = @P_WO_NO;

        COMMIT TRANSACTION;

        -- 5. 생성된 LOT 목록 즉시 반환
        EXEC dbo.USP_GET_WORK_ORDER_LOTS @P_WO_NO = @P_WO_NO;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 생산품 마스터 (재공/WIP) 등록 (USP_SET_PRODUCT_MASTER)
IF OBJECT_ID('dbo.USP_SET_PRODUCT_MASTER', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_PRODUCT_MASTER;
GO
CREATE PROCEDURE dbo.USP_SET_PRODUCT_MASTER
    @JsonInput VARCHAR(MAX)
    --@P_User_ID          VARCHAR(20),
    --@P_Product_ID       VARCHAR(20),
    --@P_Inspection_ID    VARCHAR(20),
    --@P_WO_NO            VARCHAR(20),
    --@P_Lot_NO           VARCHAR(20),
    --@P_Process_ID       VARCHAR(30),
    --@P_Process_State    VARCHAR(5)   = 'RUN',
    --@P_Result_CD        VARCHAR(5)   = NULL,
    --@P_Error_CD         VARCHAR(5)   = NULL,
    --@P_Stator_Barcode   VARCHAR(30)  = NULL,
    --@P_PCB_Barcode      VARCHAR(30)  = NULL,
    --@P_Product_Label    VARCHAR(30)  = NULL,
    --@P_Housing_SN       VARCHAR(30)  = NULL,
    --@P_Impeller_SN      VARCHAR(30)  = NULL,
    --@P_Use_YN           CHAR(1)      = 'Y'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF ISJSON(@JsonInput) = 0
        BEGIN
            RAISERROR(N'잘못된 JSON 형식입니다. 올바른 데이터를 전달해주세요.', 16, 1);
            RETURN;
        END;

        --DECLARE @P_User_ID          VARCHAR(20);
        --DECLARE @P_Product_ID       VARCHAR(20);
        --DECLARE @P_Inspection_ID    VARCHAR(20);
        --DECLARE @P_WO_NO            VARCHAR(20);
        --DECLARE @P_Lot_NO           VARCHAR(10);
        --DECLARE @P_Process_ID       VARCHAR(30);
        --DECLARE @P_Process_State    VARCHAR(5);
        --DECLARE @P_Result_CD        VARCHAR(5);
        --DECLARE @P_Error_CD         VARCHAR(5);
        --DECLARE @P_Stator_Barcode   VARCHAR(30);
        --DECLARE @P_PCB_Barcode      VARCHAR(30);
        --DECLARE @P_Product_Label    VARCHAR(30);
        --DECLARE @P_Housing_SN       VARCHAR(30);
        --DECLARE @P_Impeller_SN      VARCHAR(30);
        --DECLARE @P_Use_YN           CHAR(1);

        --SELECT 
        --    @P_User_ID          = User_ID,
        --    @P_Product_ID       = Product_ID,
        --    @P_Inspection_ID    = Inspection_ID,
        --    @P_WO_NO            = WO_NO,
        --    @P_Lot_NO           = Lot_NO,
        --    @P_Process_ID       = Process_ID,
        --    @P_Process_State    = Process_State,
        --    @P_Result_CD        = Result_CD,
        --    @P_Error_CD         = Error_CD,
        --    @P_Stator_Barcode   = Stator_Barcode,
        --    @P_PCB_Barcode      = PCB_Barcode,
        --    @P_Product_Label    = Product_Label,
        --    @P_Housing_SN       = Housing_SN,
        --    @P_Impeller_SN      = Impeller_SN,
        --    @P_Use_YN           = Use_YN
        --FROM OPENJSON(@JsonInput)
        --WITH (
        --    User_ID          VARCHAR(20) '$.User_ID',
        --    Product_ID       VARCHAR(20) '$.Product_ID',
        --    Inspection_ID    VARCHAR(20) '$.Inspection_ID',
        --    WO_NO            VARCHAR(20) '$.WO_NO',
        --    Lot_NO           VARCHAR(10) '$.Lot_NO',
        --    Process_ID       VARCHAR(30) '$.Process_ID',
        --    Process_State    VARCHAR(5)  '$.Process_State',
        --    Result_CD        VARCHAR(5)  '$.Result_CD',
        --    Error_CD         VARCHAR(5)  '$.Error_CD',
        --    Stator_Barcode   VARCHAR(30) '$.Stator_Barcode',
        --    PCB_Barcode      VARCHAR(30) '$.PCB_Barcode',
        --    Product_Label    VARCHAR(30) '$.Product_Label',
        --    Housing_SN       VARCHAR(30) '$.Housing_SN',
        --    Impeller_SN      VARCHAR(30) '$.Impeller_SN',
        --    Use_YN           CHAR(1)     '$.Use_YN'
        --);
        DECLARE @P_User_ID          VARCHAR(20) = JSON_VALUE(@JsonInput, '$.User_ID');
        DECLARE @P_Product_ID       VARCHAR(20) = JSON_VALUE(@JsonInput, '$.Product_ID');
        DECLARE @P_Inspection_ID    VARCHAR(20) = JSON_VALUE(@JsonInput, '$.Inspection_ID');
        DECLARE @P_WO_NO            VARCHAR(20) = JSON_VALUE(@JsonInput, '$.WO_NO');
        DECLARE @P_Lot_NO           VARCHAR(20) = JSON_VALUE(@JsonInput, '$.Lot_NO');
        DECLARE @P_Process_ID       VARCHAR(30) = JSON_VALUE(@JsonInput, '$.Process_ID');
        DECLARE @P_Process_State    VARCHAR(5)  = JSON_VALUE(@JsonInput, '$.Process_State');
        DECLARE @P_Result_CD        VARCHAR(5)  = JSON_VALUE(@JsonInput, '$.Result_CD');
        DECLARE @P_Error_CD         VARCHAR(5)  = JSON_VALUE(@JsonInput, '$.Error_CD');
        DECLARE @P_Stator_Barcode   VARCHAR(30) = JSON_VALUE(@JsonInput, '$.Stator_Barcode');
        DECLARE @P_PCB_Barcode      VARCHAR(30) = JSON_VALUE(@JsonInput, '$.PCB_Barcode');
        DECLARE @P_Product_Label    VARCHAR(30) = JSON_VALUE(@JsonInput, '$.Product_Label');
        DECLARE @P_Housing_SN       VARCHAR(30) = JSON_VALUE(@JsonInput, '$.Housing_SN');
        DECLARE @P_Impeller_SN      VARCHAR(30) = JSON_VALUE(@JsonInput, '$.Impeller_SN');
        DECLARE @P_Use_YN           CHAR(1)     = ISNULL(JSON_VALUE(@JsonInput, '$.Use_YN'), 'Y');

        MERGE INTO dbo.TB_PRODUCT_MASTER WITH (HOLDLOCK) AS T
        USING (SELECT @P_Product_ID AS Product_ID) AS S
        ON (T.Product_ID = S.Product_ID)
        WHEN MATCHED THEN
            UPDATE SET 
                WO_NO            = ISNULL(@P_WO_NO, WO_NO),
                Lot_NO           = ISNULL(@P_Lot_NO, Lot_NO),
                Process_ID       = ISNULL(@P_Process_ID, Process_ID),
                Inspection_ID    = ISNULL(@P_Inspection_ID, Inspection_ID),
                Result_CD        = ISNULL(@P_Result_CD, Result_CD),
                Error_CD         = ISNULL(@P_Error_CD, Error_CD),
                Stator_Barcode   = ISNULL(@P_Stator_Barcode, Stator_Barcode),
                PCB_Barcode      = ISNULL(@P_PCB_Barcode, PCB_Barcode),
                Product_Label    = ISNULL(@P_Product_Label, Product_Label),
                Housing_SN       = ISNULL(@P_Housing_SN, Housing_SN),
                Impeller_SN      = ISNULL(@P_Impeller_SN, Impeller_SN),
                --Process_State    = @P_Process_State,
                Modified_By      = @P_User_ID,
                Modified_DT      = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (Product_ID, WO_NO, Lot_NO, Process_ID, Inspection_ID, Result_CD, Error_CD, Stator_Barcode, PCB_Barcode, Product_Label, Housing_SN, Impeller_SN, Process_State, Use_YN, Created_By, Created_DT)
            VALUES (@P_Product_ID, @P_WO_NO, @P_Lot_NO, @P_Process_ID, @P_Inspection_ID, @P_Result_CD, @P_Error_CD, @P_Stator_Barcode, @P_PCB_Barcode, @P_Product_Label, @P_Housing_SN, @P_Impeller_SN, @P_Process_State, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 생산품 마스터 (재공/WIP) 조회 (USP_GET_PRODUCT_MASTER)
IF OBJECT_ID('dbo.USP_GET_PRODUCT_MASTER', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_GET_PRODUCT_MASTER;
GO
CREATE PROCEDURE dbo.USP_GET_PRODUCT_MASTER
    @P_Product_ID       VARCHAR(20) = NULL,
    @P_Inspection_ID    VARCHAR(20) = NULL,
    @P_WO_NO            VARCHAR(20) = NULL,
    @P_Lot_NO           VARCHAR(10) = NULL,
    @P_Process_State    VARCHAR(5)  = NULL,
    @P_Result_CD        VARCHAR(5)  = NULL,
    @P_Error_CD         VARCHAR(5)  = NULL,
    @P_Stator_Barcode   VARCHAR(30) = NULL,
    @P_PCB_Barcode      VARCHAR(30) = NULL,
    @P_Product_Label    VARCHAR(30) = NULL,
    @P_Housing_SN       VARCHAR(30) = NULL,
    @P_Impeller_SN      VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Sql NVARCHAR(MAX);
    DECLARE @WhereClause NVARCHAR(MAX) = N'';
    DECLARE @ParamList NVARCHAR(MAX);
    BEGIN TRY
        SET @Sql = N'SELECT Product_ID, WO_NO, Lot_NO, Process_ID, Inspection_ID, 
                            Result_CD, Error_CD, Stator_Barcode, PCB_Barcode, Product_Label, 
                            Housing_SN, Impeller_SN, Process_State, Use_YN, Description
                       FROM dbo.TB_PRODUCT_MASTER';
        IF @P_Product_ID IS NOT NULL
            SET @WhereClause += N' AND Product_ID = @P_Product_ID';
        IF @P_WO_NO IS NOT NULL
            SET @WhereClause += N' AND WO_NO = @P_WO_NO';
        IF @P_Lot_NO IS NOT NULL
            SET @WhereClause += N' AND Lot_NO = @P_Lot_NO';
        IF @P_Inspection_ID IS NOT NULL
            SET @WhereClause += N' AND Inspection_ID = @P_Inspection_ID';
        IF @P_Result_CD IS NOT NULL
            SET @WhereClause += N' AND Result_CD = @P_Result_CD';
        IF @P_Error_CD IS NOT NULL
            SET @WhereClause += N' AND Error_CD = @P_Error_CD';
        IF @P_Stator_Barcode IS NOT NULL
            SET @WhereClause += N' AND Stator_Barcode = @P_Stator_Barcode';
        IF @P_PCB_Barcode IS NOT NULL
            SET @WhereClause += N' AND PCB_Barcode = @P_PCB_Barcode';
        IF @P_Product_Label IS NOT NULL
            SET @WhereClause += N' AND Product_Label = @P_Product_Label';
        IF @P_Housing_SN IS NOT NULL
            SET @WhereClause += N' AND Housing_SN = @P_Housing_SN';
        IF @P_Impeller_SN IS NOT NULL
            SET @WhereClause += N' AND Impeller_SN = @P_Impeller_SN';

        -- 조건이 하나라도 있으면 WHERE 절 결합
        IF LEN(@WhereClause) > 0
            SET @Sql += N' WHERE 1 = 1' + @WhereClause;

        -- 파라미터 정의
        SET @ParamList = N'@P_Product_ID VARCHAR(20), @P_WO_NO VARCHAR(20), @P_Lot_NO VARCHAR(10), @P_Inspection_ID VARCHAR(20), 
                            @P_Result_CD VARCHAR(5), @P_Error_CD VARCHAR(5), @P_Stator_Barcode VARCHAR(30), @P_PCB_Barcode VARCHAR(30), 
                            @P_Product_Label VARCHAR(30), @P_Housing_SN VARCHAR(30), @P_Impeller_SN VARCHAR(30)';

        -- 동적 SQL 실행
    EXEC sp_executesql @Sql, @ParamList,
        @P_Product_ID, @P_WO_NO, @P_Lot_NO, @P_Inspection_ID, @P_Result_CD, @P_Error_CD,
        @P_Stator_Barcode, @P_PCB_Barcode, @P_Product_Label, @P_Housing_SN, @P_Impeller_SN;
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 공정 실적 수신/저장 (USP_SET_PROCESS_EXECUTION)
--IF OBJECT_ID('dbo.USP_SET_PROCESS_EXECUTION', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_PROCESS_EXECUTION;
--GO
--CREATE PROCEDURE dbo.USP_SET_PROCESS_EXECUTION
--    @P_Execution_ID      VARCHAR(20),
--    @P_Prev_Execution_ID VARCHAR(20) = '0',
--    @P_Inspection_ID     VARCHAR(20),
--    @P_Product_ID        VARCHAR(20),
--    @P_WO_NO             VARCHAR(20),
--    @P_Lot_NO            VARCHAR(10),
--    @P_Process_ID        VARCHAR(30),
--    @P_Equipment_ID      VARCHAR(10),
--    @P_Worker_ID         VARCHAR(10),
--    @P_NCount            VARCHAR(10) = '1',
--    @P_Start_DT          VARCHAR(10),
--    @P_End_DT            VARCHAR(10) = NULL,
--    @P_PCheck            VARCHAR(5)  = NULL,
--    @P_Result_CD         VARCHAR(5)  = NULL,
--    @P_Error_CD          VARCHAR(5)  = NULL,
--    @P_Use_YN            CHAR(1)     = 'Y',
--    @P_User_ID           VARCHAR(10) = 'SYSTEM'
--AS
--BEGIN
--    SET NOCOUNT ON;
--    BEGIN TRY
--        MERGE INTO dbo.TB_PROCESS_EXECUTION WITH (HOLDLOCK) AS T
--        USING (SELECT @P_Execution_ID AS Execution_ID) AS S
--        ON (T.Execution_ID = S.Execution_ID)
--        WHEN MATCHED THEN
--            UPDATE SET 
--                Prev_Execution_ID = @P_Prev_Execution_ID,
--                Inspection_ID     = @P_Inspection_ID,
--                Product_ID        = @P_Product_ID,
--                WO_NO             = @P_WO_NO,
--                Lot_NO            = @P_Lot_NO,
--                Process_ID        = @P_Process_ID,
--                Equipment_ID      = @P_Equipment_ID,
--                Worker_ID         = @P_Worker_ID,
--                NCount            = @P_NCount,
--                Start_DT          = @P_Start_DT,
--                End_DT            = @P_End_DT,
--                PCheck            = @P_PCheck,
--                Result_CD         = @P_Result_CD,
--                Error_CD          = @P_Error_CD,
--                Use_YN            = @P_Use_YN,
--                Modified_By       = @P_User_ID,
--                Modified_DT       = SYSUTCDATETIME()
--        WHEN NOT MATCHED THEN
--            INSERT (Execution_ID, Prev_Execution_ID, Inspection_ID, Product_ID, WO_NO, Lot_NO, Process_ID, Equipment_ID, Worker_ID, NCount, Start_DT, End_DT, PCheck, Result_CD, Error_CD, Use_YN, Created_By, Created_DT)
--            VALUES (@P_Execution_ID, @P_Prev_Execution_ID, @P_Inspection_ID, @P_Product_ID, @P_WO_NO, @P_Lot_NO, @P_Process_ID, @P_Equipment_ID, @P_Worker_ID, @P_NCount, @P_Start_DT, @P_End_DT, @P_PCheck, @P_Result_CD, @P_Error_CD, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());
--    END TRY
--    BEGIN CATCH
--        THROW;
--    END CATCH
--END;
--GO


-- 불량코드 등록/수정 (USP_SET_DEFECT_CODE)
IF OBJECT_ID('dbo.USP_SET_DEFECT_CODE', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_DEFECT_CODE;
GO
CREATE PROCEDURE dbo.USP_SET_DEFECT_CODE
    @P_Defect_CD        VARCHAR(10),
    @P_Defect_NM        VARCHAR(20),
    @P_Defect_Type_CD   VARCHAR(20),
    @P_Process_ID       VARCHAR(10),
    @P_Severity_CD      VARCHAR(10),
    @P_Description      VARCHAR(50) = NULL,
    @P_Use_YN           CHAR(1)     = 'Y',
    @P_User_ID          VARCHAR(10) = 'SYSTEM'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        MERGE INTO dbo.TB_DEFECT_CODE WITH (HOLDLOCK) AS T
        USING (SELECT @P_Defect_CD AS Defect_CD) AS S
        ON (T.Defect_CD = S.Defect_CD)
        WHEN MATCHED THEN
            UPDATE SET 
                Defect_CD       = @P_Defect_CD,
                Defect_NM       = @P_Defect_NM,
                Defect_Type_CD  = @P_Defect_Type_CD,
                Process_ID      = @P_Process_ID,
                Severity_CD     = @P_Severity_CD,
                Description     = @P_Description,
                Use_YN          = @P_Use_YN,
                Modified_By     = @P_User_ID,
                Modified_DT     = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (Defect_CD, Defect_NM, Defect_Type_CD, Process_ID, Severity_CD, Description, Use_YN, Created_By, Created_DT)
            VALUES (@P_Defect_CD, @P_Defect_NM, @P_Defect_Type_CD, @P_Process_ID, @P_Severity_CD, @P_Description, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 불량코드 조회 (USP_GET_DEFECT_CODE)
IF OBJECT_ID('dbo.USP_GET_DEFECT_CODE', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_GET_DEFECT_CODE;
GO
CREATE PROCEDURE dbo.USP_GET_DEFECT_CODE
    @P_Defect_CD        VARCHAR(10),
    @P_Process_ID       VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Defect_CD, Defect_NM, Defect_Type_CD, Process_ID, Severity_CD, Use_YN, Description
          FROM dbo.TB_DEFECT_CODE
         WHERE (Defect_CD = @P_Defect_CD OR @P_Defect_CD IS NULL)
           AND (Process_ID = @P_Process_ID OR @P_Process_ID IS NULL)
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 공정라우터 등록/수정 (USP_SET_PROCESS_ROUTE)
IF OBJECT_ID('dbo.USP_SET_PROCESS_ROUTE', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_PROCESS_ROUTE;
GO
CREATE PROCEDURE dbo.USP_SET_PROCESS_ROUTE
    @P_Route_ID             VARCHAR(20),
    @P_Route_NM             VARCHAR(20),
    @P_Model_CD             VARCHAR(20),
    @P_Revision_CD          VARCHAR(10),
    @P_Effective_From_DT    DATETIME2(0),
    @P_Effective_To_DT      DATETIME2(0),
    @P_Status_CD            VARCHAR(10),
    @P_Description          VARCHAR(50) = NULL,
    @P_Use_YN               CHAR(1)     = 'Y',
    @P_User_ID              VARCHAR(10) = 'SYSTEM'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        MERGE INTO dbo.TB_PROCESS_ROUTE WITH (HOLDLOCK) AS T
        USING (SELECT @P_Route_ID AS Route_ID) AS S
        ON (T.Route_ID = S.Route_ID)
        WHEN MATCHED THEN
            UPDATE SET 
                Route_ID            = @P_Route_ID,
                Route_NM            = @P_Route_NM,
                Model_CD            = @P_Model_CD,
                Revision_CD         = @P_Revision_CD,
                Effective_From_DT   = @P_Effective_From_DT,
                Effective_To_DT     = @P_Effective_To_DT,
                Status_CD           = @P_Status_CD,
                Description         = @P_Description,
                Use_YN              = @P_Use_YN,
                Modified_By         = @P_User_ID,
                Modified_DT         = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (Route_ID, Route_NM, Model_CD, Revision_CD, Effective_From_DT, Effective_To_DT, Description, Use_YN, Created_By, Created_DT)
            VALUES (@P_Route_ID, @P_Route_NM, @P_Model_CD, @P_Revision_CD, @P_Effective_From_DT, @P_Effective_To_DT, @P_Description, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 공정라우터 조회 (USP_GET_PROCESS_ROUTE)
IF OBJECT_ID('dbo.USP_GET_PROCESS_ROUTE', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_GET_PROCESS_ROUTE;
GO
CREATE PROCEDURE dbo.USP_GET_PROCESS_ROUTE
    @P_Route_ID             VARCHAR(20),
    @P_Model_CD             VARCHAR(20),
    @P_Revision_CD          VARCHAR(10),
    @P_Status_CD            VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Route_ID, Route_NM, Model_CD, Revision_CD, Effective_From_DT, Effective_To_DT, Use_YN, Description
        FROM dbo.TB_PROCESS_ROUTE
        WHERE (Route_ID = @P_Route_ID OR @P_Route_ID IS NULL)
        AND (Model_CD = @P_Model_CD OR @P_Model_CD IS NULL)
        AND (Revision_CD = @P_Revision_CD OR @P_Revision_CD IS NULL)
        AND (Status_CD = @P_Status_CD OR @P_Status_CD IS NULL)
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- 공정라우터 디테일 조회 (USP_GET_PROCESS_ROUTE_DETAIL)
IF OBJECT_ID('dbo.USP_GET_PROCESS_ROUTE_DETAIL', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_GET_PROCESS_ROUTE_DETAIL;
GO
CREATE OR ALTER PROCEDURE dbo.USP_GET_ROUTE_DETAIL
    @P_Route_ID VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT D.RouteD_ID,
           D.Route_ID,
           P.Process_CD,
           P.Process_NM,
           D.Sequence_NO,
           D.Required_YN,
           D.Inspection_YN,
           D.PreProcess_CD,
           D.Line_NO,
           D.STD_Cycle_Time,
           D.Rework_Allowed_YN,
           D.Rework_Process_ID,
           D.Description
      FROM dbo.TB_PROCESS_ROUTE_DETAIL D
      LEFT JOIN dbo.TB_PROCESS P ON D.Process_CD = P.Process_CD
     WHERE D.Route_ID = @P_Route_ID
     ORDER BY D.Sequence_NO ASC;
END;
GO

-- 라우팅 상세 저장 (USP_SET_PROCESS_ROUTE_DETAIL)
IF OBJECT_ID('dbo.USP_SET_PROCESS_ROUTE_DETAIL', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_PROCESS_ROUTE_DETAIL;
GO
CREATE OR ALTER PROCEDURE dbo.USP_SET_PROCESS_ROUTE_DETAIL
    @P_Route_ID                 VARCHAR(20),
    @P_Process_CD               VARCHAR(10),
    @P_Process_NM               VARCHAR(30),
    @P_Sequence_NO              INT,
    @P_Required_YN              CHAR(1),
    @P_Inspection_YN            CHAR(1),
    @P_PreProcess_CD            VARCHAR(10),
    @P_Line_NO                  VARCHAR(10),
    @P_STD_Cycle_Time           INT,
    @P_Rework_Allowed_YN        CHAR(1),
    @P_Rework_Process_CD        VARCHAR(10),
    @P_Use_YN                   CHAR(1)         = 'Y',
    @P_Description              NVARCHAR(200)   = NULL,
    @P_User_ID                  VARCHAR(20)     = 'SYSTEM'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Clean_Prev_ID VARCHAR(20) = NULLIF(LTRIM(RTRIM(@P_PreProcess_CD)), '');

        MERGE INTO dbo.TB_PROCESS_ROUTE_DETAIL WITH (HOLDLOCK) AS T
        USING (SELECT @P_Route_ID AS Route_ID, @P_Sequence_NO AS Sequence_NO) AS S
        ON (T.Route_ID = S.Route_ID AND T.Sequence_NO = S.Sequence_NO)
        WHEN MATCHED THEN
            UPDATE SET
                --T.RouteD_ID         = @P_RouteD_ID,
                T.Route_ID          = @P_Route_ID,
                T.Process_CD        = @P_Process_CD,
                T.Process_NM        = @P_Process_NM,
                T.Sequence_NO       = @P_Sequence_NO,
                T.Required_YN       = @P_Required_YN,
                T.Inspection_YN     = @P_Inspection_YN,
                T.PreProcess_CD     = @P_PreProcess_CD,
                T.Line_NO           = @P_Line_NO,
                T.STD_Cycle_Time    = @P_STD_Cycle_Time,
                T.Rework_Allowed_YN = @P_Rework_Allowed_YN,
                T.Rework_Process_CD = @P_Rework_Process_CD,
                T.Use_YN            = @P_Use_YN,
                T.Description       = @P_Description,
                T.Modified_By       = @P_User_ID,
                T.Modified_DT       = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (Route_ID, Process_CD, Process_NM, Sequence_NO, Required_YN, Inspection_YN, PreProcess_CD, Line_NO, STD_Cycle_Time, Rework_Allowed_YN, Rework_Process_CD, Use_YN, Description, Created_By, Created_DT)
            VALUES (@P_Route_ID, @P_Process_CD, @P_Process_NM, @P_Sequence_NO, @P_Required_YN, @P_Inspection_YN, @P_PreProcess_CD, @P_Line_NO, @P_STD_Cycle_Time, @P_Rework_Allowed_YN, @P_Rework_Process_CD, @P_Use_YN, @P_Description, @P_User_ID, SYSUTCDATETIME());

        SELECT 'OK' AS Result_CD, N'라우팅 공정 순서가 저장되었습니다.' AS Result_Msg;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- 라우팅 상세 삭제 (USP_DEL_ROUTE_DETAIL)
IF OBJECT_ID('dbo.USP_DEL_ROUTE_DETAIL', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_DEL_ROUTE_DETAIL;
GO
CREATE OR ALTER PROCEDURE dbo.USP_DEL_ROUTE_DETAIL
    @P_Route_ID     VARCHAR(20),
    @P_Sequence_NO  INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM dbo.TB_PROCESS_ROUTE_DETAIL
        WHERE  Route_ID = @P_Route_ID AND Sequence_NO = @P_Sequence_NO;

        SELECT 'OK' AS Result_CD, N'공정 순서가 삭제되었습니다.' AS Result_Msg;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- 작업자 등록/수정 (USP_SET_USER)
IF OBJECT_ID('dbo.USP_SET_WORKER', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_WORKER;
GO
CREATE PROCEDURE dbo.USP_SET_WORKER
    @P_Login_ID            VARCHAR(20),
    @P_Worker_ID           VARCHAR(20),
    @P_Worker_NM           VARCHAR(30),
    @P_User_PWD            VARCHAR(20),
    @P_Dept_CD             VARCHAR(30),
    @P_Position_CD         VARCHAR(30),
    @P_Permission_CD       VARCHAR(10),
    @P_Use_YN              CHAR(1),
    @P_Description         VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        MERGE INTO dbo.TB_WORKER WITH (HOLDLOCK) AS T
        USING (SELECT @P_Worker_ID AS User_ID) AS S
        ON (T.User_ID = S.User_ID)
        WHEN MATCHED THEN
            UPDATE SET 
                User_ID         = @P_Worker_ID,
                User_NM         = @P_Worker_NM,
                User_PWD        = @P_User_PWD,
                Dept_CD         = @P_Dept_CD,
                Position_CD     = @P_Position_CD,
                Permission_CD   = @P_Permission_CD,
                Description     = @P_Description,
                Use_YN          = @P_Use_YN,
                Modified_By     = @P_Login_ID,
                Modified_DT     = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (User_ID, User_NM, User_PWD, Dept_CD, Position_CD, Permission_CD, Description, Use_YN, Created_By, Created_DT)
            VALUES (@P_Worker_ID, @P_Worker_NM, @P_User_PWD, @P_Dept_CD, @P_Position_CD, @P_Permission_CD, @P_Description, @P_Use_YN, @P_Login_ID, SYSUTCDATETIME());
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 작업자 조회 (USP_GET_WORKER)
IF OBJECT_ID('dbo.USP_GET_WORKER', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_GET_WORKER;
GO
CREATE PROCEDURE dbo.USP_GET_WORKER
    @P_Worker_ID           VARCHAR(20),
    @P_Worker_NM           VARCHAR(30),
    @P_Dept_CD             VARCHAR(30),
    @P_Position_CD         VARCHAR(30),
    @P_Permission_CD       VARCHAR(10),
    @P_Use_YN              CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT User_ID, User_NM, User_PWD, Dept_CD, Position_CD, Permission_CD, Use_YN, Description
          FROM dbo.TB_WORKER
         WHERE (User_ID = @P_Worker_ID OR @P_Worker_ID IS NULL)
           AND (User_NM LIKE CONCAT(N'%', @P_Worker_NM, N'%') OR @P_Worker_NM IS NULL)
           AND (Dept_CD = @P_Dept_CD OR @P_Dept_CD IS NULL)
           AND (Position_CD = @P_Position_CD OR @P_Position_CD IS NULL)
           AND (Permission_CD = @P_Permission_CD OR @P_Permission_CD IS NULL)
           AND (Use_YN = @P_Use_YN OR @P_Use_YN IS NULL)
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 로그인 이력 등록 (USP_SET_LOGIN_HISTORY)
IF OBJECT_ID('dbo.USP_SET_LOGIN_HISTORY', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_LOGIN_HISTORY;
GO
CREATE PROCEDURE dbo.USP_SET_LOGIN_HISTORY
    @P_Login_ID         VARCHAR(20),
    @P_Client_IP        VARCHAR(45),
    @P_QR_YN            CHAR(1),
    @P_Description      VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO dbo.TB_LOGIN_HISTORY (Login_ID, Client_IP, QR_YN, Description, Created_By, Created_DT)
        VALUES (@P_Login_ID, @P_Client_IP, @P_QR_YN, @P_Description, 'SYSTEM', SYSUTCDATETIME());
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 로그인 이력 조회 (USP_GET_LOGIN_HISTORY)
IF OBJECT_ID('dbo.USP_GET_LOGIN_HISTORY', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_GET_LOGIN_HISTORY;
GO
CREATE PROCEDURE dbo.USP_GET_LOGIN_HISTORY
    @P_Login_ID         VARCHAR(20),
    @P_QR_YN            CHAR(1),
    @P_Login_DT         DATETIME2(0)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Login_ID, Client_IP, QR_YN, Description, Created_DT
          FROM dbo.TB_LOGIN_HISTORY
         WHERE (Login_ID = @P_Login_ID OR @P_Login_ID IS NULL)
           AND (QR_YN = @P_QR_YN OR @P_QR_YN IS NULL)
           AND ((Created_DT >= @P_Login_DT AND Created_DT < DATEADD(DAY, 1, @P_Login_DT)) OR @P_Login_DT IS NULL)
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 로그인 (USP_WORKER_LOGIN)
IF OBJECT_ID('dbo.USP_WORKER_LOGIN', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_WORKER_LOGIN;
GO
CREATE PROCEDURE dbo.USP_WORKER_LOGIN
    @P_Login_ID   VARCHAR(20),
    @P_Password   VARCHAR(20),
    @P_Client_IP  VARCHAR(45),
    @P_QR_YN      CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @User_ID VARCHAR(20) = NULL;

        IF @P_QR_YN IS NULL OR @P_QR_YN NOT IN ('Y', 'N')
            THROW 50001, '올바르지 않은 로그인 방식입니다.', 1;

        IF @P_QR_YN = 'Y'
            THROW 50002, 'QR 로그인 기능은 아직 사용할 수 없습니다.', 1;
            --SELECT @@User_ID = User_ID
            --FROM dbo.TB_WORKER
            --WHERE User_ID = @P_Login_ID
            --  AND Use_YN = 'Y';
        ELSE
        BEGIN
            SELECT @User_ID = User_ID
            FROM dbo.TB_WORKER
            WHERE User_ID = @P_Login_ID 
              AND User_PWD = @P_Password
              AND Use_YN = 'Y'
        END

        IF @User_ID IS NULL
        BEGIN
            RETURN;
        END
        
        --INSERT INTO dbo.TB_LOGIN_HISTORY (Login_ID, Client_IP, QR_YN)
        --VALUES (@P_Login_ID, @P_Client_IP, @P_QR_YN);
        EXEC dbo.USP_SET_LOGIN_HISTORY
            @P_Login_ID     = @User_ID,
            @P_Client_IP    = @P_Client_IP,
            @P_QR_YN        = @P_QR_YN;

        SELECT  User_ID, User_NM, Position_CD, Permission_CD, @P_Client_IP AS Client_IP
        FROM    dbo.TB_WORKER
        WHERE   User_ID = @User_ID AND Use_YN = 'Y';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 다국어 (USP_GET_LANG_DICT)
IF OBJECT_ID('dbo.USP_GET_LANG_DICT', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_GET_LANG_DICT;
GO
CREATE PROCEDURE dbo.USP_GET_LANG_DICT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT  Msg_ID, Category, Text_KO, Text_EN, Text_VI, Text_ETC
        FROM    dbo.TB_LANG_DICT
        WHERE   Use_YN = 'Y';
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- ============================================================================
-- 설비 검사 데이터(설비 인터페이스) 수신 전용 프로시저
-- ============================================================================

-- 공정 검사 사전 상태체크 (USP_CHECK_PROCESS)
IF OBJECT_ID('dbo.USP_CHECK_PROCESS', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_CHECK_PROCESS;
GO
CREATE PROCEDURE dbo.USP_CHECK_PROCESS
    @JsonInput NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF ISJSON(@JsonInput) = 0
            THROW 54001, N'잘못된 JSON 형식입니다.', 1;

        DECLARE @P_User_ID    VARCHAR(20) = JSON_VALUE(@JsonInput, '$.User_ID');
        DECLARE @P_Product_ID VARCHAR(20) = JSON_VALUE(@JsonInput, '$.Product_ID');
        DECLARE @P_Process_CD VARCHAR(30) = JSON_VALUE(@JsonInput, '$.Process_CD');

        DECLARE @Cur_Proc_ID    VARCHAR(30),
                @Cur_State      VARCHAR(10),
                @Cur_Result_CD  VARCHAR(10),
                @Cur_Error_CD  VARCHAR(10),
                @WO_NO          VARCHAR(20),
                @Lot_NO         VARCHAR(20);

        SELECT  @Cur_Proc_ID   = Process_ID,
                @Cur_State     = Process_State,
                @Cur_Result_CD = Result_CD,
                @Cur_Error_CD  = Error_CD,
                @WO_NO         = WO_NO,
                @Lot_NO        = Lot_NO
        FROM    dbo.TB_PRODUCT_MASTER
        WHERE   Product_ID = @P_Product_ID AND Use_YN = 'Y';

        -- 1) 첫 공정 신규 투입 제품인 경우 (아직 TB_PRODUCT_MASTER에 없는 경우)
        IF @Cur_Proc_ID IS NULL
        BEGIN
            SELECT  'OK' AS RESULT,
                    @P_Product_ID AS Product_ID,
                    @P_Process_CD AS Process_CD,
                    N'신규 투입 가능' AS MESSAGE;
            RETURN;
        END

        -- 2) 이전 공정 불량(NG) 제품 인터락 차단
        IF @Cur_Result_CD = 'NG'
        BEGIN
            SELECT  'NG' AS RESULT,
                    @P_Product_ID AS Product_ID,
                    @Cur_Error_CD AS ECODE,
                    @Cur_Proc_ID AS Process_CD,
                    N'이전 공정 불량(NG) 판정 제품입니다.' AS MESSAGE;
            RETURN;
        END

        -- 3) 정상 진행 가능 응답 반환
        SELECT  'OK' AS RESULT,
                ISNULL(@Cur_State, 'READY') AS Status,
                @P_Product_ID AS Product_ID,
                @WO_NO AS WO_NO,
                @Lot_NO AS Lot_NO,
                @Cur_Proc_ID AS Current_Process_CD,
                N'공정 작업 가능(OK)' AS MESSAGE;
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 저항 검사 수신 (USP_SET_RESISTANCE_TEST)
IF OBJECT_ID('dbo.USP_SET_RESISTANCE_TEST', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_RESISTANCE_TEST;
GO
CREATE PROCEDURE dbo.USP_SET_RESISTANCE_TEST
    @P_Worker_ID        VARCHAR(10),
    @P_Inspection_ID    VARCHAR(20),
    @P_Product_ID       VARCHAR(20),
    @P_Process_ID       VARCHAR(30),
    @P_Stator_Barcode   VARCHAR(30),
    @P_Resistance       VARCHAR(10),
    @P_NCount           VARCHAR(10) = '1',
    @P_Start_DT         VARCHAR(10),
    @P_End_DT           VARCHAR(10) = NULL,
    @P_PCheck           VARCHAR(5)  = NULL,
    @P_Result_CD        VARCHAR(5)  = NULL,
    @P_Error_CD         VARCHAR(5)  = NULL,
    @P_Use_YN           CHAR(1)     = 'Y',
    @P_User_ID          VARCHAR(10) = 'SYSTEM'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        -- 1) 검사 테이블 저장
        MERGE INTO dbo.TB_RESISTANCE_TEST WITH (HOLDLOCK) AS T
        USING (SELECT @P_Inspection_ID AS Inspection_ID) AS S
        ON (T.Inspection_ID = S.Inspection_ID)
        WHEN MATCHED THEN
            UPDATE SET 
                Inspection_ID   = @P_Inspection_ID,
                Product_ID      = @P_Product_ID,
                Process_ID      = @P_Process_ID,
                Resistance      = @P_Resistance,
                NCount          = @P_NCount,
                Start_DT        = @P_Start_DT,
                End_DT          = @P_End_DT,
                PCheck          = @P_PCheck,
                Result_CD       = @P_Result_CD,
                Error_CD        = @P_Error_CD,
                Use_YN          = @P_Use_YN,
                Created_By      = @P_Worker_ID,
                Modified_By     = @P_User_ID,
                Modified_DT     = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (Inspection_ID, Product_ID, Process_ID, Resistance, NCount, Start_DT, End_DT, PCheck, Result_CD, Error_CD, Use_YN, Created_By, Created_DT)
            VALUES (@P_Inspection_ID, @P_Product_ID, @P_Process_ID, @P_Resistance, @P_NCount, @P_Start_DT, @P_End_DT, @P_PCheck, @P_Result_CD, @P_Error_CD, @P_Use_YN, @P_Worker_ID, SYSUTCDATETIME());

        -- 2) 제품 마스터 업데이트 (Stator Barcode 및 공정 진행 정보)
        DECLARE @JsonInput NVARCHAR(MAX);
        SET @JsonInput = (
            SELECT 
                @P_Inspection_ID AS Inspection_ID,
                @P_Product_ID AS Product_ID,
                @P_Process_ID AS Process_ID,
                @P_Resistance AS Resistance,
                @P_Stator_Barcode AS Stator_Barcode
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );
        --PRINT (SELECT @JsonInput AS GeneratedJson);

        EXEC dbo.USP_SET_PRODUCT_MASTER @JsonInput = @JsonInput;
            --@P_Product_ID     = @P_Product_ID,
            --@P_Process_ID     = @P_Process_ID,
            --@P_Inspection_ID  = @P_Inspection_ID,
            --@P_Result_CD      = @P_Result_CD,
            --@P_Error_CD       = @P_Error_CD,
            --@P_Stator_Barcode = @P_Stator_Barcode,
            --@P_User_ID        = @P_User_ID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 저항 검사 조회 (USP_GET_RESISTANCE_TEST)
IF OBJECT_ID('dbo.USP_GET_RESISTANCE_TEST', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_GET_RESISTANCE_TEST;
GO
CREATE PROCEDURE dbo.USP_GET_RESISTANCE_TEST
    @P_Product_ID       VARCHAR(20),
    @P_Inspection_ID    VARCHAR(20) = NULL,
    @P_WO_NO            VARCHAR(20) = NULL,     -- PRODUCT_MASTER 에 존재
    @P_Lot_NO           VARCHAR(10) = NULL,     -- PRODUCT_MASTER 에 존재
    @P_Stator_Barcode   VARCHAR(30) = NULL,     -- PRODUCT_MASTER 에 존재
    @P_PCB_Barcode      VARCHAR(30) = NULL,     -- PRODUCT_MASTER 에 존재
    @P_Product_Label    VARCHAR(30) = NULL,     -- PRODUCT_MASTER 에 존재
    @P_Housing_SN       VARCHAR(30) = NULL,     -- PRODUCT_MASTER 에 존재
    @P_Impeller_SN      VARCHAR(30) = NULL,     -- PRODUCT_MASTER 에 존재
    @P_Start_DT         VARCHAR(10) = NULL,
    @P_End_DT           VARCHAR(10) = NULL,
    @P_Worker_ID        VARCHAR(10) = NULL,
    @P_Result_CD        VARCHAR(5)  = NULL,
    @P_Error_CD         VARCHAR(5)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT PM.Inspection_ID, PM.Product_ID, PM.Stator_Barcode, PM.PCB_Barcode, PM.Product_Label, PM.Housing_SN, PM.Impeller_SN, PM.Process_State,
               RT.Process_ID, RT.Resistance, RT.Start_DT, RT.End_DT, RT.PCheck, RT.Result_CD, RT.Error_CD, RT.Use_YN,
               (SELECT COUNT(a.Product_ID) FROM dbo.TB_RESISTANCE_TEST a WHERE RT.Product_ID = PM.Product_ID) AS NCount
          FROM dbo.TB_PRODUCT_MASTER PM
         INNER JOIN dbo.TB_RESISTANCE_TEST RT ON PM.PRODUCT_ID = RT.PRODUCT_ID
         WHERE (PM.PRODUCT_ID = @P_Product_ID OR @P_Product_ID IS NULL)
           AND (PM.INSPECTION_ID = @P_Inspection_ID OR @P_Inspection_ID IS NULL)
           AND (PM.WO_NO = @P_WO_NO OR @P_WO_NO IS NULL)
           AND (PM.LOT_NO = @P_Lot_NO OR @P_Lot_NO IS NULL)
           AND (PM.STATOR_BARCODE = @P_Stator_Barcode OR @P_Stator_Barcode IS NULL)
           AND (PM.PCB_BARCODE = @P_PCB_Barcode OR @P_PCB_Barcode IS NULL)
           AND (PM.PRODUCT_LABEL = @P_Product_Label OR @P_Product_Label IS NULL)
           AND (PM.HOUSING_SN = @P_Housing_SN OR @P_Housing_SN IS NULL)
           AND (PM.IMPELLER_SN = @P_Impeller_SN OR @P_Impeller_SN IS NULL)
           AND (RT.Start_DT >= @P_Start_DT OR @P_Start_DT IS NULL)
           AND (RT.Start_DT < DATEADD(DAY, 1, @P_End_DT) OR @P_End_DT IS NULL)
           AND (RT.Created_By = @P_Worker_ID OR @P_Worker_ID IS NULL)
           AND (RT.RESULT_CD = @P_Result_CD OR @P_Result_CD IS NULL)
           AND (RT.ERROR_CD = @P_Error_CD OR @P_Error_CD IS NULL);
    END TRY
    BEGIN CATCH
        EXEC USP_GetError;
        THROW;
    END CATCH
END;
GO

-- 오일 주입 수신 (USP_SET_OIL_INJECTION)
--IF OBJECT_ID('dbo.USP_SET_OIL_INJECTION', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_OIL_INJECTION;
--GO
--CREATE PROCEDURE dbo.USP_SET_OIL_INJECTION
--    @P_Inspection_ID    VARCHAR(20),
--    @P_Product_ID       VARCHAR(20),
--    @P_Process_ID       VARCHAR(30),
--    @P_Equipment_ID     VARCHAR(10),
--    @P_Worker_ID        VARCHAR(10),
--    @P_Oil_Weight       VARCHAR(10),
--    @P_Bearing_Hight    VARCHAR(10),
--    @P_Oil_Cap_Hight    VARCHAR(10),
--    @P_NCount           VARCHAR(10) = '1',
--    @P_Start_DT         VARCHAR(10),
--    @P_End_DT           VARCHAR(10) = NULL,
--    @P_PCheck           VARCHAR(5)  = NULL,
--    @P_Result_CD        VARCHAR(5)  = NULL,
--    @P_Error_CD         VARCHAR(5)  = NULL,
--    @P_Use_YN           CHAR(1)     = 'Y',
--    @P_User_ID          VARCHAR(10) = 'SYSTEM'
--AS
--BEGIN
--    SET NOCOUNT ON;
--    BEGIN TRANSACTION;
--    BEGIN TRY
--        MERGE INTO dbo.TB_OIL_INJECTION WITH (HOLDLOCK) AS T
--        USING (SELECT @P_Inspection_ID AS Inspection_ID) AS S
--        ON (T.Inspection_ID = S.Inspection_ID)
--        WHEN MATCHED THEN
--            UPDATE SET 
--                Product_ID      = @P_Product_ID,
--                WO_NO           = @P_WO_NO,
--                Lot_NO          = @P_Lot_NO,
--                Process_ID      = @P_Process_ID,
--                Equipment_ID    = @P_Equipment_ID,
--                Worker_ID       = @P_Worker_ID,
--                Oil_Weight      = @P_Oil_Weight,
--                Bearing_Hight   = @P_Bearing_Hight,
--                Oil_Cap_Hight   = @P_Oil_Cap_Hight,
--                NCount          = @P_NCount,
--                Start_DT        = @P_Start_DT,
--                End_DT          = @P_End_DT,
--                PCheck          = @P_PCheck,
--                Result_CD       = @P_Result_CD,
--                Error_CD        = @P_Error_CD,
--                Use_YN          = @P_Use_YN,
--                Modified_By     = @P_User_ID,
--                Modified_DT     = SYSUTCDATETIME()
--        WHEN NOT MATCHED THEN
--            INSERT (Inspection_ID, Product_ID, Process_ID, Equipment_ID, Worker_ID, Oil_Weight, Bearing_Hight, Oil_Cap_Hight, NCount, Start_DT, End_DT, PCheck, Result_CD, Error_CD, Use_YN, Created_By, Created_DT)
--            VALUES (@P_Inspection_ID, @P_Product_ID, @P_Process_ID, @P_Equipment_ID, @P_Worker_ID, @P_Oil_Weight, @P_Bearing_Hight, @P_Oil_Cap_Hight, @P_NCount, @P_Start_DT, @P_End_DT, @P_PCheck, @P_Result_CD, @P_Error_CD, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());

--        EXEC dbo.USP_SET_PRODUCT_MASTER
--            @P_Product_ID    = @P_Product_ID,
--            @P_WO_NO         = @P_WO_NO,
--            @P_Lot_NO        = @P_Lot_NO,
--            @P_Process_ID    = @P_Process_ID,
--            @P_Inspection_ID = @P_Inspection_ID,
--            @P_NCount        = @P_NCount,
--            @P_Result_CD     = @P_Result_CD,
--            @P_Error_CD      = @P_Error_CD,
--            @P_User_ID       = @P_User_ID;

--        COMMIT TRANSACTION;
--    END TRY
--    BEGIN CATCH
--        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
--        THROW;
--    END CATCH
--END;
--GO

---- 열 융착 수신 (USP_SET_THERMAL_STICKING)
--IF OBJECT_ID('dbo.USP_SET_THERMAL_STICKING', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_THERMAL_STICKING;
--GO
--CREATE PROCEDURE dbo.USP_SET_THERMAL_STICKING
--    @P_Inspection_ID    VARCHAR(20),
--    @P_Product_ID       VARCHAR(20),
--    @P_WO_NO            VARCHAR(20),
--    @P_Lot_NO           VARCHAR(10),
--    @P_Process_ID       VARCHAR(30),
--    @P_Equipment_ID     VARCHAR(10),
--    @P_Worker_ID        VARCHAR(10),
--    @P_PCB_Barcode      VARCHAR(30),
--    @P_Welding_Time     VARCHAR(10),
--    @P_Welding_TEMP     VARCHAR(10),
--    @P_NCount           VARCHAR(10) = '1',
--    @P_Start_DT         VARCHAR(10),
--    @P_End_DT           VARCHAR(10) = NULL,
--    @P_PCheck           VARCHAR(5)  = NULL,
--    @P_Result_CD        VARCHAR(5)  = NULL,
--    @P_Error_CD         VARCHAR(5)  = NULL,
--    @P_Use_YN           CHAR(1)     = 'Y',
--    @P_User_ID          VARCHAR(10) = 'SYSTEM'
--AS
--BEGIN
--    SET NOCOUNT ON;
--    BEGIN TRANSACTION;
--    BEGIN TRY
--        MERGE INTO dbo.TB_THERMAL_STICKING WITH (HOLDLOCK) AS T
--        USING (SELECT @P_Inspection_ID AS Inspection_ID) AS S
--        ON (T.Inspection_ID = S.Inspection_ID)
--        WHEN MATCHED THEN
--            UPDATE SET 
--                Product_ID      = @P_Product_ID,
--                WO_NO           = @P_WO_NO,
--                Lot_NO          = @P_Lot_NO,
--                Process_ID      = @P_Process_ID,
--                Equipment_ID    = @P_Equipment_ID,
--                Worker_ID       = @P_Worker_ID,
--                PCB_Barcode     = @P_PCB_Barcode,
--                Welding_Time    = @P_Welding_Time,
--                Welding_TEMP    = @P_Welding_TEMP,
--                NCount          = @P_NCount,
--                Start_DT        = @P_Start_DT,
--                End_DT          = @P_End_DT,
--                PCheck          = @P_PCheck,
--                Result_CD       = @P_Result_CD,
--                Error_CD        = @P_Error_CD,
--                Use_YN          = @P_Use_YN,
--                Modified_By     = @P_User_ID,
--                Modified_DT     = SYSUTCDATETIME()
--        WHEN NOT MATCHED THEN
--            INSERT (Inspection_ID, Product_ID, WO_NO, Lot_NO, Process_ID, Equipment_ID, Worker_ID, PCB_Barcode, Welding_Time, Welding_TEMP, NCount, Start_DT, End_DT, PCheck, Result_CD, Error_CD, Use_YN, Created_By, Created_DT)
--            VALUES (@P_Inspection_ID, @P_Product_ID, @P_WO_NO, @P_Lot_NO, @P_Process_ID, @P_Equipment_ID, @P_Worker_ID, @P_PCB_Barcode, @P_Welding_Time, @P_Welding_TEMP, @P_NCount, @P_Start_DT, @P_End_DT, @P_PCheck, @P_Result_CD, @P_Error_CD, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());

--        EXEC dbo.USP_SET_PRODUCT_MASTER
--            @P_Product_ID    = @P_Product_ID,
--            @P_WO_NO         = @P_WO_NO,
--            @P_Lot_NO        = @P_Lot_NO,
--            @P_Process_ID    = @P_Process_ID,
--            @P_Equipment_ID  = @P_Equipment_ID,
--            @P_Worker_ID     = @P_Worker_ID,
--            @P_Inspection_ID = @P_Inspection_ID,
--            @P_NCount        = @P_NCount,
--            @P_Start_DT      = @P_Start_DT,
--            @P_End_DT        = @P_End_DT,
--            @P_Result_CD     = @P_Result_CD,
--            @P_Error_CD      = @P_Error_CD,
--            @P_PCB_Barcode   = @P_PCB_Barcode,
--            @P_User_ID       = @P_User_ID;

--        COMMIT TRANSACTION;
--    END TRY
--    BEGIN CATCH
--        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
--        THROW;
--    END CATCH
--END;
--GO

---- 코일 납땜 수신 (USP_SET_COIL_SOLDERING)
--IF OBJECT_ID('dbo.USP_SET_COIL_SOLDERING', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_COIL_SOLDERING;
--GO
--CREATE PROCEDURE dbo.USP_SET_COIL_SOLDERING
--    @P_Inspection_ID    VARCHAR(20),
--    @P_Product_ID       VARCHAR(20),
--    @P_WO_NO            VARCHAR(20),
--    @P_Lot_NO           VARCHAR(10),
--    @P_Process_ID       VARCHAR(30),
--    @P_Equipment_ID     VARCHAR(10),
--    @P_Worker_ID        VARCHAR(10),
--    @P_Soldering        VARCHAR(10),
--    @P_NCount           VARCHAR(10) = '1',
--    @P_Start_DT         VARCHAR(10),
--    @P_End_DT           VARCHAR(10) = NULL,
--    @P_PCheck           VARCHAR(5)  = NULL,
--    @P_Result_CD        VARCHAR(5)  = NULL,
--    @P_Error_CD         VARCHAR(5)  = NULL,
--    @P_Use_YN           CHAR(1)     = 'Y',
--    @P_User_ID          VARCHAR(10) = 'SYSTEM'
--AS
--BEGIN
--    SET NOCOUNT ON;
--    BEGIN TRANSACTION;
--    BEGIN TRY
--        MERGE INTO dbo.TB_COIL_SOLDERING WITH (HOLDLOCK) AS T
--        USING (SELECT @P_Inspection_ID AS Inspection_ID) AS S
--        ON (T.Inspection_ID = S.Inspection_ID)
--        WHEN MATCHED THEN
--            UPDATE SET 
--                Product_ID      = @P_Product_ID,
--                WO_NO           = @P_WO_NO,
--                Lot_NO          = @P_Lot_NO,
--                Process_ID      = @P_Process_ID,
--                Equipment_ID    = @P_Equipment_ID,
--                Worker_ID       = @P_Worker_ID,
--                Soldering       = @P_Soldering,
--                NCount          = @P_NCount,
--                Start_DT        = @P_Start_DT,
--                End_DT          = @P_End_DT,
--                PCheck          = @P_PCheck,
--                Result_CD       = @P_Result_CD,
--                Error_CD        = @P_Error_CD,
--                Use_YN          = @P_Use_YN,
--                Modified_By     = @P_User_ID,
--                Modified_DT     = SYSUTCDATETIME()
--        WHEN NOT MATCHED THEN
--            INSERT (Inspection_ID, Product_ID, WO_NO, Lot_NO, Process_ID, Equipment_ID, Worker_ID, Soldering, NCount, Start_DT, End_DT, PCheck, Result_CD, Error_CD, Use_YN, Created_By, Created_DT)
--            VALUES (@P_Inspection_ID, @P_Product_ID, @P_WO_NO, @P_Lot_NO, @P_Process_ID, @P_Equipment_ID, @P_Worker_ID, @P_Soldering, @P_NCount, @P_Start_DT, @P_End_DT, @P_PCheck, @P_Result_CD, @P_Error_CD, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());

--        EXEC dbo.USP_SET_PRODUCT_MASTER
--            @P_Product_ID    = @P_Product_ID,
--            @P_WO_NO         = @P_WO_NO,
--            @P_Lot_NO        = @P_Lot_NO,
--            @P_Process_ID    = @P_Process_ID,
--            @P_Inspection_ID = @P_Inspection_ID,
--            @P_NCount        = @P_NCount,
--            @P_Result_CD     = @P_Result_CD,
--            @P_Error_CD      = @P_Error_CD,
--            @P_User_ID       = @P_User_ID;

--        COMMIT TRANSACTION;
--    END TRY
--    BEGIN CATCH
--        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
--        THROW;
--    END CATCH
--END;
--GO

---- 납땜 AOI 수신 (USP_SET_SOLDER_AOI)
--IF OBJECT_ID('dbo.USP_SET_SOLDER_AOI', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_SOLDER_AOI;
--GO
--CREATE PROCEDURE dbo.USP_SET_SOLDER_AOI
--    @P_Inspection_ID    VARCHAR(20),
--    @P_Product_ID       VARCHAR(20),
--    @P_WO_NO            VARCHAR(20),
--    @P_Lot_NO           VARCHAR(10),
--    @P_Process_ID       VARCHAR(30),
--    @P_Equipment_ID     VARCHAR(10),
--    @P_Worker_ID        VARCHAR(10),
--    @P_Housing_SN       VARCHAR(30),
--    @P_Soldering        VARCHAR(10),
--    @P_NCount           VARCHAR(10) = '1',
--    @P_Start_DT         VARCHAR(10),
--    @P_End_DT           VARCHAR(10) = NULL,
--    @P_PCheck           VARCHAR(5)  = NULL,
--    @P_Result_CD        VARCHAR(5)  = NULL,
--    @P_Error_CD         VARCHAR(5)  = NULL,
--    @P_Use_YN           CHAR(1)     = 'Y',
--    @P_User_ID          VARCHAR(10) = 'SYSTEM'
--AS
--BEGIN
--    SET NOCOUNT ON;
--    BEGIN TRANSACTION;
--    BEGIN TRY
--        MERGE INTO dbo.TB_SOLDER_AOI WITH (HOLDLOCK) AS T
--        USING (SELECT @P_Inspection_ID AS Inspection_ID) AS S
--        ON (T.Inspection_ID = S.Inspection_ID)
--        WHEN MATCHED THEN
--            UPDATE SET 
--                Product_ID      = @P_Product_ID,
--                WO_NO           = @P_WO_NO,
--                Lot_NO          = @P_Lot_NO,
--                Process_ID      = @P_Process_ID,
--                Equipment_ID    = @P_Equipment_ID,
--                Worker_ID       = @P_Worker_ID,
--                Housing_SN      = @P_Housing_SN,
--                Soldering       = @P_Soldering,
--                NCount          = @P_NCount,
--                Start_DT        = @P_Start_DT,
--                End_DT          = @P_End_DT,
--                PCheck          = @P_PCheck,
--                Result_CD       = @P_Result_CD,
--                Error_CD        = @P_Error_CD,
--                Use_YN          = @P_Use_YN,
--                Modified_By     = @P_User_ID,
--                Modified_DT     = SYSUTCDATETIME()
--        WHEN NOT MATCHED THEN
--            INSERT (Inspection_ID, Product_ID, WO_NO, Lot_NO, Process_ID, Equipment_ID, Worker_ID, Housing_SN, Soldering, NCount, Start_DT, End_DT, PCheck, Result_CD, Error_CD, Use_YN, Created_By, Created_DT)
--            VALUES (@P_Inspection_ID, @P_Product_ID, @P_WO_NO, @P_Lot_NO, @P_Process_ID, @P_Equipment_ID, @P_Worker_ID, @P_Housing_SN, @P_Soldering, @P_NCount, @P_Start_DT, @P_End_DT, @P_PCheck, @P_Result_CD, @P_Error_CD, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());

--        EXEC dbo.USP_SET_PRODUCT_MASTER
--            @P_Product_ID    = @P_Product_ID,
--            @P_WO_NO         = @P_WO_NO,
--            @P_Lot_NO        = @P_Lot_NO,
--            @P_Process_ID    = @P_Process_ID,
--            @P_Inspection_ID = @P_Inspection_ID,
--            @P_NCount        = @P_NCount,
--            @P_Result_CD     = @P_Result_CD,
--            @P_Error_CD      = @P_Error_CD,
--            @P_Housing_SN    = @P_Housing_SN,
--            @P_User_ID       = @P_User_ID;

--        COMMIT TRANSACTION;
--    END TRY
--    BEGIN CATCH
--        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
--        THROW;
--    END CATCH
--END;
--GO

---- 몰드 납땜 수신 (USP_SET_MOLD_SOLDERING)
--IF OBJECT_ID('dbo.USP_SET_MOLD_SOLDERING', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_MOLD_SOLDERING;
--GO
--CREATE PROCEDURE dbo.USP_SET_MOLD_SOLDERING
--    @P_Inspection_ID    VARCHAR(20),
--    @P_Product_ID       VARCHAR(20),
--    @P_WO_NO            VARCHAR(20),
--    @P_Lot_NO           VARCHAR(10),
--    @P_Process_ID       VARCHAR(30),
--    @P_Equipment_ID     VARCHAR(10),
--    @P_Worker_ID        VARCHAR(10),
--    @P_PCB_Barcode      VARCHAR(30),
--    @P_Soldering        VARCHAR(10),
--    @P_NCount           VARCHAR(10) = '1',
--    @P_Start_DT         VARCHAR(10),
--    @P_End_DT           VARCHAR(10) = NULL,
--    @P_PCheck           VARCHAR(5)  = NULL,
--    @P_Result_CD        VARCHAR(5)  = NULL,
--    @P_Error_CD         VARCHAR(5)  = NULL,
--    @P_Use_YN           CHAR(1)     = 'Y',
--    @P_User_ID          VARCHAR(10) = 'SYSTEM'
--AS
--BEGIN
--    SET NOCOUNT ON;
--    BEGIN TRANSACTION;
--    BEGIN TRY
--        MERGE INTO dbo.TB_MOLD_SOLDERING WITH (HOLDLOCK) AS T
--        USING (SELECT @P_Inspection_ID AS Inspection_ID) AS S
--        ON (T.Inspection_ID = S.Inspection_ID)
--        WHEN MATCHED THEN
--            UPDATE SET 
--                Product_ID      = @P_Product_ID,
--                WO_NO           = @P_WO_NO,
--                Lot_NO          = @P_Lot_NO,
--                Process_ID      = @P_Process_ID,
--                Equipment_ID    = @P_Equipment_ID,
--                Worker_ID       = @P_Worker_ID,
--                PCB_Barcode     = @P_PCB_Barcode,
--                Soldering       = @P_Soldering,
--                NCount          = @P_NCount,
--                Start_DT        = @P_Start_DT,
--                End_DT          = @P_End_DT,
--                PCheck          = @P_PCheck,
--                Result_CD       = @P_Result_CD,
--                Error_CD        = @P_Error_CD,
--                Use_YN          = @P_Use_YN,
--                Modified_By     = @P_User_ID,
--                Modified_DT     = SYSUTCDATETIME()
--        WHEN NOT MATCHED THEN
--            INSERT (Inspection_ID, Product_ID, WO_NO, Lot_NO, Process_ID, Equipment_ID, Worker_ID, PCB_Barcode, Soldering, NCount, Start_DT, End_DT, PCheck, Result_CD, Error_CD, Use_YN, Created_By, Created_DT)
--            VALUES (@P_Inspection_ID, @P_Product_ID, @P_WO_NO, @P_Lot_NO, @P_Process_ID, @P_Equipment_ID, @P_Worker_ID, @P_PCB_Barcode, @P_Soldering, @P_NCount, @P_Start_DT, @P_End_DT, @P_PCheck, @P_Result_CD, @P_Error_CD, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());

--        EXEC dbo.USP_SET_PRODUCT_MASTER
--            @P_Product_ID    = @P_Product_ID,
--            @P_WO_NO         = @P_WO_NO,
--            @P_Lot_NO        = @P_Lot_NO,
--            @P_Process_ID    = @P_Process_ID,
--            @P_Inspection_ID = @P_Inspection_ID,
--            @P_NCount        = @P_NCount,
--            @P_Result_CD     = @P_Result_CD,
--            @P_Error_CD      = @P_Error_CD,
--            @P_PCB_Barcode   = @P_PCB_Barcode,
--            @P_User_ID       = @P_User_ID;

--        COMMIT TRANSACTION;
--    END TRY
--    BEGIN CATCH
--        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
--        THROW;
--    END CATCH
--END;
--GO

---- 밸런싱 수신 (USP_SET_BALANCING)
--IF OBJECT_ID('dbo.USP_SET_BALANCING', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_BALANCING;
--GO
--CREATE PROCEDURE dbo.USP_SET_BALANCING
--    @P_Inspection_ID    VARCHAR(20),
--    @P_Product_ID       VARCHAR(20),
--    @P_WO_NO            VARCHAR(20),
--    @P_Lot_NO           VARCHAR(10),
--    @P_Process_ID       VARCHAR(30),
--    @P_Equipment_ID     VARCHAR(10),
--    @P_Worker_ID        VARCHAR(10),
--    @P_Impeller_SN      VARCHAR(30),
--    @P_Balance_Amount   VARCHAR(10),
--    @P_NCount           VARCHAR(10) = '1',
--    @P_Start_DT         VARCHAR(10),
--    @P_End_DT           VARCHAR(10) = NULL,
--    @P_PCheck           VARCHAR(5)  = NULL,
--    @P_Result_CD        VARCHAR(5)  = NULL,
--    @P_Error_CD         VARCHAR(5)  = NULL,
--    @P_Use_YN           CHAR(1)     = 'Y',
--    @P_User_ID          VARCHAR(10) = 'SYSTEM'
--AS
--BEGIN
--    SET NOCOUNT ON;
--    BEGIN TRANSACTION;
--    BEGIN TRY
--        MERGE INTO dbo.TB_BALANCING WITH (HOLDLOCK) AS T
--        USING (SELECT @P_Inspection_ID AS Inspection_ID) AS S
--        ON (T.Inspection_ID = S.Inspection_ID)
--        WHEN MATCHED THEN
--            UPDATE SET 
--                Product_ID      = @P_Product_ID,
--                WO_NO           = @P_WO_NO,
--                Lot_NO          = @P_Lot_NO,
--                Process_ID      = @P_Process_ID,
--                Equipment_ID    = @P_Equipment_ID,
--                Worker_ID       = @P_Worker_ID,
--                Impeller_SN     = @P_Impeller_SN,
--                Balance_Amount  = @P_Balance_Amount,
--                NCount          = @P_NCount,
--                Start_DT        = @P_Start_DT,
--                End_DT          = @P_End_DT,
--                PCheck          = @P_PCheck,
--                Result_CD       = @P_Result_CD,
--                Error_CD        = @P_Error_CD,
--                Use_YN          = @P_Use_YN,
--                Modified_By     = @P_User_ID,
--                Modified_DT     = SYSUTCDATETIME()
--        WHEN NOT MATCHED THEN
--            INSERT (Inspection_ID, Product_ID, WO_NO, Lot_NO, Process_ID, Equipment_ID, Worker_ID, Impeller_SN, Balance_Amount, NCount, Start_DT, End_DT, PCheck, Result_CD, Error_CD, Use_YN, Created_By, Created_DT)
--            VALUES (@P_Inspection_ID, @P_Product_ID, @P_WO_NO, @P_Lot_NO, @P_Process_ID, @P_Equipment_ID, @P_Worker_ID, @P_Impeller_SN, @P_Balance_Amount, @P_NCount, @P_Start_DT, @P_End_DT, @P_PCheck, @P_Result_CD, @P_Error_CD, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());

--        EXEC dbo.USP_SET_PRODUCT_MASTER
--            @P_Product_ID    = @P_Product_ID,
--            @P_WO_NO         = @P_WO_NO,
--            @P_Lot_NO        = @P_Lot_NO,
--            @P_Process_ID    = @P_Process_ID,
--            @P_Inspection_ID = @P_Inspection_ID,
--            @P_NCount        = @P_NCount,
--            @P_Result_CD     = @P_Result_CD,
--            @P_Error_CD      = @P_Error_CD,
--            @P_Impeller_SN   = @P_Impeller_SN,
--            @P_User_ID       = @P_User_ID;

--        COMMIT TRANSACTION;
--    END TRY
--    BEGIN CATCH
--        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
--        THROW;
--    END CATCH
--END;
--GO

---- EOL 검사 수신 (USP_SET_EOL_TEST)
--IF OBJECT_ID('dbo.USP_SET_EOL_TEST', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_EOL_TEST;
--GO
--CREATE PROCEDURE dbo.USP_SET_EOL_TEST
--    @P_Inspection_ID    VARCHAR(20),
--    @P_Product_ID       VARCHAR(20),
--    @P_WO_NO            VARCHAR(20),
--    @P_Lot_NO           VARCHAR(10),
--    @P_Process_ID       VARCHAR(30),
--    @P_Equipment_ID     VARCHAR(10),
--    @P_Worker_ID        VARCHAR(10),
--    @P_Voltage          VARCHAR(10),
--    @P_Current          VARCHAR(10),
--    @P_RPM              VARCHAR(10),
--    @P_Thermistor_R     VARCHAR(10),
--    @P_NCount           VARCHAR(10) = '1',
--    @P_Start_DT         VARCHAR(10),
--    @P_End_DT           VARCHAR(10) = NULL,
--    @P_PCheck           VARCHAR(5)  = NULL,
--    @P_Result_CD        VARCHAR(5)  = NULL,
--    @P_Error_CD         VARCHAR(5)  = NULL,
--    @P_Use_YN           CHAR(1)     = 'Y',
--    @P_User_ID          VARCHAR(10) = 'SYSTEM'
--AS
--BEGIN
--    SET NOCOUNT ON;
--    BEGIN TRANSACTION;
--    BEGIN TRY
--        MERGE INTO dbo.TB_EOL_TEST WITH (HOLDLOCK) AS T
--        USING (SELECT @P_Inspection_ID AS Inspection_ID) AS S
--        ON (T.Inspection_ID = S.Inspection_ID)
--        WHEN MATCHED THEN
--            UPDATE SET 
--                Product_ID      = @P_Product_ID,
--                WO_NO           = @P_WO_NO,
--                Lot_NO          = @P_Lot_NO,
--                Process_ID      = @P_Process_ID,
--                Equipment_ID    = @P_Equipment_ID,
--                Worker_ID       = @P_Worker_ID,
--                Voltage         = @P_Voltage,
--                ＩCurrent       = @P_ICurrent,
--                RPM             = @P_RPM,
--                Thermistor_R    = @P_Thermistor_R,
--                NCount          = @P_NCount,
--                Start_DT        = @P_Start_DT,
--                End_DT          = @P_End_DT,
--                PCheck          = @P_PCheck,
--                Result_CD       = @P_Result_CD,
--                Error_CD        = @P_Error_CD,
--                Use_YN          = @P_Use_YN,
--                Modified_By     = @P_User_ID,
--                Modified_DT     = SYSUTCDATETIME()
--        WHEN NOT MATCHED THEN
--            INSERT (Inspection_ID, Product_ID, WO_NO, Lot_NO, Process_ID, Equipment_ID, Worker_ID, Voltage, [Current], RPM, Thermistor_R, NCount, Start_DT, End_DT, PCheck, Result_CD, Error_CD, Use_YN, Created_By, Created_DT)
--            VALUES (@P_Inspection_ID, @P_Product_ID, @P_WO_NO, @P_Lot_NO, @P_Process_ID, @P_Equipment_ID, @P_Worker_ID, @P_Voltage, @P_Current, @P_RPM, @P_Thermistor_R, @P_NCount, @P_Start_DT, @P_End_DT, @P_PCheck, @P_Result_CD, @P_Error_CD, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());

--        EXEC dbo.USP_SET_PRODUCT_MASTER
--            @P_Product_ID    = @P_Product_ID,
--            @P_WO_NO         = @P_WO_NO,
--            @P_Lot_NO        = @P_Lot_NO,
--            @P_Process_ID    = @P_Process_ID,
--            @P_Inspection_ID = @P_Inspection_ID,
--            @P_NCount        = @P_NCount,
--            @P_Result_CD     = @P_Result_CD,
--            @P_Error_CD      = @P_Error_CD,
--            @P_User_ID       = @P_User_ID;

--        COMMIT TRANSACTION;
--    END TRY
--    BEGIN CATCH
--        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
--        THROW;
--    END CATCH
--END;
--GO

---- NVH 검사 수신 (USP_SET_NVH_TEST)
--IF OBJECT_ID('dbo.USP_SET_NVH_TEST', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_NVH_TEST;
--GO
--CREATE PROCEDURE dbo.USP_SET_NVH_TEST
--    @P_Inspection_ID    VARCHAR(20),
--    @P_Product_ID       VARCHAR(20),
--    @P_WO_NO            VARCHAR(20),
--    @P_Lot_NO           VARCHAR(10),
--    @P_Process_ID       VARCHAR(30),
--    @P_Equipment_ID     VARCHAR(10),
--    @P_Worker_ID        VARCHAR(10),
--    @P_NCount           VARCHAR(10) = '1',
--    @P_Start_DT         VARCHAR(10),
--    @P_End_DT           VARCHAR(10) = NULL,
--    @P_PCheck           VARCHAR(5)  = NULL,
--    @P_Result_CD        VARCHAR(5)  = NULL,
--    @P_Error_CD         VARCHAR(5)  = NULL,
--    @P_Use_YN           CHAR(1)     = 'Y',
--    @P_User_ID          VARCHAR(10) = 'SYSTEM'
--AS
--BEGIN
--    SET NOCOUNT ON;
--    BEGIN TRANSACTION;
--    BEGIN TRY
--        MERGE INTO dbo.TB_NVH_TEST WITH (HOLDLOCK) AS T
--        USING (SELECT @P_Inspection_ID AS Inspection_ID) AS S
--        ON (T.Inspection_ID = S.Inspection_ID)
--        WHEN MATCHED THEN
--            UPDATE SET 
--                Product_ID      = @P_Product_ID,
--                WO_NO           = @P_WO_NO,
--                Lot_NO          = @P_Lot_NO,
--                Process_ID      = @P_Process_ID,
--                Equipment_ID    = @P_Equipment_ID,
--                Worker_ID       = @P_Worker_ID,
--                NCount          = @P_NCount,
--                Start_DT        = @P_Start_DT,
--                End_DT          = @P_End_DT,
--                PCheck          = @P_PCheck,
--                Result_CD       = @P_Result_CD,
--                Error_CD        = @P_Error_CD,
--                Use_YN          = @P_Use_YN,
--                Modified_By     = @P_User_ID,
--                Modified_DT     = SYSUTCDATETIME()
--        WHEN NOT MATCHED THEN
--            INSERT (Inspection_ID, Product_ID, WO_NO, Lot_NO, Process_ID, Equipment_ID, Worker_ID, NCount, Start_DT, End_DT, PCheck, Result_CD, Error_CD, Use_YN, Created_By, Created_DT)
--            VALUES (@P_Inspection_ID, @P_Product_ID, @P_WO_NO, @P_Lot_NO, @P_Process_ID, @P_Equipment_ID, @P_Worker_ID, @P_NCount, @P_Start_DT, @P_End_DT, @P_PCheck, @P_Result_CD, @P_Error_CD, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());

--        EXEC dbo.USP_SET_PRODUCT_MASTER
--            @P_Product_ID    = @P_Product_ID,
--            @P_WO_NO         = @P_WO_NO,
--            @P_Lot_NO        = @P_Lot_NO,
--            @P_Process_ID    = @P_Process_ID,
--            @P_Inspection_ID = @P_Inspection_ID,
--            @P_NCount        = @P_NCount,
--            @P_Result_CD     = @P_Result_CD,
--            @P_Error_CD      = @P_Error_CD,
--            @P_User_ID       = @P_User_ID;

--        COMMIT TRANSACTION;
--    END TRY
--    BEGIN CATCH
--        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
--        THROW;
--    END CATCH
--END;
--GO

---- 핀 휘어짐 검사 수신 (USP_SET_PIN_BENT_TEST)
--IF OBJECT_ID('dbo.USP_SET_PIN_BENT_TEST', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_PIN_BENT_TEST;
--GO
--CREATE PROCEDURE dbo.USP_SET_PIN_BENT_TEST
--    @P_Inspection_ID    VARCHAR(20),
--    @P_Product_ID       VARCHAR(20),
--    @P_WO_NO            VARCHAR(20),
--    @P_Lot_NO           VARCHAR(10),
--    @P_Process_ID       VARCHAR(30),
--    @P_Equipment_ID     VARCHAR(10),
--    @P_Worker_ID        VARCHAR(10),
--    @P_NCount           VARCHAR(10) = '1',
--    @P_Start_DT         VARCHAR(10),
--    @P_End_DT           VARCHAR(10) = NULL,
--    @P_PCheck           VARCHAR(5)  = NULL,
--    @P_Result_CD        VARCHAR(5)  = NULL,
--    @P_Error_CD         VARCHAR(5)  = NULL,
--    @P_Use_YN           CHAR(1)     = 'Y',
--    @P_User_ID          VARCHAR(10) = 'SYSTEM'
--AS
--BEGIN
--    SET NOCOUNT ON;
--    BEGIN TRANSACTION;
--    BEGIN TRY
--        MERGE INTO dbo.TB_PIN_BENT_TEST WITH (HOLDLOCK) AS T
--        USING (SELECT @P_Inspection_ID AS Inspection_ID) AS S
--        ON (T.Inspection_ID = S.Inspection_ID)
--        WHEN MATCHED THEN
--            UPDATE SET 
--                Product_ID      = @P_Product_ID,
--                Process_ID      = @P_Process_ID,
--                Equipment_ID    = @P_Equipment_ID,
--                Worker_ID       = @P_Worker_ID,
--                NCount          = @P_NCount,
--                Start_DT        = @P_Start_DT,
--                End_DT          = @P_End_DT,
--                PCheck          = @P_PCheck,
--                Result_CD       = @P_Result_CD,
--                Error_CD        = @P_Error_CD,
--                Use_YN          = @P_Use_YN,
--                Modified_By     = @P_User_ID,
--                Modified_DT     = SYSUTCDATETIME()
--        WHEN NOT MATCHED THEN
--            INSERT (Inspection_ID, Product_ID, Process_ID, Equipment_ID, Worker_ID, NCount, Start_DT, End_DT, PCheck, Result_CD, Error_CD, Use_YN, Created_By, Created_DT)
--            VALUES (@P_Inspection_ID, @P_Product_ID, @P_Process_ID, @P_Equipment_ID, @P_Worker_ID, @P_NCount, @P_Start_DT, @P_End_DT, @P_PCheck, @P_Result_CD, @P_Error_CD, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());

--        EXEC dbo.USP_SET_PRODUCT_MASTER
--            @P_Product_ID    = @P_Product_ID,
--            @P_WO_NO         = @P_WO_NO,
--            @P_Lot_NO        = @P_Lot_NO,
--            @P_Process_ID    = @P_Process_ID,
--            @P_Inspection_ID = @P_Inspection_ID,
--            @P_NCount        = @P_NCount,
--            @P_Result_CD     = @P_Result_CD,
--            @P_Error_CD      = @P_Error_CD,
--            @P_User_ID       = @P_User_ID;

--        COMMIT TRANSACTION;
--    END TRY
--    BEGIN CATCH
--        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
--        THROW;
--    END CATCH
--END;
--GO

---- 포장 수신 (USP_SET_PACKING)
--IF OBJECT_ID('dbo.USP_SET_PACKING', 'P') IS NOT NULL DROP PROCEDURE dbo.USP_SET_PACKING;
--GO
--CREATE PROCEDURE dbo.USP_SET_PACKING
--    @P_Worker_ID        VARCHAR(10),
--    @P_Inspection_ID    VARCHAR(20),
--    @P_Product_ID       VARCHAR(20),
--    @P_Process_ID       VARCHAR(30),
--    @P_Product_QTY      VARCHAR(10),
--    @P_Packing_Weight   VARCHAR(10),
--    @P_NCount           VARCHAR(10) = '1',
--    @P_Start_DT         VARCHAR(10),
--    @P_End_DT           VARCHAR(10) = NULL,
--    @P_PCheck           VARCHAR(5)  = NULL,
--    @P_Result_CD        VARCHAR(5)  = NULL,
--    @P_Error_CD         VARCHAR(5)  = NULL,
--    @P_Use_YN           CHAR(1)     = 'Y',
--    @P_User_ID          VARCHAR(10) = 'SYSTEM'
--AS
--BEGIN
--    SET NOCOUNT ON;
--    BEGIN TRANSACTION;
--    BEGIN TRY
--        MERGE INTO dbo.TB_PACKING WITH (HOLDLOCK) AS T
--        USING (SELECT @P_Inspection_ID AS Inspection_ID) AS S
--        ON (T.Inspection_ID = S.Inspection_ID)
--        WHEN MATCHED THEN
--            UPDATE SET 
--                Product_ID      = @P_Product_ID,
--                WO_NO           = @P_WO_NO,
--                Lot_NO          = @P_Lot_NO,
--                Process_ID      = @P_Process_ID,
--                Equipment_ID    = @P_Equipment_ID,
--                Worker_ID       = @P_Worker_ID,
--                Product_QTY     = @P_Product_QTY,
--                Packing_Weight  = @P_Packing_Weight,
--                NCount          = @P_NCount,
--                Start_DT        = @P_Start_DT,
--                End_DT          = @P_End_DT,
--                PCheck          = @P_PCheck,
--                Result_CD       = @P_Result_CD,
--                Error_CD        = @P_Error_CD,
--                Use_YN          = @P_Use_YN,
--                Modified_By     = @P_User_ID,
--                Modified_DT     = SYSUTCDATETIME()
--        WHEN NOT MATCHED THEN
--            INSERT (Inspection_ID, Product_ID, Process_ID, Equipment_ID, Worker_ID, Product_QTY, Packing_Weight, NCount, Start_DT, End_DT, PCheck, Result_CD, Error_CD, Use_YN, Created_By, Created_DT)
--            VALUES (@P_Inspection_ID, @P_Product_ID, @P_Process_ID, @P_Equipment_ID, @P_Worker_ID, @P_Product_QTY, @P_Packing_Weight, @P_NCount, @P_Start_DT, @P_End_DT, @P_PCheck, @P_Result_CD, @P_Error_CD, @P_Use_YN, @P_User_ID, SYSUTCDATETIME());

--        EXEC dbo.USP_SET_PRODUCT_MASTER
--            @P_Product_ID    = @P_Product_ID,
--            @P_Process_ID    = @P_Process_ID,
--            @P_Equipment_ID  = @P_Equipment_ID,
--            @P_Worker_ID     = @P_Worker_ID,
--            @P_Inspection_ID = @P_Inspection_ID,
--            @P_NCount        = @P_NCount,
--            @P_Result_CD     = @P_Result_CD,
--            @P_Error_CD      = @P_Error_CD,
--            @P_Process_State = 'END',
--            @P_User_ID       = @P_User_ID;

--        COMMIT TRANSACTION;
--    END TRY
--    BEGIN CATCH
--        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
--        THROW;
--    END CATCH
--END;
--GO
