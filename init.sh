#!/bin/bash
# Check if zsh is installed and set as the default shell
if [ -z "$(command -v zsh)" ]; then
    echo "zsh is not installed. Please install zsh first."
    exit 1
fi

if [ "$SHELL" != "$(command -v zsh)" ]; then
    echo "zsh is not set as the default shell."
    exit 1
fi

# plugin manager https://github.com/zdharma-continuum/zinit
NO_INPUT=1 bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

#### Plugins ####
echo "Installing PIP plugins..."
pip install https://github.com/nvbn/thefuck/archive/master.zip --user
pip install shtab --user

# add content of .zshrc.content to .zshrc
cat .zshrc >> ~/.zshrc

exec zsh