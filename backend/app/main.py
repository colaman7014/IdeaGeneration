"""FastAPI 應用程式主入口"""
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import get_settings
from app.core.database import engine, Base
from app.services.scheduler import start_scheduler, stop_scheduler
from app.routers import ideas, news

# 取得設定
settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """應用生命週期管理"""
    # 啟動時執行
    Base.metadata.create_all(bind=engine)
    start_scheduler()
    yield
    # 關閉時執行
    stop_scheduler()


# 建立 FastAPI 應用
app = FastAPI(
    title="IdeaGeneration API",
    description="新聞到點子生成器 MVP - 讓專業人士在 3 分鐘內從新聞產生商業想法",
    version="0.1.0",
    debug=settings.debug,
    lifespan=lifespan
)

# 設定 CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # MVP 階段允許所有來源
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 註冊路由
app.include_router(ideas.router, prefix="/api")
app.include_router(news.router, prefix="/api")


@app.get("/")
async def root():
    """根路由 - 健康檢查"""
    return {
        "status": "ok",
        "message": "IdeaGeneration API is running",
        "version": "0.1.0"
    }


@app.get("/health")
async def health_check():
    """健康檢查端點"""
    return {"status": "healthy"}
