#!/bin/bash

# BMI Tracker 최적화된 빌드 스크립트
# 다양한 최적화 옵션으로 앱을 빌드합니다

echo "🚀 Optimized Build Script"
echo "========================"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 옵션 파싱
BUILD_TYPE="appbundle"
SPLIT_ABI=false
SPLIT_DEBUG_INFO=false
OBFUSCATE=false
CLEAN_BUILD=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --apk)
      BUILD_TYPE="apk"
      shift
      ;;
    --split-per-abi)
      SPLIT_ABI=true
      shift
      ;;
    --split-debug-info)
      SPLIT_DEBUG_INFO=true
      shift
      ;;
    --obfuscate)
      OBFUSCATE=true
      shift
      ;;
    --clean)
      CLEAN_BUILD=true
      shift
      ;;
    --help)
      echo "사용법: $0 [옵션]"
      echo "옵션:"
      echo "  --apk              APK 빌드 (기본: App Bundle)"
      echo "  --split-per-abi    ABI별 분할"
      echo "  --split-debug-info 디버그 정보 분할"
      echo "  --obfuscate        코드 난독화"
      echo "  --clean            클린 빌드"
      echo "  --help             도움말 표시"
      exit 0
      ;;
    *)
      echo "알 수 없는 옵션: $1"
      exit 1
      ;;
  esac
done

# 빌드 전 정리
if [ "$CLEAN_BUILD" = true ]; then
    echo -e "${YELLOW}🧹 클린 빌드 시작...${NC}"
    flutter clean
    flutter pub get
    echo -e "${GREEN}✅ 클린 완료${NC}"
fi

# 의존성 설치
echo -e "${BLUE}📦 의존성 설치...${NC}"
flutter pub get

# 코드 생성 (필요한 경우)
if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
    echo -e "${BLUE}🔨 코드 생성...${NC}"
    dart run build_runner build --delete-conflicting-outputs
fi

# 애셋 최적화
echo -e "${BLUE}🎨 애셋 최적화...${NC}"
if [ -f "scripts/optimize_assets.sh" ]; then
    ./scripts/optimize_assets.sh
fi

# 빌드 명령어 구성
BUILD_COMMAND="flutter build $BUILD_TYPE --release"

if [ "$SPLIT_ABI" = true ]; then
    BUILD_COMMAND="$BUILD_COMMAND --split-per-abi"
    echo -e "${YELLOW}📱 ABI별 분할 빌드${NC}"
fi

if [ "$SPLIT_DEBUG_INFO" = true ]; then
    BUILD_COMMAND="$BUILD_COMMAND --split-debug-info=build/debug-info"
    echo -e "${YELLOW}🐛 디버그 정보 분할${NC}"
fi

if [ "$OBFUSCATE" = true ]; then
    BUILD_COMMAND="$BUILD_COMMAND --obfuscate"
    echo -e "${YELLOW}🔒 코드 난독화 활성화${NC}"
fi

# 트리 셰이킹 최적화
BUILD_COMMAND="$BUILD_COMMAND --tree-shake-icons"

echo -e "${YELLOW}🔧 빌드 명령어: $BUILD_COMMAND${NC}"

# 빌드 실행
echo -e "${BLUE}⚡ 빌드 시작...${NC}"
if $BUILD_COMMAND; then
    echo -e "${GREEN}✅ 빌드 성공!${NC}"
    
    # 빌드 결과 분석
    echo -e "\n${BLUE}📊 빌드 결과 분석:${NC}"
    
    if [ "$BUILD_TYPE" = "apk" ]; then
        APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
        if [ -f "$APK_PATH" ]; then
            APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
            echo -e "  📱 APK 크기: ${GREEN}$APK_SIZE${NC}"
            echo -e "  📍 위치: $APK_PATH"
        fi
        
        # ABI별 APK 크기 (분할 빌드인 경우)
        if [ "$SPLIT_ABI" = true ]; then
            echo -e "\n  📱 ABI별 APK 크기:"
            for apk in build/app/outputs/flutter-apk/*.apk; do
                if [ -f "$apk" ]; then
                    size=$(du -h "$apk" | cut -f1)
                    name=$(basename "$apk")
                    echo -e "    • $name: $size"
                fi
            done
        fi
    else
        AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
        if [ -f "$AAB_PATH" ]; then
            AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
            echo -e "  📦 App Bundle 크기: ${GREEN}$AAB_SIZE${NC}"
            echo -e "  📍 위치: $AAB_PATH"
        fi
    fi
    
    # 빌드 시간 표시
    echo -e "\n${GREEN}🎉 빌드 완료!${NC}"
    
    # 추가 최적화 제안
    echo -e "\n${YELLOW}💡 추가 최적화 제안:${NC}"
    echo -e "  • Play Console에서 동적 전송 사용"
    echo -e "  • 사용하지 않는 언어 리소스 제거"
    echo -e "  • WebP 이미지 형식 사용"
    echo -e "  • 벡터 드로어블 사용"
    
else
    echo -e "${RED}❌ 빌드 실패${NC}"
    exit 1
fi