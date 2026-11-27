USE [DB_INCAR_FCA];
GO

-----------------------------------------------------------
-- GROUP_COMM_CODE
-----------------------------------------------------------
DELETE FROM dbo.TB_GROUP_COMM_CODE

BULK INSERT dbo.TB_GROUP_COMM_CODE
FROM 'D:\Project\AMOMES\INCAR_FCA\ddl\TB_GROUP_COMM_CODE.csv' -- SQL Server가 설치된 서버(혹은 접근 가능한 공유 폴더)의 파일 경로
WITH (
    FIRSTROW = 2,                -- 헤더가 있다면 2로 설정 (첫 줄 스킵)
    FIELDTERMINATOR = ',',      -- 열 구분자 (CSV는 콤마 ',', TXT는 탭 '\t' 등)
    ROWTERMINATOR = '\n',     -- 행 구분자 (줄바꿈)
    CODEPAGE = '65001'          -- 인코딩 설정 (65001: UTF-8)
    --ERRORFILE = 'D:\Project\AMOMES\INCAR_FCA\ddl\BulkErrorLog.log' -- 에러 난 행을 이 파일에 기록
);

-- 데이터 확인
SELECT * FROM dbo.TB_GROUP_COMM_CODE


-----------------------------------------------------------
-- TB_COMM_CODE
-----------------------------------------------------------
DELETE FROM  dbo.TB_COMM_CODE

BULK INSERT dbo.TB_COMM_CODE
FROM 'D:\Project\AMOMES\INCAR_FCA\ddl\TB_COMM_CODe.csv' -- SQL Server가 설치된 서버(혹은 접근 가능한 공유 폴더)의 파일 경로
WITH (
    FIRSTROW = 2,                -- 헤더가 있다면 2로 설정 (첫 줄 스킵)
    FIELDTERMINATOR = ',',      -- 열 구분자 (CSV는 콤마 ',', TXT는 탭 '\t' 등)
    ROWTERMINATOR = '\n',     -- 행 구분자 (줄바꿈)
    CODEPAGE = '65001'          -- 인코딩 설정 (65001: UTF-8)
    --ERRORFILE = 'D:\Project\AMOMES\INCAR_FCA\ddl\BulkErrorLog.log' -- 에러 난 행을 이 파일에 기록
);

-- 데이터 확인
SELECT * FROM dbo.TB_COMM_CODE


-----------------------------------------------------------
-- TB_LANG_DICT
-----------------------------------------------------------
DELETE FROM  dbo.TB_LANG_DICT

BULK INSERT dbo.TB_LANG_DICT
FROM 'D:\Project\AMOMES\INCAR_FCA\ddl\TB_LANG_DICT.csv' -- SQL Server가 설치된 서버(혹은 접근 가능한 공유 폴더)의 파일 경로
WITH (
    FIRSTROW = 2,                -- 헤더가 있다면 2로 설정 (첫 줄 스킵)
    FIELDTERMINATOR = ',',      -- 열 구분자 (CSV는 콤마 ',', TXT는 탭 '\t' 등)
    ROWTERMINATOR = '\n',     -- 행 구분자 (줄바꿈)
    CODEPAGE = '65001'          -- 인코딩 설정 (65001: UTF-8)
    --ERRORFILE = 'D:\Project\AMOMES\INCAR_FCA\ddl\BulkErrorLog.log' -- 에러 난 행을 이 파일에 기록
);

-- 데이터 확인
SELECT * FROM dbo.TB_LANG_DICT

-----------------------------------------------------------
-- TB_PROCESS
-----------------------------------------------------------
DELETE FROM  dbo.TB_PROCESS

BULK INSERT dbo.TB_PROCESS
FROM 'D:\Project\AMOMES\INCAR_FCA\ddl\TB_PROCESS.csv' -- SQL Server가 설치된 서버(혹은 접근 가능한 공유 폴더)의 파일 경로
WITH (
    FIRSTROW = 2,                -- 헤더가 있다면 2로 설정 (첫 줄 스킵)
    FIELDTERMINATOR = ',',      -- 열 구분자 (CSV는 콤마 ',', TXT는 탭 '\t' 등)
    ROWTERMINATOR = '\n',     -- 행 구분자 (줄바꿈)
    CODEPAGE = '65001'          -- 인코딩 설정 (65001: UTF-8)
    --ERRORFILE = 'D:\Project\AMOMES\INCAR_FCA\ddl\BulkErrorLog.log' -- 에러 난 행을 이 파일에 기록
);

-- 데이터 확인
SELECT * FROM dbo.TB_PROCESS


-----------------------------------------------------------
-- TB_MODEL
-----------------------------------------------------------
DELETE FROM  dbo.TB_MODEL

BULK INSERT dbo.TB_MODEL
FROM 'D:\Project\AMOMES\INCAR_FCA\ddl\TB_MODEL.csv' -- SQL Server가 설치된 서버(혹은 접근 가능한 공유 폴더)의 파일 경로
WITH (
    FIRSTROW = 2,                -- 헤더가 있다면 2로 설정 (첫 줄 스킵)
    FIELDTERMINATOR = ',',      -- 열 구분자 (CSV는 콤마 ',', TXT는 탭 '\t' 등)
    ROWTERMINATOR = '\n',     -- 행 구분자 (줄바꿈)
    CODEPAGE = '65001'          -- 인코딩 설정 (65001: UTF-8)
 
   --ERRORFILE = 'D:\Project\AMOMES\INCAR_FCA\ddl\BulkErrorLog.log' -- 에러 난 행을 이 파일에 기록
);

-- 데이터 확인
SELECT * FROM dbo.TB_MODEL

-----------------------------------------------------------
-- TB_PROCESS_ROUTE
-----------------------------------------------------------
DELETE FROM  dbo.TB_PROCESS_ROUTE

BULK INSERT dbo.TB_PROCESS_ROUTE
FROM 'D:\Project\AMOMES\INCAR_FCA\ddl\TB_PROCESS_ROUTE.csv' -- SQL Server가 설치된 서버(혹은 접근 가능한 공유 폴더)의 파일 경로
WITH (
    FIRSTROW = 2,                -- 헤더가 있다면 2로 설정 (첫 줄 스킵)
    FIELDTERMINATOR = ',',      -- 열 구분자 (CSV는 콤마 ',', TXT는 탭 '\t' 등)
    ROWTERMINATOR = '\n',     -- 행 구분자 (줄바꿈)
    CODEPAGE = '65001'          -- 인코딩 설정 (65001: UTF-8)
    --ERRORFILE = 'D:\Project\AMOMES\INCAR_FCA\ddl\BulkErrorLog.log' -- 에러 난 행을 이 파일에 기록
);

-- 데이터 확인
SELECT * FROM dbo.TB_PROCESS_ROUTE