#!/bin/bash

# BMI Tracker 애셋 최적화 스크립트
# 이미지 파일을 압축하고 최적화합니다

echo "🎨 Asset Optimization Script"
echo "=========================="

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 애셋 디렉토리
ASSETS_DIR="assets"
IMAGES_DIR="$ASSETS_DIR/images"
ICONS_DIR="$ASSETS_DIR/icons"

# 통계 변수
TOTAL_BEFORE=0
TOTAL_AFTER=0
FILES_OPTIMIZED=0

# 디렉토리 생성 (없는 경우)
mkdir -p "$IMAGES_DIR"
mkdir -p "$ICONS_DIR"

# ImageMagick 설치 확인
if ! command -v convert &> /dev/null; then
    echo -e "${RED}❌ ImageMagick이 설치되어 있지 않습니다.${NC}"
    echo "설치 방법: brew install imagemagick"
    exit 1
fi

# PNG 최적화 함수
optimize_png() {
    local file="$1"
    local before_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file")
    
    # ImageMagick을 사용한 PNG 최적화
    convert "$file" -strip -quality 85 "$file.tmp"
    
    if [ -f "$file.tmp" ]; then
        local after_size=$(stat -f%z "$file.tmp" 2>/dev/null || stat -c%s "$file.tmp")
        
        # 크기가 줄어든 경우에만 교체
        if [ "$after_size" -lt "$before_size" ]; then
            mv "$file.tmp" "$file"
            TOTAL_BEFORE=$((TOTAL_BEFORE + before_size))
            TOTAL_AFTER=$((TOTAL_AFTER + after_size))
            FILES_OPTIMIZED=$((FILES_OPTIMIZED + 1))
            
            local saved=$((before_size - after_size))
            local percent=$((saved * 100 / before_size))
            echo -e "${GREEN}✓${NC} $(basename "$file"): ${before_size} → ${after_size} bytes (${percent}% 감소)"
        else
            rm "$file.tmp"
            echo -e "${YELLOW}○${NC} $(basename "$file"): 이미 최적화됨"
        fi
    fi
}

# JPG/JPEG 최적화 함수
optimize_jpg() {
    local file="$1"
    local before_size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file")
    
    # ImageMagick을 사용한 JPEG 최적화
    convert "$file" -strip -interlace Plane -quality 85 "$file.tmp"
    
    if [ -f "$file.tmp" ]; then
        local after_size=$(stat -f%z "$file.tmp" 2>/dev/null || stat -c%s "$file.tmp")
        
        # 크기가 줄어든 경우에만 교체
        if [ "$after_size" -lt "$before_size" ]; then
            mv "$file.tmp" "$file"
            TOTAL_BEFORE=$((TOTAL_BEFORE + before_size))
            TOTAL_AFTER=$((TOTAL_AFTER + after_size))
            FILES_OPTIMIZED=$((FILES_OPTIMIZED + 1))
            
            local saved=$((before_size - after_size))
            local percent=$((saved * 100 / before_size))
            echo -e "${GREEN}✓${NC} $(basename "$file"): ${before_size} → ${after_size} bytes (${percent}% 감소)"
        else
            rm "$file.tmp"
            echo -e "${YELLOW}○${NC} $(basename "$file"): 이미 최적화됨"
        fi
    fi
}

# 1x, 2x, 3x 버전 생성 함수
generate_flutter_assets() {
    local file="$1"
    local dir=$(dirname "$file")
    local filename=$(basename "$file")
    local name="${filename%.*}"
    local ext="${filename##*.}"
    
    # 2x 디렉토리 생성
    mkdir -p "$dir/2.0x"
    mkdir -p "$dir/3.0x"
    
    # 원본을 1x로 사용
    echo -e "${GREEN}✓${NC} 1x: $filename"
    
    # 2x 버전 생성 (200%)
    convert "$file" -resize 200% "$dir/2.0x/$filename"
    echo -e "${GREEN}✓${NC} 2x: 2.0x/$filename"
    
    # 3x 버전 생성 (300%)
    convert "$file" -resize 300% "$dir/3.0x/$filename"
    echo -e "${GREEN}✓${NC} 3x: 3.0x/$filename"
}

# PNG 파일 최적화
echo -e "\n${YELLOW}PNG 파일 최적화 중...${NC}"
find "$ASSETS_DIR" -name "*.png" -type f | while read -r file; do
    # 2.0x, 3.0x 폴더는 건너뛰기
    if [[ ! "$file" =~ (2\.0x|3\.0x) ]]; then
        optimize_png "$file"
    fi
done

# JPG/JPEG 파일 최적화
echo -e "\n${YELLOW}JPEG 파일 최적화 중...${NC}"
find "$ASSETS_DIR" -name "*.jpg" -o -name "*.jpeg" -type f | while read -r file; do
    # 2.0x, 3.0x 폴더는 건너뛰기
    if [[ ! "$file" =~ (2\.0x|3\.0x) ]]; then
        optimize_jpg "$file"
    fi
done

# Flutter 해상도별 애셋 생성 (선택적)
if [ "$1" == "--generate-resolutions" ]; then
    echo -e "\n${YELLOW}Flutter 해상도별 애셋 생성 중...${NC}"
    find "$ASSETS_DIR" \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) -type f | while read -r file; do
        # 2.0x, 3.0x 폴더는 건너뛰기
        if [[ ! "$file" =~ (2\.0x|3\.0x) ]]; then
            generate_flutter_assets "$file"
        fi
    done
fi

# 결과 출력
echo -e "\n${GREEN}========== 최적화 완료 ==========${NC}"
echo "최적화된 파일: $FILES_OPTIMIZED개"

if [ $FILES_OPTIMIZED -gt 0 ]; then
    TOTAL_SAVED=$((TOTAL_BEFORE - TOTAL_AFTER))
    TOTAL_PERCENT=$((TOTAL_SAVED * 100 / TOTAL_BEFORE))
    
    echo "원본 크기: $((TOTAL_BEFORE / 1024)) KB"
    echo "최적화 후: $((TOTAL_AFTER / 1024)) KB"
    echo "절약된 용량: $((TOTAL_SAVED / 1024)) KB (${TOTAL_PERCENT}%)"
fi

echo -e "${GREEN}=================================${NC}"