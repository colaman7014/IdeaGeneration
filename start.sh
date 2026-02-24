#!/bin/bash
# IdeaGeneration Backend 啟動腳本 (macOS / Linux)

set -e

echo "=== IdeaGeneration Backend 啟動腳本 ==="
echo

# 檢查 .env 是否存在
if [ ! -f "backend/.env" ]; then
    echo "[錯誤] 找不到 backend/.env 檔案"
    echo "請先複製 backend/.env.example 為 backend/.env 並設定 VERCEL_API_KEY"
    exit 1
fi

# 切換到 backend 目錄
cd backend

# 檢查 uv 是否安裝
if ! command -v uv &> /dev/null; then
    echo "[錯誤] 未找到 uv，請先安裝：https://docs.astral.sh/uv/"
    exit 1
fi

echo "[1/2] 安裝 Python 依賴..."
uv sync

echo "[2/2] 啟動 FastAPI 後端伺服器..."
echo "      API 位址：http://localhost:8000"
echo "      API 文件：http://localhost:8000/docs"
echo

uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
