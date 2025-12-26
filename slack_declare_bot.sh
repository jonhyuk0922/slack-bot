#!/bin/bash
export PATH=/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
set -euo pipefail

# ===== .env 파일 로드 =====
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/.env" ]; then
  export $(grep -v '^#' "${SCRIPT_DIR}/.env" | xargs)
fi

# ===== 설정 =====
# 환경변수에서 웹훅 URL 가져오기
WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
if [ -z "$WEBHOOK_URL" ]; then
  echo "Error: SLACK_WEBHOOK_URL environment variable is not set"
  exit 1
fi

MENTION="<@U04HT688648>"   # 박정원 멤버 ID
MODE="${1:-weekday_morning}"  # weekday_morning | weekday_evening | saturday

# 한국 시간
export TZ="Asia/Seoul"
TODAY="$(date '+%Y-%m-%d(%a)')"

send_slack() {
  local MESSAGE="$1"

  curl -sS -X POST \
    -H 'Content-type: application/json; charset=utf-8' \
    --data "{
      \"text\": \"${MESSAGE}\"
    }" \
    "${WEBHOOK_URL}" >/dev/null
}

# =========================
# 메시지 분기
# =========================

if [[ "$MODE" == "weekday_morning" ]]; then
  MESSAGE="[$TODAY 오늘의 선포]

출근길 하루를 선포하며,
저녁에 퇴근길에 하루 선포했던 말씀을 얼마나 이루셨는지 돌아보면 좋을 것 같아요 ㅎㅎ
사랑합니다 ❤️ ${MENTION}"

  send_slack "$MESSAGE"

elif [[ "$MODE" == "weekday_evening" ]]; then
  MESSAGE="오늘도 최고로 수고많았어요! 💛

오늘 하루를 돌아보며
주님이 나를 통해 하신 일들을 적어봐요.
힘든 일이 있다면 맡겨드리고,
감사한 일이 있다면 표현해봐요 🙏"

  send_slack "$MESSAGE"

elif [[ "$MODE" == "saturday" ]]; then
  MESSAGE="[한주를 돌아봅니다]

1. 이번 한주 내가 잘한 것, 배운 것, 개선할 것, 적용점을 한줄씩 적어봅니다.
2. 그리고 토,일 주말을 어떻게 보낼지도 적어봅니다."

  send_slack "$MESSAGE"

else
  echo "사용법:"
  echo "  weekday_morning | weekday_evening | saturday"
  exit 1
fi