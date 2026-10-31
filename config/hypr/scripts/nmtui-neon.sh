#!/usr/bin/env bash
export NEWT_COLORS="
root=,black
roottext=cyan,black
window=white,black
border=cyan,black
shadow=,black
title=magenta,black
label=white,black
textbox=white,black
acttextbox=black,cyan
button=black,cyan
actbutton=black,magenta
compactbutton=cyan,black
entry=cyan,black
disentry=gray,black
checkbox=cyan,black
actcheckbox=black,magenta
listbox=white,black
actlistbox=black,magenta
sellistbox=cyan,black
actsellistbox=black,magenta
helpline=cyan,black
emptyscale=,black
fullscale=,cyan
"
exec nmtui
