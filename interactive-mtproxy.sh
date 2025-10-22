#!/usr/bin/env bash
# interactive-mtproxy.sh
# 用途: 交互式按步骤执行安装 mtproxy 的命令（每步确认）
# 使用: ./interactive-mtproxy.sh [--auto] [--log logfile]
# 说明:
#   --auto : 不询问，自动逐步执行（谨慎）
#   --log  : 将输出和错误追加到指定日志文件

set -u

AUTO=false
LOGFILE=""

# 解析参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    --auto) AUTO=true; shift ;;
    --log) LOGFILE="$2"; shift 2 ;;
    --help|-h) echo "Usage: $0 [--auto] [--log logfile]"; exit 0 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

# 日志函数
log() {
  echo -e "$1"
  if [[ -n "$LOGFILE" ]]; then
    echo -e "$(date +"%F %T") $1" >> "$LOGFILE"
  fi
}

# 确认函数（自动模式直接返回 true）
confirm_step() {
  local prompt="$1"
  if $AUTO ; then
    return 0
  fi
  read -p "$prompt (y/n): " ans
  case "$ans" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

# 步骤定义：每步由说明和命令组成
steps=(
  "第一步：删除旧目录并创建 /home/mtproxy，进入该目录;rm -rf /home/mtproxy && mkdir -p /home/mtproxy && cd /home/mtproxy"
  "第二步：下载 mtproxy 安装脚本;curl -fsSL -o mtproxy.sh https://github.com/ellermister/mtproxy/raw/master/mtproxy.sh"
  "第三步：执行 mtproxy 安装脚本;bash mtproxy.sh"
)

# 主循环
for entry in "${steps[@]}"; do
  desc=$(echo "$entry" | cut -d';' -f1)
  cmd=$(echo "$entry" | cut -d';' -f2-)

  log "----------------------------------------"
  log "步骤: $desc"
  log "命令: $cmd"

  if confirm_step "是否执行此步骤？"; then
    log "执行中..."
    # 在子 shell 中执行以避免改变主脚本的工作目录，除非命令本身包含 cd 并需要影响后续步骤
    if echo "$cmd" | grep -q "cd "/home/mtproxy""; then
      # 如果命令包含进入目录的操作，需要在当前 shell 执行以保留目录
      eval "$cmd"
      rc=$?
    else
      (eval "$cmd")
      rc=$?
    fi

    if [[ $rc -ne 0 ]]; then
      log "❌ 命令返回非零状态: $rc"
      # 在非自动模式下，询问是否继续
      if ! $AUTO ; then
        if confirm_step "命令失败。是否继续执行后续步骤？"; then
          log "继续下一步。"
        else
          log "脚本中止。"
          exit $rc
        fi
      fi
    else
      log "✅ 步骤完成。"
    fi
  else
    log "⏭️ 跳过此步骤。"
  fi
done

log "\n🎉 所有步骤处理完成，脚本退出。"
