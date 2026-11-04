#!/usr/bin/env bash
# description: 交互读取端口并停止占用进程，完成后复查占用状态。
# author: zzy
# created: 2026-10-28
# Linux / macOS；兼容 Bash 3.2。使用 root 确保能看到其他用户的端口进程。
set -u
set -o pipefail

printf '%s\n' '关闭指定端口的 TCP 监听 / UDP 占用进程；同一进程的其他服务也会停止。'
printf '%s' '请输入端口，多个端口用空格分隔: '
IFS= read -r input_text || exit 1
ports=()
read -r -a values <<< "$input_text"
if (( ${#values[@]} == 0 )); then
    printf '%s\n' '没有输入端口。' >&2
    exit 1
fi
for value in "${values[@]}"; do
    if [[ ! "$value" =~ ^[0-9]{1,5}$ ]]; then
        printf '无效端口：%s（必须是 1-65535）\n' "$value" >&2
        exit 1
    fi
    port=$((10#$value))
    if (( port < 1 || port > 65535 )); then
        printf '无效端口：%s（必须是 1-65535）\n' "$value" >&2
        exit 1
    fi
    ports+=("$port")
done

if (( EUID != 0 )); then
    printf '%s\n' '请使用 sudo bash 运行本脚本，以完整查询和停止其他用户的进程。' >&2
    exit 1
fi
if command -v lsof >/dev/null 2>&1; then
    backend=lsof
elif command -v ss >/dev/null 2>&1; then
    backend=ss
else
    printf '%s\n' '需要安装 lsof（Linux/macOS）或 ss（Linux iproute2）。' >&2
    exit 1
fi

# 返回端口对应的 PID；查询出错时退出，不能报告为空闲。
find_pids() {
    local port="$1" output status protocol
    if [[ "$backend" == lsof ]]; then
        for protocol in TCP UDP; do
            if [[ "$protocol" == TCP ]]; then
                output=$(lsof -nP -t -iTCP:"$port" -sTCP:LISTEN)
            else
                # -iUDP:port 也会匹配远端端口，因此按本地端点单独过滤。
                output=$(lsof -nP -iUDP -Fpn)
            fi
            status=$?
            # lsof 在没有匹配时返回 1。
            if (( status > 1 )); then return "$status"; fi
            if [[ "$protocol" == UDP ]]; then
                printf '%s\n' "$output" | awk -v port="$port" '
                    /^p/ { owner = substr($0, 2) }
                    /^n/ {
                        split(substr($0, 2), endpoint, "->")
                        count = split(endpoint[1], parts, ":")
                        if (parts[count] == port) print owner
                    }'
            else
                [[ -z "$output" ]] || printf '%s\n' "$output"
            fi
        done
    else
        # UDP 包括已连接的套接字，TCP 仅选择监听套接字。
        output=$(ss -H -ltnp "sport = :$port") || return 2
        output="$output
$(ss -H -aunp "sport = :$port")" || return 2
        if [[ -n "${output//[[:space:]]/}" ]]; then
            if [[ "$output" != *pid=* ]]; then
                printf '端口 %s 被占用，但无法识别 PID。\n' "$port" >&2
                return 2
            fi
            printf '%s\n' "$output" | grep -oE 'pid=[0-9]+' | cut -d= -f2
        fi
    fi
    return 0
}

targets=""
for port in "${ports[@]}"; do
    found=$(find_pids "$port") || exit 1
    if [[ -z "$found" ]]; then
        printf '端口 %s 未被服务占用。\n' "$port"
    else
        while IFS= read -r process_id; do
            [[ "$process_id" =~ ^[0-9]+$ ]] || exit 1
            printf '端口 %s -> PID %s\n' "$port" "$process_id"
        done <<< "$found"
        targets="$targets
$found"
    fi
done
targets=$(printf '%s\n' "$targets" | awk 'NF && !seen[$0]++')
failed=0
while IFS= read -r process_id; do
    [[ -n "$process_id" ]] || continue
    if (( process_id <= 1 || process_id == $$ || process_id == PPID )); then
        printf '跳过系统、当前脚本或父进程 PID %s。\n' "$process_id" >&2
        failed=1
        continue
    fi
    kill -0 "$process_id" 2>/dev/null || continue
    printf '正在停止 PID %s\n' "$process_id"
    if ! kill -TERM "$process_id"; then
        failed=1
        continue
    fi
    for attempt in 1 2 3 4 5; do
        kill -0 "$process_id" 2>/dev/null || break
        sleep 1
    done
    if kill -0 "$process_id" 2>/dev/null; then
        # 仅当它仍占用所选端口时强制停止。
        still_owner=0
        for port in "${ports[@]}"; do
            found=$(find_pids "$port") || exit 1
            if printf '%s\n' "$found" | grep -qx "$process_id"; then
                still_owner=1
            fi
        done
        if (( still_owner )); then
            kill -KILL "$process_id" || failed=1
        fi
    fi
done <<< "$targets"

# 给内核短暂时间回收套接字。
[[ -z "$targets" ]] || sleep 1
for port in "${ports[@]}"; do
    remaining=$(find_pids "$port") || exit 1
    if [[ -n "$remaining" ]]; then
        printf '端口 %s 仍被占用，请检查服务是否自动重启（PID：%s）。\n' "$port" "$remaining" >&2
        failed=1
    else
        printf '端口 %s 已空闲。\n' "$port"
    fi
done
exit "$failed"
