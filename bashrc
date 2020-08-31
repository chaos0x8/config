#!/usr/bin/bash

if [ -f /etc/skel/.bashrc ]; then
  source /etc/skel/.bashrc
fi

# History options
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoreboth:erasedups

shopt -s histappend

if [ -d "$HOME/bin" ]; then
  export PATH="$HOME/bin:$PATH"
fi

