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
  if [ -f "$HOME/bin/bashrc" ]; then
    source "$HOME/bin/bashrc"
  fi

  export PATH="$HOME/bin:$PATH"
fi

