#!/bin/sh
if [ -n "$OLD_XDG_CONFIG_HOME" ]; then
  export XDG_CONFIG_HOME="$OLD_XDG_CONFIG_HOME"
else
  unset XDG_CONFIG_HOME
fi
exec fish
