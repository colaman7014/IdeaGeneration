@echo off
echo === IdeaGeneration Backend 啟動腳本 ===
echo.

REM 檢查 .env 是否存在
if not exist "backend\.env" (
    echo [錯誤] 找不到 backend\.env 檔案
    echo 請先複製 backend\.env.example 為 backend\.env 並設定 VERCEL_API_KEY
    pause
    exit /b 1
)

REM 切換到 backend 目錄
cd backend

REM 檢查 uv 是否安裝
where uv >nul 2>&1
if %errorlevel% neq 0 (
    echo [錯誤] 未找到 uv，請先安裝：https://docs.astral.sh/uv/
    pause
    exit /b 1
)

echo [1/3] 安裝 Python 依賴...
uv sync

echo [2/3] 啟動 FastAPI 後端伺服器...
echo       API 位址：http://localhost:8000
echo       API 文件：http://localhost:8000/docs
echo.
uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

pause
