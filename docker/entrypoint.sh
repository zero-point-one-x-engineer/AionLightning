#!/bin/bash
set -euo pipefail

ROLE="${1:-}"
DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_PASSWORD="${DB_PASSWORD:-aion}"
GAME_IP="${GAME_IP:-127.0.0.1}"
LOGIN_HOST="${LOGIN_HOST:-login}"
CHAT_HOST="${CHAT_HOST:-chat}"
CHATSERVER_ENABLE="${CHATSERVER_ENABLE:-true}"

case "$ROLE" in
  login)
    CD=/opt/aion/login
    cd "$CD"
    sed -i "s|jdbc:mysql://[^:/]*:[0-9]*|jdbc:mysql://${DB_HOST}:${DB_PORT}|" config/network/database.properties
    sed -i "s|^database.user = .*|database.user = ${DB_USER}|" config/network/database.properties
    sed -i "s|^database.password = .*|database.password = ${DB_PASSWORD}|" config/network/database.properties
    exec java -Xms8m -Xmx32m -ea -Xbootclasspath/p:./libs/jsr166-1.7.0.jar -cp "./libs/*" com.aionemu.loginserver.LoginServer
    ;;

  game)
    CD=/opt/aion/game
    cd "$CD"
    sed -i "s|jdbc:mysql://[^:/]*:[0-9]*|jdbc:mysql://${DB_HOST}:${DB_PORT}|" config/network/database.properties
    sed -i "s|^database.user = .*|database.user = ${DB_USER}|" config/network/database.properties
    sed -i "s|^database.password = .*|database.password = ${DB_PASSWORD}|" config/network/database.properties
    sed -i "s|^gameserver.network.login.address = .*|gameserver.network.login.address = ${LOGIN_HOST}:${LOGIN_PORT:-9014}|" config/network/network.properties
    sed -i "s|^gameserver.network.chat.address = .*|gameserver.network.chat.address = ${CHAT_HOST}:${CHAT_PORT:-9021}|" config/network/network.properties
    sed -i "s|default=\"[^\"]*\"|default=\"${GAME_IP}\"|" config/network/ipconfig.xml
    sed -i "s|^gameserver.chatserver.enable = .*|gameserver.chatserver.enable = ${CHATSERVER_ENABLE}|" config/main/gameserver.properties
    mkdir -p log
    exec java -Xms256m -Xmx3072m -XX:MaxPermSize=256m -ea -XX:-UseSplitVerifier -javaagent:./libs/al-commons.jar -cp "./libs/*" com.aionemu.gameserver.GameServer
    ;;

  chat)
    CD=/opt/aion/chat
    cd "$CD"
    sed -i "s|^chatserver.network.client.address = .*|chatserver.network.client.address = 0.0.0.0:10241|" config/chatserver.properties
    sed -i "s|^chatserver.network.gameserver.address = .*|chatserver.network.gameserver.address = 0.0.0.0:9021|" config/chatserver.properties
    mkdir -p log
    exec java -Xms128m -Xmx128m -ea -Xbootclasspath/p:./libs/jsr166-1.7.0.jar -cp "./libs/*" com.aionemu.chatserver.ChatServer
    ;;

  *)
    echo "Error: unknown role '${ROLE}'. Use login, game or chat." >&2
    exit 1
    ;;
esac