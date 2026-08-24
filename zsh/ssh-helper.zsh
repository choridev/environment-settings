# =========================
# SSH Helper for zsh
# Requires: fzf, ssh-keyscan
# =========================

_ssha_cache_dir="$HOME/.cache/ssha"
_ssha_reachable_cache="$_ssha_cache_dir/reachable.txt"
_ssha_unreachable_cache="$_ssha_cache_dir/unreachable.txt"
_ssha_check_pid_file="$_ssha_cache_dir/check.pid"

# ======== Auto-generate helper scripts ========

_ssha_ensure_scripts() {
  mkdir -p "$_ssha_cache_dir"

  # Preview script (called by fzf --preview)
  local preview="$_ssha_cache_dir/preview.sh"
  if [[ ! -f "$preview" ]]; then
    cat > "$preview" <<'PREVIEW_EOF'
#!/usr/bin/env bash
h="$1"
h=$(echo "$h" | sed 's/^[●○] //;s/^  //;s/\x1b\[[0-9;]*m//g')

GRN='\033[32m' RED='\033[31m' YLW='\033[33m'
DIM='\033[2m' BLD='\033[1m' RST='\033[0m'

config_info=$(ssh -G "$h" 2>/dev/null)
if [[ -z "$config_info" ]]; then
  echo -e "${RED}●${RST} ${BLD}$h${RST}"
  echo -e "  ${DIM}(config not found)${RST}"
  exit 0
fi

user=$(echo "$config_info" | awk 'tolower($1)=="user"{print $2; exit}')
hostname=$(echo "$config_info" | awk 'tolower($1)=="hostname"{print $2; exit}')
port=$(echo "$config_info" | awk 'tolower($1)=="port"{print $2; exit}')
proxyjump=$(echo "$config_info" | awk 'tolower($1)=="proxyjump"{print $2; exit}')
identity=$(echo "$config_info" | awk 'tolower($1)=="identityfile"{print $2; exit}')

echo -e "  ${BLD}$h${RST}"
echo ""
echo -e "  ${DIM}User${RST}       ${user:-<default>}"
echo -e "  ${DIM}HostName${RST}   ${hostname:-<unknown>}"
[[ -n "$port" && "$port" != "22" ]] && echo -e "  ${DIM}Port${RST}       $port"
[[ -n "$identity" ]] && echo -e "  ${DIM}Identity${RST}   $identity"
[[ -n "$proxyjump" && "$proxyjump" != "none" ]] && echo -e "  ${DIM}ProxyJump${RST}  $proxyjump"
echo ""
echo -en "  ${DIM}Status${RST}     "

if [[ -n "$proxyjump" && "$proxyjump" != "none" ]]; then
  echo -e "${YLW}via ProxyJump${RST} ${DIM}($proxyjump)${RST}"
else
  target_host="${hostname:-$h}"
  target_port="${port:-22}"
  if ssh-keyscan -T 5 -p "$target_port" "$target_host" 2>/dev/null | grep -q .; then
    echo -e "${GRN}reachable${RST} ${DIM}($target_host:$target_port)${RST}"
  else
    echo -e "${RED}unreachable${RST} ${DIM}($target_host:$target_port)${RST}"
  fi
fi
PREVIEW_EOF
    chmod +x "$preview"
  fi

  # Check-worker script (called by ssha-check)
  local worker="$_ssha_cache_dir/check-worker.sh"
  if [[ ! -f "$worker" ]]; then
    cat > "$worker" <<'WORKER_EOF'
#!/usr/bin/env bash
cache_dir="$HOME/.cache/ssha"
hosts_file="$cache_dir/hosts.txt"
targets_file="$cache_dir/targets.tmp"
results_file="$cache_dir/results.tmp"

if [[ "$1" == "--check-one" ]]; then
  IFS=$'\t' read -r host target port <<< "$2"
  if ssh-keyscan -T 5 -p "$port" "$target" 2>/dev/null | grep -q .; then
    printf 'ok\t%s\n' "$host"
  else
    printf 'ng\t%s\n' "$host"
  fi
  exit 0
fi

[[ -f "$hosts_file" ]] || exit 1

trap 'rm -f "$targets_file" "$results_file" "$cache_dir/check.pid"' EXIT

while IFS= read -r host; do
  [[ -z "$host" ]] && continue
  info=$(ssh -G "$host" 2>/dev/null)
  proxyjump=$(echo "$info" | awk 'tolower($1)=="proxyjump"{print $2; exit}')
  if [[ -n "$proxyjump" && "$proxyjump" != "none" ]]; then
    continue
  fi
  hostname=$(echo "$info" | awk 'tolower($1)=="hostname"{print $2; exit}')
  port=$(echo "$info" | awk 'tolower($1)=="port"{print $2; exit}')
  printf '%s\t%s\t%s\n' "$host" "${hostname:-$host}" "${port:-22}"
done < "$hosts_file" > "$targets_file"

: > "$results_file"
if [[ -s "$targets_file" ]]; then
  xargs -a "$targets_file" -P 50 -I{} "$0" --check-one {} > "$results_file"
fi

awk -F'\t' '$1=="ok"{print $2}' "$results_file" | sort -u > "$cache_dir/reachable.txt"
awk -F'\t' '$1=="ng"{print $2}' "$results_file" | sort -u > "$cache_dir/unreachable.txt"

r=$(wc -l < "$cache_dir/reachable.txt")
u=$(wc -l < "$cache_dir/unreachable.txt")
echo "Done: $r reachable, $u unreachable"
WORKER_EOF
    chmod +x "$worker"
  fi
}

