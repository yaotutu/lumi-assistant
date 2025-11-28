#!/bin/bash

# Release生成脚本
# 用于GitHub Actions自动生成Release描述和资源

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# 默认值
VERSION=${VERSION:-"0.1.0-pre"}
BUILD_NUMBER=${BUILD_NUMBER:-$(date +'%Y%m%d%H%M')}
COMMIT_SHA=${COMMIT_SHA:-$(git rev-parse --short HEAD)}
COMMIT_MESSAGE=${COMMIT_MESSAGE:-$(git log -1 --pretty=format:'%s')}
COMMIT_AUTHOR=${COMMIT_AUTHOR:-$(git log -1 --pretty=format:'%an')}
COMMIT_DATE=${COMMIT_DATE:-$(git log -1 --pretty=format:'%ci')}
BRANCH=${BRANCH:-$(git rev-parse --abbrev-ref HEAD)}

# GitHub相关变量
GITHUB_REPOSITORY=${GITHUB_REPOSITORY:-""}
GITHUB_SHA=${GITHUB_SHA:-$(git rev-parse HEAD)}

# 生成URL
if [ -n "${GITHUB_REPOSITORY}" ]; then
    REPO_URL="https://github.com/${GITHUB_REPOSITORY}"
    COMMIT_URL="${REPO_URL}/commit/${GITHUB_SHA}"
    ISSUES_URL="${REPO_URL}/issues"
    RELEASES_URL="${REPO_URL}/releases"
    DOCS_URL="${REPO_URL}/blob/main/docs"
    CONTRIBUTING_URL="${REPO_URL}/blob/main/CONTRIBUTING.md"
else
    REPO_URL="https://github.com/your-username/lumi-assistant"
    COMMIT_URL="${REPO_URL}/commit/${COMMIT_SHA}"
    ISSUES_URL="${REPO_URL}/issues"
    RELEASES_URL="${REPO_URL}/releases"
    DOCS_URL="${REPO_URL}/blob/main/docs"
    CONTRIBUTING_URL="${REPO_URL}/blob/main/CONTRIBUTING.md"
fi

# 生成构建时间
BUILD_TIME=$(date -u +'%Y-%m-%d %H:%M:%S UTC')

# 生成标签名
TAG_NAME="v${VERSION}"

# 检查Android构建环境
get_android_info() {
    # 读取项目信息
    if [ -f "${REPO_ROOT}/app/build.gradle" ]; then
        VERSION_NAME_FROM_GRADLE=$(grep -o 'versionName "[^"]*"' "${REPO_ROOT}/app/build.gradle" | grep -o '"[^"]*"' | tr -d '"' || echo "Unknown")
        VERSION_CODE_FROM_GRADLE=$(grep -o 'versionCode [0-9]*' "${REPO_ROOT}/app/build.gradle" | grep -o '[0-9]*' || echo "Unknown")
    else
        VERSION_NAME_FROM_GRADLE="Unknown"
        VERSION_CODE_FROM_GRADLE="Unknown"
    fi

    # 获取Gradle版本
    if command -v ./gradlew &> /dev/null; then
        GRADLE_VERSION=$(./gradlew --version | grep "Gradle" | head -n1 | awk '{print $2}' || echo "Unknown")
    else
        GRADLE_VERSION="Unknown"
    fi

    # 获取Kotlin版本
    if [ -f "${REPO_ROOT}/gradle.properties" ]; then
        KOTLIN_VERSION=$(grep "kotlin.version" "${REPO_ROOT}/gradle.properties" | cut -d'=' -f2 | tr -d ' ' || echo "Unknown")
    else
        KOTLIN_VERSION="Unknown"
    fi

    # 获取AGP版本
    if [ -f "${REPO_ROOT}/gradle/libs.versions.toml" ]; then
        AGP_VERSION=$(grep "agp" "${REPO_ROOT}/gradle/libs.versions.toml" -A1 | grep "version" | cut -d'=' -f2 | tr -d ' "')
    else
        AGP_VERSION="Unknown"
    fi
}

# 生成Release描述
generate_release_notes() {
    local template_file="${SCRIPT_DIR}/../release-template.md"
    local output_file="${REPO_ROOT}/release_notes.md"
    
    if [ ! -f "${template_file}" ]; then
        log_error "Release模板文件不存在: ${template_file}"
        exit 1
    fi
    
    log_info "生成Release描述..."
    
    # 复制模板并替换变量
    cp "${template_file}" "${output_file}"
    
    # 替换所有变量
    sed -i.bak \
        -e "s|{{VERSION}}|${VERSION}|g" \
        -e "s|{{BUILD_NUMBER}}|${BUILD_NUMBER}|g" \
        -e "s|{{BUILD_TIME}}|${BUILD_TIME}|g" \
        -e "s|{{COMMIT_SHA}}|${COMMIT_SHA}|g" \
        -e "s|{{COMMIT_URL}}|${COMMIT_URL}|g" \
        -e "s|{{COMMIT_MESSAGE}}|${COMMIT_MESSAGE}|g" \
        -e "s|{{COMMIT_AUTHOR}}|${COMMIT_AUTHOR}|g" \
        -e "s|{{COMMIT_DATE}}|${COMMIT_DATE}|g" \
        -e "s|{{BRANCH}}|${BRANCH}|g" \
        -e "s|{{REPO_URL}}|${REPO_URL}|g" \
        -e "s|{{ISSUES_URL}}|${ISSUES_URL}|g" \
        -e "s|{{RELEASES_URL}}|${RELEASES_URL}|g" \
        -e "s|{{DOCS_URL}}|${DOCS_URL}|g" \
        -e "s|{{CONTRIBUTING_URL}}|${CONTRIBUTING_URL}|g" \
        -e "s|{{GRADLE_VERSION}}|${GRADLE_VERSION}|g" \
        -e "s|{{KOTLIN_VERSION}}|${KOTLIN_VERSION}|g" \
        -e "s|{{AGP_VERSION}}|${AGP_VERSION}|g" \
        -e "s|{{VERSION_NAME_FROM_GRADLE}}|${VERSION_NAME_FROM_GRADLE}|g" \
        -e "s|{{VERSION_CODE_FROM_GRADLE}}|${VERSION_CODE_FROM_GRADLE}|g" \
        -e "s|{{TAG_NAME}}|${TAG_NAME}|g" \
        "${output_file}"
    
    # 删除备份文件
    rm -f "${output_file}.bak"
    
    log_success "Release描述已生成: ${output_file}"
}

