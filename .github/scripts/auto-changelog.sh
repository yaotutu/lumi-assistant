#!/bin/bash

# 自动变更日志生成脚本
# 基于Git提交记录和Conventional Commits规范自动生成Release notes

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

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
SINCE_TAG=${SINCE_TAG:-""}

# 如果没有设置GITHUB_REPOSITORY，尝试从git remote获取
if [ -z "${GITHUB_REPOSITORY}" ]; then
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
    if [[ "$REMOTE_URL" == *"github.com"* ]]; then
        # 从git remote URL提取仓库名，移除.git后缀
        GITHUB_REPOSITORY=$(echo "$REMOTE_URL" | sed -E 's/.*github\.com[\/:]([^\/]+\/[^\/]+)(\.git)?$/\1/' | sed 's/\.git$//')
    else
        GITHUB_REPOSITORY="your-username/your-repo"
        log_warning "无法获取GitHub仓库名，使用默认值: ${GITHUB_REPOSITORY}"
    fi
fi

# 如果没有指定起始tag，尝试找到最近的tag
if [ -z "${SINCE_TAG}" ]; then
    SINCE_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
fi

# 分类函数
categorize_commit() {
    local commit_msg="$1"
    local commit_type=$(echo "$commit_msg" | grep -o '^[a-z]*:' | sed 's/:$//' || echo "other")
    
    case "$commit_type" in
        feat|feature)
            echo "🚀 新功能"
            ;;
        fix|bug|bugfix)
            echo "🐛 错误修复"
            ;;
        docs|doc)
            echo "📚 文档更新"
            ;;
        style|refactor)
            echo "♻️ 代码重构"
            ;;
        perf|performance)
            echo "⚡ 性能优化"
            ;;
        test|tests)
            echo "🧪 测试"
            ;;
        build|ci|chore)
            echo "🔧 构建和CI"
            ;;
        security|sec)
            echo "🔒 安全修复"
            ;;
        deps|dependencies)
            echo "📦 依赖更新"
            ;;
        remove|deprecated)
            echo "🗑️ 移除功能"
            ;;
        *)
            echo "🔄 其他更改"
            ;;
    esac
}

# 格式化提交信息
format_commit() {
    local commit_hash="$1"
    local commit_msg="$2"
    local short_hash=$(echo "$commit_hash" | cut -c1-7)
    
    # 移除类型前缀，保留主要信息
    local clean_msg=$(echo "$commit_msg" | sed 's/^[a-z]*: *//')
    
    echo "- ${clean_msg} ([${short_hash}](https://github.com/${GITHUB_REPOSITORY}/commit/${commit_hash}))"
}

