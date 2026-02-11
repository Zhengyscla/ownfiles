#!/bin/sh

BOT_TOKEN="8146296148:AAGRAV_DsuCc4WyGeaT1X42uBpnTCCSwJKQ"
CHAT_ID="7398915507"


IP="$PAM_RHOST"
USER="$PAM_USER"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
HOST=$(hostname)

# 只在真实交互式 SSH 登录时触发
[ "$PAM_TYPE" != "open_session" ] && exit 0
[ -z "$PAM_TTY" ] && exit 0

# 如果没有来源IP（例如本地tty登录）则退出
[ -z "$IP" ] && exit 0

# 过滤内网IP
#case "$IP" in
#    192.168.*|10.*|172.16.*|127.0.0.1)
 #       exit 0
#        ;;
#esac

# 查询国家
COUNTRY=$(curl -s --max-time 3 "https://api.country.is/$IP" \
          | sed -n 's/.*"country":"\([^"]*\)".*/\1/p')

[ -z "$COUNTRY" ] && COUNTRY="Unknown"

TEXT="🔐 SSH Login Alert

Host: $HOST
User: $USER
IP: $IP
Country: $COUNTRY
Time: $DATE"

# 后台发送，不阻塞登录
(
curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
     -d chat_id="$CHAT_ID" \
     -d text="$TEXT" > /dev/null 2>&1
) &

exit 0
