"""Test Prompt output quality and API structure"""
import sys
import io

# Fix Windows encoding
if sys.platform == 'win32':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
from app.services.llm_client import (
    TAG_EXTRACTION_PROMPT,
    IDEA_SYNTHESIS_PROMPT,
    DEVIL_AUDIT_PROMPT
)


def test_prompt_format():
    """Test Prompt format correctness"""
    print("=" * 60)
    print("Test 1: Prompt Format Validation")
    print("=" * 60)
    
    # Test tag extraction prompt
    try:
        tag_prompt = TAG_EXTRACTION_PROMPT.format(
            title="OpenAI GPT-5 release",
            summary="OpenAI announces GPT-5 with significant improvements."
        )
        print("[PASS] TAG_EXTRACTION_PROMPT format OK")
        print(f"       Output length: {len(tag_prompt)} chars")
    except KeyError as e:
        print(f"[FAIL] TAG_EXTRACTION_PROMPT missing var: {e}")
    
    # Test idea synthesis prompt
    try:
        idea_prompt = IDEA_SYNTHESIS_PROMPT.format(
            news_a_title="TSMC 2nm process",
            tags_a="semiconductor, advanced process",
            news_b_title="Telemedicine growth",
            tags_b="medical tech, digital transformation"
        )
        print("[PASS] IDEA_SYNTHESIS_PROMPT format OK")
        print(f"       Output length: {len(idea_prompt)} chars")
    except KeyError as e:
        print(f"[FAIL] IDEA_SYNTHESIS_PROMPT missing var: {e}")
    
    # Test devil audit prompt
    try:
        devil_prompt = DEVIL_AUDIT_PROMPT.format(
            idea_content="Test idea content for validation"
        )
        print("[PASS] DEVIL_AUDIT_PROMPT format OK")
        print(f"       Output length: {len(devil_prompt)} chars")
    except KeyError as e:
        print(f"[FAIL] DEVIL_AUDIT_PROMPT missing var: {e}")
    
    print()


def test_prompt_content_quality():
    """Test Prompt content quality"""
    print("=" * 60)
    print("Test 2: Prompt Content Quality Check")
    print("=" * 60)
    checks = [
        ("TAG_EXTRACTION has output example", "\u7bc4\u4f8b\u8f38\u51fa" in TAG_EXTRACTION_PROMPT),
        ("TAG_EXTRACTION limits tag count", "3-5" in TAG_EXTRACTION_PROMPT),
        ("IDEA_SYNTHESIS has structured output", "\u9ede\u5b50\u540d\u7a31" in IDEA_SYNTHESIS_PROMPT),
        ("IDEA_SYNTHESIS has profit model", "\u7372\u5229\u6a21\u5f0f" in IDEA_SYNTHESIS_PROMPT),
        ("IDEA_SYNTHESIS has action guide", "\u7b2c\u4e00\u6b65\u884c\u52d5" in IDEA_SYNTHESIS_PROMPT),
        ("DEVIL_AUDIT sets role", "\u98a8\u96aa\u6295\u8cc7\u4eba" in DEVIL_AUDIT_PROMPT),
        ("DEVIL_AUDIT limits questions", "5" in DEVIL_AUDIT_PROMPT),
        ("DEVIL_AUDIT has fire emoji", "\U0001f525" in DEVIL_AUDIT_PROMPT),
    ]
    passed = 0
    for check_name, result in checks:
        if result:
            print(f"[PASS] {check_name}")
            passed += 1
        else:
            print(f"[FAIL] {check_name}")
    
    print(f"\nQuality checks: {passed}/{len(checks)} passed")
    print()


def test_api_schema_imports():
    """Test API Schema imports"""
    print("=" * 60)
    print("Test 3: API Schema Import Check")
    print("=" * 60)
    
    try:
        from app.schemas import (
            IdeaResponse,
            IdeaListResponse,
            IdeaGenerateRequest,
            DevilAuditRequest,
            DevilAuditResponse,
            NewsResponse,
            NewsListResponse,
            TagResponse
        )
        print("[PASS] All schemas imported successfully")
        
        # Test schema structure
        print(f"       IdeaResponse fields: {list(IdeaResponse.model_fields.keys())}")
        print(f"       NewsResponse fields: {list(NewsResponse.model_fields.keys())}")
        print(f"       IdeaGenerateRequest fields: {list(IdeaGenerateRequest.model_fields.keys())}")
        
    except ImportError as e:
        print(f"[FAIL] Schema import failed: {e}")
    
    print()


def test_service_imports():
    """Test Service imports"""
    print("=" * 60)
    print("Test 4: Service Import Check")
    print("=" * 60)
    
    try:
        from app.services.llm_client import create_llm_client, VercelLLMClient
        print("[PASS] llm_client imported")
    except ImportError as e:
        print(f"[FAIL] llm_client import failed: {e}")
    
    try:
        from app.services.idea_service import create_idea_service, IdeaService
        print("[PASS] idea_service imported")
    except ImportError as e:
        print(f"[FAIL] idea_service import failed: {e}")
    
    try:
        from app.services.tag_extractor import create_tag_extractor, TagExtractor
        print("[PASS] tag_extractor imported")
    except ImportError as e:
        print(f"[FAIL] tag_extractor import failed: {e}")
    
    print()


def test_router_imports():
    """Test Router imports"""
    print("=" * 60)
    print("Test 5: Router Import Check")
    print("=" * 60)
    
    try:
        from app.routers.ideas import router as ideas_router
        print(f"[PASS] ideas router imported")
        print(f"       Route count: {len(ideas_router.routes)}")
    except ImportError as e:
        print(f"[FAIL] ideas router import failed: {e}")
    
    try:
        from app.routers.news import router as news_router
        print(f"[PASS] news router imported")
        print(f"       Route count: {len(news_router.routes)}")
    except ImportError as e:
        print(f"[FAIL] news router import failed: {e}")
    
    print()


def main():
    """Run all tests"""
    print("\n" + "=" * 60)
    print("IdeaGeneration - Prompt Quality Test")
    print("=" * 60 + "\n")
    test_prompt_content_quality()
    test_api_schema_imports()
    test_service_imports()
    test_router_imports()
    print("=" * 60)
    print("All tests completed!")
    print("=" * 60)


if __name__ == "__main__":
    main()
