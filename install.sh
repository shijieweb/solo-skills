#!/usr/bin/env bash
# SOLO Skills Installer (macOS / Linux)
# 一键安装所有 SOLO 适配技能
# 用法: bash -c "$(curl -fsSL https://raw.githubusercontent.com/lcy362/solo-skills/main/install.sh)"

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

echo -e "\n${CYAN}🧰 SOLO Skills Installer${NC}"
echo -e "${CYAN}========================\n${NC}"

# 检测 SOLO 技能目录
SKILLS_DIR="${HOME}/.trae-cn/skills"

if [ ! -d "$SKILLS_DIR" ]; then
    echo -e "${YELLOW}⚠️  未找到 SOLO 技能目录: $SKILLS_DIR${NC}"
    read -p "请输入 SOLO 技能目录路径 (默认: $SKILLS_DIR): " input
    SKILLS_DIR="${input:-$SKILLS_DIR}"
fi

echo -e "${GREEN}📂 目标安装目录: $SKILLS_DIR${NC}"

# 创建临时目录
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo -e "\n${YELLOW}📥 下载技能仓库...${NC}"
git clone --depth 1 https://github.com/lcy362/solo-skills.git "$TMP_DIR" 2>/dev/null

if [ ! -d "$TMP_DIR" ]; then
    echo -e "${RED}❌ 仓库下载失败${NC}"
    exit 1
fi

# 安装技能
INSTALLED=()
for SKILL_DIR in "find-skills" "self-improving"; do
    SRC="$TMP_DIR/$SKILL_DIR"
    TARGET="$SKILLS_DIR/$SKILL_DIR"
    
    if [ ! -d "$SRC" ]; then
        continue
    fi
    
    if [ -d "$TARGET" ]; then
        echo -e "  ${GRAY}⏭️  $SKILL_DIR — 已存在，跳过${NC}"
        continue
    fi
    
    cp -r "$SRC" "$TARGET"
    INSTALLED+=("$SKILL_DIR")
    echo -e "  ${GREEN}✅ $SKILL_DIR — 安装成功${NC}"
done

echo -e "\n${CYAN}📊 安装摘要:${NC}"
echo -e "    目录: $SKILLS_DIR"
echo -e "${GREEN}    安装: ${#INSTALLED[@]} 个技能${NC}"
for s in "${INSTALLED[@]}"; do
    echo -e "     ${GREEN}✅ $s${NC}"
done

echo -e "\n${CYAN}🎉 安装完成！重启 SOLO 会话后技能生效。${NC}"
echo -e "${YELLOW}   提示：运行 '检查所有技能更新' 可以检查新版本。\n${NC}"
