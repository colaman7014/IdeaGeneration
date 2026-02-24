"""排程任務管理"""
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.interval import IntervalTrigger

from app.core.config import get_settings
from app.core.database import SessionLocal
from app.services.rss_fetcher import create_rss_fetcher
from app.services.tag_extractor import create_tag_extractor


# 全域排程器實例
scheduler = AsyncIOScheduler()


async def fetch_rss_job():
    """RSS 抓取排程任務"""
    db = SessionLocal()
    try:
        fetcher = create_rss_fetcher(db)
        result = fetcher.fetch_all_sources()
        print(f"[RSS 排程] 抓取完成: {result['new_articles']} 篇新文章")
        return result
    except Exception as e:
        print(f"[RSS 排程] 錯誤: {str(e)}")
    finally:
        db.close()


async def extract_tags_job():
    """標籤提取排程任務"""
    db = SessionLocal()
    try:
        extractor = create_tag_extractor(db)
        result = await extractor.process_untagged_news(limit=10)
        print(f"[標籤排程] 處理完成: {result['processed']} 篇已標籤")
        return result
    except Exception as e:
        print(f"[標籤排程] 錯誤: {str(e)}")
    finally:
        db.close()


def setup_scheduler():
    """設定排程任務"""
    settings = get_settings()
    interval_minutes = settings.rss_update_interval
    
    # 新增 RSS 抓取任務（每小時）
    scheduler.add_job(
        fetch_rss_job,
        trigger=IntervalTrigger(minutes=interval_minutes),
        id="fetch_rss",
        name="RSS 抓取任務",
        replace_existing=True
    )
    
    # 新增標籤提取任務（每 10 分鐘）
    scheduler.add_job(
        extract_tags_job,
        trigger=IntervalTrigger(minutes=10),
        id="extract_tags",
        name="標籤提取任務",
        replace_existing=True
    )
    
    print(f"[排程器] 已設定 RSS 抓取間隔: {interval_minutes} 分鐘")
    print("[排程器] 已設定標籤提取間隔: 10 分鐘")


def start_scheduler():
    """啟動排程器"""
    if not scheduler.running:
        setup_scheduler()
        scheduler.start()
        print("[排程器] 已啟動")


def stop_scheduler():
    """停止排程器"""
    if scheduler.running:
        scheduler.shutdown()
        print("[排程器] 已停止")
