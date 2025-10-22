#!/usr/bin/env bash
# =========================================
# 🧰 TG 代理一键菜单脚本（交互式）
# =========================================

set -e

# 函数：确认执行
confirm() {
  read -p "$1 (y/n): " choice
  case "$choice" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

# 安装 TG 代理
install_mtproxy() {
  echo "------------------------------"
  echo "🚀 安装 TG 代理 (MTProxy)"
  echo "------------------------------"

  steps=(
    "第一步：删除旧目录并创建 /home/mtproxy;rm -rf /home/mtproxy && mkdir -p /home/mtproxy && cd /home/mtproxy"
    "第二步：下载 mtproxy 安装脚本;curl -fsSL -o mtproxy.sh https://github.com/ellermister/mtproxy/raw/master/mtproxy.sh"
    "第三步：执行安装脚本;bash mtproxy.sh"
  )

  for step in "${steps[@]}"; do
    desc=$(echo "$step" | cut -d';' -f1)
    cmd=$(echo "$step" | cut -d';' -f2-)
    echo
    echo "$desc"
    confirm "是否执行此步骤？" && eval "$cmd" && echo "✅ 已完成" || echo "⏭️ 已跳过"
  done

  echo "🎉 安装流程结束。"
}

# 卸载 TG 代理
uninstall_mtproxy() {
  echo "------------------------------"
  echo "🧹 卸载 TG 代理"
  echo "------------------------------"
  confirm "确定要删除 /home/mtproxy 吗？此操作不可恢复！" && \
  rm -rf /home/mtproxy && echo "✅ 已卸载 MTProxy。" || \
  echo "⏭️ 已取消卸载。"
}

# 主菜单
while true; do
  clear
  echo "=========================================="
  echo "🌐 TG 代理安装/卸载脚本"
  echo "=========================================="
  echo "1) 安装 TG 代理"
  echo "2) 卸载 TG 代理"
  echo "3) 退出"
  echo "------------------------------------------"
  read -p "请选择操作 [1-3]: " choice

  case "$choice" in
    1) install_mtproxy ;;
    2) uninstall_mtproxy ;;
    3) echo "👋 已退出。"; exit 0 ;;
    *) echo "❌ 无效选项，请输入 1-3。"; sleep 1 ;;
  esac

  echo
  read -p "按 Enter 返回菜单..." _
done
