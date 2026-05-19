#!/usr/bin/env sh
# This wrapper script is invoked by xdg-desktop-portal-termfilechooser.
#
# For more information about input/output arguments read `xdg-desktop-portal-termfilechooser(5)`

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"
debug="$6"

set -e

if [ "$debug" = 1 ]; then
  set -x
fi

cmd="yazi"

termcmd="${TERMCMD:-ghostty --title 'termfilechooser' -e}"

# Force absolute directory targets to prevent the Desktop directory fallback
export YAZI_CWD="${path:-/home/elichall}"

if [ "$save" = "1" ]; then
  exec ghostty --title="termfilechooser" -e yazi --chooser-file="$out" "$YAZI_CWD"
elif [ "$directory" = "1" ]; then
  exec ghostty --title="termfilechooser" -e yazi --chooser-file="$out" --cwd-file="$out.1" "$YAZI_CWD"
elif [ "$multiple" = "1" ]; then
  exec ghostty --title="termfilechooser" -e yazi --chooser-file="$out" "$YAZI_CWD"
else
  exec ghostty --title="termfilechooser" -e yazi --chooser-file="$out" "$YAZI_CWD"
fi

command="$termcmd $cmd"
for arg in "$@"; do
  # escape double quotes
  escaped=$(printf "%s" "$arg" | sed 's/"/\\"/g')
  # escape special
  command="$command \"$escaped\""
done

sh -c "$command"

if [ "$directory" = "1" ]; then
  if [ ! -s "$out" ] && [ -s "$out"".1" ]; then
    cat "$out"".1" >"$out"
    rm "$out"".1"
  else
    rm "$out"".1"
  fi
fi
