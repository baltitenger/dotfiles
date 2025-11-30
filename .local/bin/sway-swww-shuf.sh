#!/bin/bash

cd ~/Pictures/backgrounds/apod

rm -f "$XDG_RUNTIME_DIR"/swww-shuf
mkfifo "$XDG_RUNTIME_DIR"/swww-shuf

{
	swaymsg -mt subscribe '["output"]' &
	cat "$XDG_RUNTIME_DIR"/swww-shuf &
	exec 3>"$XDG_RUNTIME_DIR"/swww-shuf
	while sleep 15m; do echo; done
} | while read x; do
	for out in `swaymsg -t get_outputs | jq -r '.[] | select(.active and .power) .name'`; do
		[ -z "$x" -o ! -f ~/.cache/swww/"$out" ] &&
			swww img -o "$out" -t any --transition-step 5 `shuf -en1 *`
	done
done

