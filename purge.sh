#!/bin/bash
pip uninstall thefuck -y
rm -rf ~/.oh-my-zsh
rm -rf ~/.local/share/zinit/
rm -rf "${ZINIT[HOME_DIR]}"
rm -rf ~/.zshrc