# 生成Release摘要（用于GitHub Actions输出）
generate_release_summary() {
    local summary_file="${REPO_ROOT}/release_summary.md"
    
    cat > "${summary_file}" << EOF
# 🚀 Lumi Assistant ${VERSION}

**开发测试版本** - 仅供开发和测试使用

## 📦 构建信息
- 版本号: \`${VERSION}\`
- 构建号: \`${BUILD_NUMBER}\`
- 构建时间: \`${BUILD_TIME}\`
- Git提交: [\`${COMMIT_SHA}\`](${COMMIT_URL})

## 📝 最新更改
**${COMMIT_MESSAGE}**

## 📱 下载
APK文件将在构建完成后自动附加到此Release。

## ⚠️ 注意
这是开发测试版本，可能包含未完成的功能和已知问题。

---
*由 GitHub Actions 自动生成*
EOF

    log_success "Release摘要已生成: ${summary_file}"
}

# 验证APK文件
verify_apk() {
    local apk_path="$1"
    
    if [ -z "${apk_path}" ]; then
        log_error "APK路径不能为空"
        return 1
    fi
    
    if [ ! -f "${apk_path}" ]; then
        log_error "APK文件不存在: ${apk_path}"
        return 1
    fi
    
    # 检查文件大小
    local file_size=$(stat -f%z "${apk_path}" 2>/dev/null || stat -c%s "${apk_path}" 2>/dev/null || echo "0")
    if [ "${file_size}" -lt 1000000 ]; then  # 小于1MB
        log_warning "APK文件可能太小: ${file_size} bytes"
    fi
    
    log_success "APK文件验证通过: ${apk_path} (${file_size} bytes)"
}

# 输出到GitHub Actions环境
output_to_github() {
    if [ -n "${GITHUB_OUTPUT}" ]; then
        echo "release-notes-path=${REPO_ROOT}/release_notes.md" >> ${GITHUB_OUTPUT}
        echo "release-summary-path=${REPO_ROOT}/release_summary.md" >> ${GITHUB_OUTPUT}
        echo "tag-name=${TAG_NAME}" >> ${GITHUB_OUTPUT}
        echo "release-name=🚀 Lumi Assistant ${VERSION}" >> ${GITHUB_OUTPUT}
        echo "is-prerelease=true" >> ${GITHUB_OUTPUT}
        
        log_success "Release信息已输出到GitHub Actions环境"
    fi
}

# 显示Release摘要
show_summary() {
    echo ""
    echo "================================================"
    echo "              Release信息摘要"
    echo "================================================"
    echo "版本号:           ${VERSION}"
    echo "构建号:           ${BUILD_NUMBER}"
    echo "标签名:           ${TAG_NAME}"
    echo "构建时间:         ${BUILD_TIME}"
    echo "提交哈希:         ${COMMIT_SHA}"
    echo "提交信息:         ${COMMIT_MESSAGE}"
    echo "分支:             ${BRANCH}"
    echo "Gradle版本:       ${GRADLE_VERSION}"
    echo "Kotlin版本:       ${KOTLIN_VERSION}"
    echo "AGP版本:          ${AGP_VERSION}"
    echo "仓库URL:          ${REPO_URL}"
    echo "================================================"
}

# 主函数
main() {
    log_info "开始生成Release信息..."

    get_android_info
    generate_release_notes
    generate_release_summary
    output_to_github
    show_summary

    log_success "Release信息生成完成！"
}

# 处理命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --verify-apk)
            verify_apk "$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --verify-apk PATH    验证APK文件"
            echo "  --help, -h           显示帮助信息"
            echo ""
            echo "Environment Variables:"
            echo "  VERSION              版本号 (默认: 0.1.0-pre)"
            echo "  BUILD_NUMBER         构建号 (默认: 当前时间戳)"
            echo "  COMMIT_SHA           提交哈希 (默认: git rev-parse --short HEAD)"
            echo "  GITHUB_REPOSITORY    GitHub仓库名"
            echo "  GITHUB_OUTPUT        GitHub Actions输出文件"
            exit 0
            ;;
        *)
            log_error "未知参数: $1"
            exit 1
            ;;
    esac
done

# 如果没有特殊参数，执行主函数
if [ $# -eq 0 ]; then
    main "$@"
fi