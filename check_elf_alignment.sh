#!/bin/bash

# Script to check 16KB page size alignment for Android apps
# Based on: https://github.com/NitinPrakash9911/check_elf_alignment

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [ "$#" -lt 1 ]; then
    echo -e "${RED}Usage: $0 <path-to-apk-or-aab>${NC}"
    echo "Example: $0 build/app/outputs/apk/release/app-release.apk"
    exit 1
fi

APP_PATH="$1"

if [ ! -f "$APP_PATH" ]; then
    echo -e "${RED}Error: File not found: $APP_PATH${NC}"
    exit 1
fi

echo -e "${YELLOW}Checking 16KB page size alignment for: $APP_PATH${NC}"
echo ""

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Extract APK/AAB
if [[ "$APP_PATH" == *.apk ]]; then
    unzip -q "$APP_PATH" -d "$TEMP_DIR"
elif [[ "$APP_PATH" == *.aab ]]; then
    unzip -q "$APP_PATH" -d "$TEMP_DIR"
else
    echo -e "${RED}Error: File must be .apk or .aab${NC}"
    exit 1
fi

# Find all .so files
SO_FILES=$(find "$TEMP_DIR" -name "*.so")

if [ -z "$SO_FILES" ]; then
    echo -e "${GREEN}✓ No native libraries found. App is compatible with 16KB page size.${NC}"
    exit 0
fi

FAILED=0
PASSED=0

echo "Checking native libraries (.so files):"
echo "----------------------------------------"

while IFS= read -r so_file; do
    BASENAME=$(basename "$so_file")
    
    # Check if readelf is available
    if ! command -v readelf &> /dev/null; then
        echo -e "${RED}Error: readelf not found. Please install binutils.${NC}"
        echo "On macOS: brew install binutils"
        echo "On Linux: sudo apt-get install binutils"
        exit 1
    fi
    
    # Check alignment of LOAD segments
    ALIGNMENT=$(readelf -l "$so_file" | grep LOAD | awk '{print $NF}' | head -1)
    
    # Convert hex to decimal if needed
    if [[ "$ALIGNMENT" =~ ^0x ]]; then
        ALIGNMENT=$((ALIGNMENT))
    fi
    
    # 16KB = 16384 bytes
    if [ "$ALIGNMENT" -ge 16384 ]; then
        echo -e "  ${GREEN}✓${NC} $BASENAME (alignment: $ALIGNMENT)"
        ((PASSED++))
    else
        echo -e "  ${RED}✗${NC} $BASENAME (alignment: $ALIGNMENT) - NEEDS UPDATE"
        ((FAILED++))
    fi
done <<< "$SO_FILES"

echo "----------------------------------------"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ SUCCESS: All native libraries are 16KB page size compatible!${NC}"
    echo -e "${GREEN}  Passed: $PASSED${NC}"
    exit 0
else
    echo -e "${RED}✗ FAILURE: Some libraries are not 16KB compatible${NC}"
    echo -e "${GREEN}  Passed: $PASSED${NC}"
    echo -e "${RED}  Failed: $FAILED${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Update Android Gradle Plugin to 8.5.1+"
    echo "2. Update Gradle to 8.5+"
    echo "3. Update NDK to r28+"
    echo "4. Update Flutter to 3.32+"
    echo "5. Update any plugins that provide native libraries"
    echo "6. Clean and rebuild: ./gradlew clean && ./gradlew assembleRelease"
    exit 1
fi