# 生成变更日志
generate_changelog() {
    local output_file="${REPO_ROOT}/release_notes.md"
    local temp_file=$(mktemp)
    
    log_info "生成自动化变更日志..."
    
    # 获取提交范围
    local commit_range=""
    if [ -n "${SINCE_TAG}" ]; then
        commit_range="${SINCE_TAG}..HEAD"
        log_info "获取从 ${SINCE_TAG} 到 HEAD 的提交"
    else
        # 如果没有之前的tag，获取最近10个提交
        commit_range="HEAD~10..HEAD"
        log_warning "未找到之前的tag，获取最近10个提交"
    fi
    
    # 获取提交列表
    local commits=$(git log --pretty=format:"%H|%s" "$commit_range" --reverse)
    
    if [ -z "$commits" ]; then
        log_warning "未找到新的提交"
        commits=$(git log --pretty=format:"%H|%s" -1)
    fi
    
    # 创建临时文件存储分类信息
    local temp_dir=$(mktemp -d)
    
    # 处理每个提交
    while IFS='|' read -r commit_hash commit_msg; do
        if [ -n "$commit_hash" ] && [ -n "$commit_msg" ]; then
            local category=$(categorize_commit "$commit_msg")
            local formatted_commit=$(format_commit "$commit_hash" "$commit_msg")
            
            # 将提交信息追加到对应分类文件
            local category_file="${temp_dir}/$(echo "$category" | tr ' ' '_')"
            echo "$formatted_commit" >> "$category_file"
        fi
    done <<< "$commits"
    
    # 生成Release notes - 完全基于Git提交记录
    cat > "$output_file" << EOF
# 🚀 Lumi Assistant ${VERSION}

**此版本包含 $(echo "$commits" | wc -l | tr -d ' ') 个更改**

## What's Changed

EOF
    
    # 按优先级输出分类
    local ordered_categories=(
        "🚀_新功能"
        "🐛_错误修复"
        "⚡_性能优化"
        "♻️_代码重构"
        "🔒_安全修复"
        "📚_文档更新"
        "🧪_测试"
        "🔧_构建和CI"
        "📦_依赖更新"
        "🗑️_移除功能"
        "🔄_其他更改"
    )
    
    local has_changes=false
    for category_file in "${ordered_categories[@]}"; do
        local category_path="${temp_dir}/${category_file}"
        if [ -f "$category_path" ]; then
            local category_name=$(echo "$category_file" | tr '_' ' ')
            echo "### $category_name" >> "$output_file"
            echo "" >> "$output_file"
            cat "$category_path" >> "$output_file"
            echo "" >> "$output_file"
            has_changes=true
        fi
    done
    
    # 清理临时目录
    rm -rf "$temp_dir"
    
    if [ "$has_changes" = false ]; then
        echo "### 🔄 其他更改" >> "$output_file"
        echo "" >> "$output_file"
        echo "- 常规更新和维护" >> "$output_file"
        echo "" >> "$output_file"
    fi
    
    # 添加下载和安装信息
    cat >> "$output_file" << EOF
## 📱 下载说明

本版本提供4种不同架构的APK供下载：

### 🎯 特定架构版本（推荐，体积更小）
- **ARM32 (armeabi-v7a)**: 适用于32位ARM设备
- **ARM64 (arm64-v8a)**: 适用于64位ARM设备（大多数现代Android设备）
- **x64 (x86_64)**: 适用于x86_64架构设备（模拟器等）

### 📦 通用版本
- **Universal**: 包含所有架构，兼容性最好但体积最大

### 🤔 如何选择？
1. **推荐**: 下载ARM64版本（适用于大多数现代Android设备）
2. **不确定**: 下载Universal版本（确保兼容但体积较大）
3. **老设备**: 如果ARM64版本无法安装，尝试ARM32版本

## 📋 安装步骤

1. 根据设备架构下载对应APK文件
2. 允许安装未知来源应用
3. 安装并运行

## ⚠️ 开发版本

此为开发测试版本，可能包含未完成功能和已知问题。

## 🐛 问题反馈

遇到问题请在 [Issues](https://github.com/${GITHUB_REPOSITORY}/issues) 反馈。

---
*🤖 自动生成于 $(date -u +'%Y-%m-%d %H:%M:%S UTC')*
EOF
    
    log_success "变更日志已生成: $output_file"
    
    # 显示预览
    echo ""
    echo "========== Release Notes 预览 =========="
    head -20 "$output_file"
    echo "..."
    echo "========================================"
}

# 输出到GitHub Actions环境
output_to_github() {
    if [ -n "${GITHUB_OUTPUT}" ]; then
        echo "changelog-path=${REPO_ROOT}/release_notes.md" >> ${GITHUB_OUTPUT}
        log_success "变更日志路径已输出到GitHub Actions环境"
    fi
}

# 主函数
main() {
    log_info "开始生成自动化变更日志..."
    
    generate_changelog
    output_to_github
    
    log_success "自动化变更日志生成完成！"
}

# 处理命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --since-tag)
            SINCE_TAG="$2"
            shift 2
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        --build-number)
            BUILD_NUMBER="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --since-tag TAG      从指定tag开始生成变更日志"
            echo "  --version VERSION    版本号"
            echo "  --build-number NUM   构建号"
            echo "  --help, -h           显示帮助信息"
            echo ""
            echo "Environment Variables:"
            echo "  VERSION              版本号 (默认: 0.1.0-pre)"
            echo "  BUILD_NUMBER         构建号 (默认: 当前时间戳)"
            echo "  SINCE_TAG            起始tag"
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