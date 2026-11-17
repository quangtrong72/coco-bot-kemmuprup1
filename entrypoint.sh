#!/bin/bash
GAME_DIR="/app/game_data"
LOG_FILE="$GAME_DIR/logs/latest.log"

MC_USER="${MC_USER:-Kemmuprup1}"
MC_PASS="${MC_PASS:-722006}"
MC_SERVER="${MC_SERVER:-coco.ultramc.co}"
MC_RAM="${MC_RAM:-4500M}"

cd "$GAME_DIR" || exit 1

send_cmd() {
    JAVA_PID=$(pgrep -n java)
    [ -z "$JAVA_PID" ] && return
    export DISPLAY=$(tr '\0' '\n' < /proc/$JAVA_PID/environ 2>/dev/null | grep '^DISPLAY=' | cut -d= -f2)
    export XAUTHORITY=$(tr '\0' '\n' < /proc/$JAVA_PID/environ 2>/dev/null | grep '^XAUTHORITY=' | cut -d= -f2)
    xdotool key t
    sleep 0.5
    xdotool type --delay 50 "$1"
    sleep 0.5
    xdotool key Return
}

watch_log() {
    sleep 15
    tail -n 0 -F "$LOG_FILE" 2>/dev/null | while read -r line; do
        if echo "$line" | grep -q "Nhập /login"; then
            echo "[AUTO] Phat hien yeu cau dang nhap -> Gui /login..."
            sleep 2
            send_cmd "/login $MC_PASS"
        elif echo "$line" | grep -q "Nhập /register"; then
            echo "[AUTO] Tai khoan moi -> Gui /register..."
            sleep 2
            send_cmd "/register $MC_PASS $MC_PASS"
        fi

        if echo "$line" | grep -Eq "Disconnected|Connection lost|Timed out|Internal Exception|ngắt kết nối|mất kết nối"; then
            echo "[AUTO] Bi dis khoi server! Cho 15 giay roi ket noi lai..."
            sleep 15
            pkill -9 java
        fi
    done
}

watch_log &
WATCHER_PID=$!
trap "kill $WATCHER_PID 2>/dev/null; pkill -9 java; pkill -9 Xvfb; exit" SIGINT SIGTERM

while true; do
    echo "[AUTO] Dang khoi dong Minecraft cho acc: $MC_USER..."
    pkill -9 Xvfb 2>/dev/null
    xvfb-run -a -s "-screen 0 640x480x16" portablemc --main-dir "$GAME_DIR" start fabric:1.21.1 -u "$MC_USER" --join-server "$MC_SERVER" --jvm-arg="-Xmx$MC_RAM"
    echo "[AUTO] Game da tat. Khoi dong lai sau 10 giay..."
    sleep 10
done
