#!/bin/bash/command
input=$(cat)

# Approximate USD -> THB rate; adjust as needed.
USD_TO_THB=35

read -r DIR MODEL COST COST_THB PCT CR5H CR7D <<< "$(echo "$input" | node -e '
const rate = Number(process.argv[1]);
let d = "";
process.stdin.on("data", c => d += c);
process.stdin.on("end", () => {
  const j = JSON.parse(d);
  const dir = (j.workspace && j.workspace.current_dir) || "";
  const model = ((j.model && (j.model.display_name || j.model.id)) || "").replace(/\s+/g, "_");
  const cost = (j.cost && j.cost.total_cost_usd) || 0;
  const pct = Math.round((j.context_window && j.context_window.used_percentage) || 0);
  const cr5h = Math.round((j.rate_limits && j.rate_limits.five_hour && j.rate_limits.five_hour.used_percentage) || 0);
  const cr7d = Math.round((j.rate_limits && j.rate_limits.seven_day && j.rate_limits.seven_day.used_percentage) || 0);
  process.stdout.write(`${dir} ${model || "-"} ${cost.toFixed(2)} ${(cost * rate).toFixed(2)} ${pct} ${cr5h} ${cr7d}`);
});
' "$USD_TO_THB")"
MODEL=${MODEL//_/ }

BRANCH=""
if git --no-optional-locks -C "$DIR" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  BRANCH=$(git --no-optional-locks -C "$DIR" branch --show-current 2>/dev/null)
fi

CYAN=$'\033[36m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; DIM=$'\033[2m'; RESET=$'\033[0m'
MINT=$'\033[38;5;121m'; SUN=$'\033[38;5;220m'; CORAL=$'\033[38;5;209m'; PINK=$'\033[38;5;204m'; EMPTY_C=$'\033[38;5;238m'
VIOLET=$'\033[38;5;183m'

# Each bar keeps its emoji's hue but deepens as usage climbs: light at <40%, the emoji's
# base shade at 40-69%, a bold deep shade at >=70%.
shade_for() {
  local light=$1 base=$2 deep=$3 pct=$4
  if   [ "$pct" -ge 70 ]; then printf '\033[1;38;5;%sm' "$deep"
  elif [ "$pct" -ge 40 ]; then printf '\033[38;5;%sm' "$base"
  else                         printf '\033[38;5;%sm' "$light"
  fi
}

PCT_COLOR=$(shade_for 218 204 199 "$PCT")     # 🧠 pink family
CR5H_COLOR=$(shade_for 222 220 208 "$CR5H")   # ⏳ sun/gold family
CR7D_COLOR=$(shade_for 210 203 196 "$CR7D")   # 📅 red family

make_bar() {
  local pct=$1 color=$2 filled empty fill pad
  filled=$((pct / 10))
  [ "$filled" -gt 10 ] && filled=10
  empty=$((10 - filled))
  printf -v fill "%${filled}s" ""
  printf -v pad "%${empty}s" ""
  printf '%s%s%s%s%s' "$color" "${fill// /█}" "$EMPTY_C" "${pad// /░}" "$RESET"
}

CTX_BAR=$(make_bar "$PCT" "$PCT_COLOR")
CR5H_BAR=$(make_bar "$CR5H" "$CR5H_COLOR")
CR7D_BAR=$(make_bar "$CR7D" "$CR7D_COLOR")

COST_FMT=$(printf '$%s (฿%s)' "$COST" "$COST_THB")

if [ -n "$BRANCH" ]; then
  HEAD=$(printf "🌿 ${MINT}%s${RESET} 🤖 ${VIOLET}%s${RESET} 📁 ${CYAN}%s${RESET}" "$BRANCH" "$MODEL" "$DIR")
else
  HEAD=$(printf "🤖 ${VIOLET}%s${RESET} 📁 ${CYAN}%s${RESET}" "$MODEL" "$DIR")
fi

printf "%s | 💰 ${SUN}%s${RESET}\n" "$HEAD" "$COST_FMT"
printf "🧠 ${DIM}ctx${RESET}  %s ${PCT_COLOR}%3d%%${RESET}  ${DIM}|${RESET}  ⏳ ${DIM}5h${RESET} %s ${CR5H_COLOR}%3d%%${RESET}  ${DIM}|${RESET}  📅 ${DIM}7d${RESET} %s ${CR7D_COLOR}%3d%%${RESET}\n" "$CTX_BAR" "$PCT" "$CR5H_BAR" "$CR5H" "$CR7D_BAR" "$CR7D"