# Generate scripts on source
_ssha_ensure_scripts

# ======== Config file collection ========

_ssha_collect_files() {
  setopt localoptions extendedglob
  local start="${1:-$HOME/.ssh/config}"
  local -a stack
  local -A seen
  [[ -f "$start" ]] || return 0
  stack+=("$start")
  local f rf dir inc base m
  local -a matches
  while (( ${#stack[@]} )); do
    f="${stack[-1]}"; stack[-1]=()
    rf="$(readlink -f -- "$f" 2>/dev/null || echo "$f")"
    [[ -n "$rf" && -r "$rf" ]] || continue
    [[ -n "${seen[$rf]}" ]] && continue
    seen[$rf]=1
    print -r -- "$rf"
    dir="${rf:h}"
    while IFS= read -r inc; do
      case "$inc" in
        /*|~*) base="$inc" ;;
        ./*)  base="$dir/${inc#./}" ;;
        *)    base="$dir/$inc" ;;
      esac
      matches=(${~base}(N))
      (( ${#matches[@]} )) || matches=("$base")
      for m in "${matches[@]}"; do
        [[ -f "$m" ]] && stack+=("$m")
      done
    done < <(awk 'tolower($1)=="include"{for(i=2;i<=NF;i++) print $i}' "$rf" 2>/dev/null)
  done
}

# ======== Host list caching ========

_ssha_list_hosts() {
  local -a files; files=($(_ssha_collect_files "$HOME/.ssh/config"))
  (( ${#files[@]} )) || { echo "No SSH config files found." >&2; return 1; }

  mkdir -p "$_ssha_cache_dir"
  local cache_file="$_ssha_cache_dir/hosts.txt"
  local mtime_file="$_ssha_cache_dir/hosts.mtime"

  local current_mtime="" f mt
  for f in "${files[@]}"; do
    mt=$(stat -c '%Y' "$f" 2>/dev/null || stat -f '%m' "$f" 2>/dev/null || echo 0)
    current_mtime+="${f}:${mt};"
  done

  local cached_mtime=""
  [[ -f "$mtime_file" ]] && cached_mtime=$(<"$mtime_file")

  if [[ "$current_mtime" == "$cached_mtime" && -f "$cache_file" && -s "$cache_file" ]]; then
    cat "$cache_file"
    return 0
  fi

  local result
  result=$(awk '
    tolower($1)=="host" {
      for (i=2;i<=NF;i++) if ($i !~ /[*?]/) print $i
    }
  ' "${files[@]}" 2>/dev/null | sort -u)

  print -r -- "$result" > "$cache_file"
  print -r -- "$current_mtime" > "$mtime_file"
  print -r -- "$result"
}

# ======== User commands ========

ssha-cache-clear() {
  rm -f "$_ssha_cache_dir/hosts.txt" "$_ssha_cache_dir/hosts.mtime"
  rm -f "$_ssha_cache_dir/preview.sh" "$_ssha_cache_dir/check-worker.sh"
  rm -f "$_ssha_check_pid_file"
  echo "ssha cache cleared. Scripts will regenerate on next source."
}

ssha-status() {
  local r=0 u=0
  [[ -f "$_ssha_cache_dir/reachable.txt" ]] && r=$(wc -l < "$_ssha_cache_dir/reachable.txt")
  [[ -f "$_ssha_cache_dir/unreachable.txt" ]] && u=$(wc -l < "$_ssha_cache_dir/unreachable.txt")

  case "${1:-}" in
    up|reachable)
      [[ -f "$_ssha_cache_dir/reachable.txt" ]] && cat "$_ssha_cache_dir/reachable.txt" || echo "No data. Run ssha-check first."
      ;;
    down|unreachable)
      [[ -f "$_ssha_cache_dir/unreachable.txt" ]] && cat "$_ssha_cache_dir/unreachable.txt" || echo "No data. Run ssha-check first."
      ;;
    *)
      echo "Reachable:   $r"
      echo "Unreachable: $u"
      echo ""
      echo "Usage: ssha-status [up|down]"
      ;;
  esac
}

ssha-check() {
  local hosts_file="$_ssha_cache_dir/hosts.txt"
  if [[ ! -f "$hosts_file" ]]; then
    echo "Run ssha first to generate host list." >&2
    return 1
  fi

  echo "Checking reachability for all hosts (background)..."
  "$_ssha_cache_dir/check-worker.sh" &!
  print -r -- "$!" > "$_ssha_check_pid_file"
}

# ======== Reachability ========

_ssha_auto_check() {
  if [[ -f "$_ssha_check_pid_file" ]]; then
    local pid; pid=$(<"$_ssha_check_pid_file")
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      return
    fi
    rm -f "$_ssha_check_pid_file"
  fi

  local max_age=86400
  if [[ ! -f "$_ssha_reachable_cache" ]] || \
     (( $(date +%s) - $(stat -c '%Y' "$_ssha_reachable_cache" 2>/dev/null || echo 0) > max_age )); then
    ssha-check
  fi
}

_ssha_colorize_hosts() {
  local -A reachable_set unreachable_set
  local h

  if [[ -f "$_ssha_reachable_cache" ]]; then
    while IFS= read -r h; do
      [[ -n "$h" ]] && reachable_set[$h]=1
    done < "$_ssha_reachable_cache"
  fi

  if [[ -f "$_ssha_unreachable_cache" ]]; then
    while IFS= read -r h; do
      [[ -n "$h" ]] && unreachable_set[$h]=1
    done < "$_ssha_unreachable_cache"
  fi

  local line
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    if [[ -n "${reachable_set[$line]}" ]]; then
      printf '\033[32m●\033[0m %s\n' "$line"
    elif [[ -n "${unreachable_set[$line]}" ]]; then
      printf '\033[31m○\033[0m \033[2m%s\033[0m\n' "$line"
    else
      printf '  %s\n' "$line"
    fi
  done
}

# ======== Host picker + tmux ========

_pick_host() {
  local query="$1"
  local hosts; hosts=$(_ssha_list_hosts)
  [[ -z "$hosts" ]] && { echo "No SSH hosts found in ~/.ssh/config" >&2; return 1; }

  local chosen key
  if command -v fzf >/dev/null 2>&1; then
    local colored_list
    colored_list=$(echo "$hosts" | _ssha_colorize_hosts)

    local -a fzf_opts=(
      --query "${query:-}"
      --prompt='host ▸ '
      --height=40% --reverse
      --ansi
      --exact
      --border=rounded
      --info=inline-right
      --pointer='▸'
      --color='hl:green:bold,hl+:green:bold,pointer:cyan,prompt:cyan,border:240,header:240'
      --preview "$_ssha_cache_dir/preview.sh {}"
      --preview-window='right:50%:wrap'
    )

    local use_expect=0
    if [[ -n "$TMUX" || -n "$ZELLIJ" ]]; then
      # Zellij calls it a tab, Tmux a window; the key is the same either way.
      local hdr=$'\033[2mENTER:connect | ctrl-s:split ─ | ctrl-o:split │ | ctrl-n:new window\033[0m'
      [[ -n "$ZELLIJ" ]] && hdr=$'\033[2mENTER:connect | ctrl-s:split ─ | ctrl-o:split │ | ctrl-n:new tab\033[0m'
      fzf_opts+=(
        --header="$hdr"
        --expect='ctrl-s,ctrl-o,ctrl-n'
      )
      use_expect=1
    else
      fzf_opts+=(--header=$'\033[2mENTER:connect\033[0m')
    fi

    local fzf_result
    fzf_result=$(print -r -- "$colored_list" | fzf "${fzf_opts[@]}")

    [[ -z "$fzf_result" ]] && { echo "Canceled" >&2; return 1; }

    if (( use_expect )); then
      key=$(echo "$fzf_result" | head -1)
      chosen=$(echo "$fzf_result" | sed -n '2p')
    else
      key=""
      chosen="$fzf_result"
    fi

    chosen=$(echo "$chosen" | sed 's/^[●○] //;s/^  //;s/\x1b\[[0-9;]*m//g')
  else
    local filtered
    if [[ -n "$query" ]]; then
      filtered=$(print -r -- "$hosts" | grep -i -- "$query")
    else
      filtered="$hosts"
    fi
    [[ -z "$filtered" ]] && { echo "No match for: $query" >&2; return 1; }
    local -a arr; arr=("${(@f)filtered}")
    local i=1; for h in "${arr[@]}"; do printf '%2d) %s\n' $i "$h"; ((i++)); done
    printf 'Select host #: '; local n; read -r n
    [[ -z "$n" || "$n" -lt 1 || "$n" -gt "${#arr[@]}" ]] && { echo "Canceled" >&2; return 1; }
    chosen="${arr[$n]}"
    key=""
  fi

  [[ -z "$chosen" ]] && { echo "Canceled" >&2; return 1; }
  printf '%s\n%s\n' "$key" "$chosen"
}

_ssha_connect() {
  local key="$1" host="$2"
  shift 2

  # Zellij is checked first so that a Zellij session running inside Tmux —
  # which happens on a machine reached before the .zshrc guard was in place —
  # splits the pane you are actually looking at.
  #
  # The Zellij calls pass argv straight through after '--'. The Tmux ones build
  # a string that a shell re-splits, so a host or argument containing a space
  # survives on the Zellij path and not on the Tmux one.
  case "$key" in
    ctrl-s)
      if [[ -n "$ZELLIJ" ]]; then
        echo "-> zellij pane below: ssh $host $*"
        zellij action new-pane -d down -- ssh "$host" "$@"
        return
      elif [[ -n "$TMUX" ]]; then
        echo "-> tmux split horizontal: ssh $host $*"
        tmux split-window "ssh $host $*"
        return
      fi
      ;;
    ctrl-o)
      if [[ -n "$ZELLIJ" ]]; then
        echo "-> zellij pane right: ssh $host $*"
        zellij action new-pane -d right -- ssh "$host" "$@"
        return
      elif [[ -n "$TMUX" ]]; then
        echo "-> tmux split vertical: ssh $host $*"
        tmux split-window -h "ssh $host $*"
        return
      fi
      ;;
    ctrl-n)
      if [[ -n "$ZELLIJ" ]]; then
        echo "-> zellij tab: ssh $host $*"
        zellij action new-tab -n "$host" -- ssh "$host" "$@"
        return
      elif [[ -n "$TMUX" ]]; then
        echo "-> tmux window: ssh $host $*"
        tmux new-window -n "$host" "ssh $host $*"
        return
      fi
      ;;
  esac

  echo "-> ssh $host $*"
  ssh "$host" "$@"
}

# ======== Main commands ========

ssha() {
  local query="$1"; shift 2>/dev/null || true
  _ssha_list_hosts >/dev/null || return 1
  _ssha_auto_check
  local result; result=$(_pick_host "$query") || return 1
  local key host
  key=$(echo "$result" | head -1)
  host=$(echo "$result" | sed -n '2p')
  _ssha_connect "$key" "$host" "$@"
}

# ======== TAB-Completion ========

__ssha_hosts() { _ssha_list_hosts 2>/dev/null; }

_ssha_complete() {
  local -a hosts; hosts=("${(@f)$(__ssha_hosts)}"); compadd -a hosts
}
compdef _ssha_complete ssha
# ===================================================
