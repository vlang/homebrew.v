#!/bin/bash
# Warm-cache install/uninstall benchmark: brew.v (native V) vs Ruby Homebrew.
#
# Both frontends run the same operation from the same starting state:
#   install:   neovim absent, all 10 dependencies present, bottle + manifest in cache
#   uninstall: neovim present
# Ruby autoremove is disabled so both remove exactly one keg.
set -u

REPO=/Users/alex/code/brew.v
BREW_V="$REPO/brew-v"
BREW_RB=/opt/homebrew/bin/brew
CELLAR=/opt/homebrew/Cellar
DEPS="gettext json-c libunistring libuv lpeg luajit luv tree-sitter unibilium utf8proc"
RUNS="${RUNS:-5}"
OUT="$REPO/bench/results.tsv"

# Homebrew's own dev-cmd/benchmark.rb BENCHMARK_ENV, so the Ruby side does no
# analytics, auto-update, autoremove, cleanup or dependents check.
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_AUTOREMOVE=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
export HOMEBREW_NO_INSTALL_CLEANUP=1

log() { printf '%s\n' "$*" >&2; }

ensure_deps() {
  for d in $DEPS; do
    [ -d "$CELLAR/$d" ] || { log "  (restoring deps)"; "$BREW_RB" install --only-dependencies neovim >/dev/null 2>&1; return; }
  done
}

ensure_absent() { [ -d "$CELLAR/neovim" ] && "$BREW_RB" uninstall --ignore-dependencies neovim >/dev/null 2>&1; ensure_deps; }
ensure_present() { [ -d "$CELLAR/neovim" ] || "$BREW_RB" install neovim >/dev/null 2>&1; }

# measure <tool> <op> <iteration> -- runs the command under /usr/bin/time -l and
# appends one TSV row: tool op iter real user sys maxrss_bytes footprint_bytes exit
measure() {
  local tool=$1 op=$2 iter=$3 bin
  case "$tool" in v) bin="$BREW_V";; rb) bin="$BREW_RB";; esac
  local t="/tmp/bench-time.$$" o="/tmp/bench-out.$$"
  /usr/bin/time -l "$bin" "$op" neovim >"$o" 2>"$t"
  local rc=$?
  local real user sys rss foot
  real=$(awk '/ real /{print $1}' "$t" | tail -1)
  user=$(awk '/ real /{print $3}' "$t" | tail -1)
  sys=$(awk '/ real /{print $5}' "$t" | tail -1)
  rss=$(awk '/maximum resident set size/{print $1}' "$t" | tail -1)
  foot=$(awk '/peak memory footprint/{print $1}' "$t" | tail -1)
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$tool" "$op" "$iter" "$real" "$user" "$sys" "$rss" "$foot" "$rc" >>"$OUT"
  log "  $tool $op #$iter: ${real}s real, $((rss/1048576)) MB rss, exit $rc"
  [ $rc -ne 0 ] && { log "    --- stderr ---"; grep -v -e ' real ' -e 'resident\|memory\|page\|swap\|block\|message\|signal\|context\|instructions\|cycles\|footprint\|shared\|unshared' "$t" | head -5 >&2; }
  rm -f "$t" "$o"
}

printf 'tool\top\titer\treal\tuser\tsys\tmaxrss\tfootprint\texit\n' >"$OUT"

log "== warm-up (not recorded) =="
ensure_absent; "$BREW_V" install neovim >/dev/null 2>&1; "$BREW_V" uninstall neovim >/dev/null 2>&1
ensure_absent; "$BREW_RB" install neovim >/dev/null 2>&1; "$BREW_RB" uninstall neovim >/dev/null 2>&1

for i in $(seq 1 "$RUNS"); do
  log "== iteration $i/$RUNS =="
  # Rotate order each iteration so neither tool always runs from the same position.
  if [ $((i % 2)) -eq 1 ]; then order="v rb"; else order="rb v"; fi
  for tool in $order; do
    ensure_absent
    measure "$tool" install "$i"
    ensure_present
    measure "$tool" uninstall "$i"
  done
done

ensure_absent
log "== done; results in $OUT =="
