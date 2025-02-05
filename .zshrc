# Add to your .zshrc
load_env() {
    local env_file="${1:-$HOME/.env}"
    
    if [[ -f "$env_file" ]]; then
        # Read each line from .env file
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Skip empty lines and comments
            if [[ -z "$line" ]] || [[ "$line" =~ ^# ]]; then
                continue
            fi
            
            # Remove any comments from the line
            line="${line%%#*}"
            # Trim whitespace
            line="${line%%[[:space:]]}"
            
            # Export the variable if it's a valid export statement
            if [[ "$line" =~ ^export ]]; then
                eval "$line"
            # Handle non-export lines with proper format
            elif [[ "$line" =~ ^[[:alnum:]_]+=.* ]]; then
                eval "export $line"
            fi
        done < "$env_file"
        echo "Loaded environment variables from $env_file"
    else
        echo "Environment file $env_file not found"
        return 1
    fi
}

# Auto-load .env file if it exists when shell starts
if [[ -f "$HOME/.env" ]]; then
    load_env
fi

if [[ -n "${GITHUB_TOKEN}" ]]; then
    # Set credential helper to store
    git config --global credential.helper store
    
    # Create or update .git-credentials
    local credentials_file="${HOME}/.git-credentials"
    local github_line="https://${GITHUB_USERNAME:-$(git config user.email)}:${GITHUB_TOKEN}@github.com"
    
    # Remove existing GitHub entry if present
    if [[ -f "$credentials_file" ]]; then
        sed -i '/github.com/d' "$credentials_file"
    fi
    
    # Add new credentials
    echo "$github_line" >> "$credentials_file"
    chmod 600 "$credentials_file"  
fi

# Miniconda installation check and setup
if [ ! -d "$HOME/miniconda3" ]; then
    echo "Miniconda not found. Installing..."
    
    # Download the installer
    if [ "$(uname)" = "Darwin" ]; then
        # macOS
        curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
        MINICONDA_SCRIPT="Miniconda3-latest-MacOSX-x86_64.sh"
    else
        # Linux
        curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        MINICONDA_SCRIPT="Miniconda3-latest-Linux-x86_64.sh"
    fi
    
    # Install Miniconda
    bash $MINICONDA_SCRIPT -b -p $HOME/miniconda3
    rm $MINICONDA_SCRIPT
    
    # Initialize for zsh
    $HOME/miniconda3/bin/conda init zsh
    
    echo "Miniconda installation complete. Please restart your shell."
fi

# Add Miniconda to PATH if it exists
if [ -d "$HOME/miniconda3/bin" ]; then
    export PATH="$HOME/miniconda3/bin:$PATH"
fi

conda config --set auto_activate_base false

# PATH
export PATH=$HOME/.local/bin:$PATH

git config --global user.email "bjyoon513@gmail.com"
git config --global user.name "Byungjun Yoon"
git config --global init.defaultBranch
git config --global pull.rebase true

# Tools
## Fuck
eval $(thefuck --alias)

# Prompt
zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/pure

zinit ice wait lucid from"gh-r" \
    as"program" \
    sbin"fzf" \
    atload'source <(fzf --zsh)' 
zinit light junegunn/fzf

zi ice wait lucid from"gh-r" as"program" sbin"*/bat"
zi light sharkdp/bat

zinit light zsh-users/zsh-autosuggestions
bindkey '^a' autosuggest-accept
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zdharma-continuum/history-search-multi-word

zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit load 'zsh-users/zsh-history-substring-search'
zinit ice wait lucid atload'_history_substring_search_config'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND="bg=cyan,fg=white,bold"
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

zi ice wait lucid from"gh-r" as"program" sbin"eza"
zi light eza-community/eza

zinit wait lucid light-mode for \
    atinit"zicompinit; zicdreplay" \
    atclone"./install.py" \
    atpull'%atclone' \
    as"program" \
    pick"bin/autojump" \
    src"bin/autojump.sh" \
        wting/autojump

zi ice wait lucid from"gh-r" as"program" sbin"navi"
zi light denisidoro/navi

zi ice wait lucid from"gh-r" as"program" mv"ctop* -> ctop" sbin"ctop"
zi light bcicen/ctop

zi ice wait lucid from"gh-r" as"program" sbin"fd"
zi light sharkdp/fd

# DUF
zinit ice lucid wait="0" as="program" from="gh-r" bpick='*linux_amd64.deb' pick="usr/bin/duf" atload="alias df=duf"
zinit light muesli/duf

# diff-so-fancy
zi ice lucid wait="1" as="program" from="gh-r" bpick='diff-so-fancy' atload='alias diff=diff-so-fancy'
zinit light so-fancy/diff-so-fancy

zinit ice lucid as="command" from="gh-r" mv="**/bin/gh -> gh" atclone="gh completion -s zsh > _gh" atpull="%atclone" sbin="gh"
zinit light cli/cli

zinit ice lucid wait="0" as="program" from="gh-r" sbin="croc"
zinit light schollz/croc

zinit ice pick'zsh/fzf-zsh-completion.sh'
zinit light "lincheney/fzf-tab-completion"

# First add the necessary zstyle configurations
zstyle ':completion::complete:*' use-cache 1
zstyle ":conda_zsh_completion:*" use-groups true
zstyle ":conda_zsh_completion:*" show-unnamed true
zstyle ":conda_zsh_completion:*" sort-envs-by-time true
zstyle ":conda_zsh_completion:*" show-global-envs-first true

# Then load the completion plugin
zinit wait lucid light-mode for \
    atinit"zicompinit; zicdreplay" \
    blockf \
    atpull"zinit creinstall -q ." \
        conda-incubator/conda-zsh-completion


alias ff='find . -type f -name'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias p='ps -f'
alias grep='grep --color'
alias sgrep='grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS} '


alias ls='eza'                                                          # ls
alias l='eza -lbF --git'                                                # list, size, type, git
alias ll='eza -lbGF --git'                                             # long list
alias llm='eza -lbGd --git --sort=modified'                            # long list, modified date sort
alias la='eza -lbhHigUmuSa --time-style=long-iso --git --color-scale'  # all list
alias lx='eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale' # all + extended list


[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zhistory"
HISTSIZE=290000
SAVEHIST=$HISTSIZE

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_all_dups   # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt inc_append_history     # add commands to HISTFILE in order of execution
setopt share_history          # share command history data
setopt always_to_end          # cursor moved to the end in full completion
setopt hash_list_all          # hash everything before completion
# setopt completealiases        # complete alisases
setopt always_to_end          # when completing from the middle of a word, move the cursor to the end of the word
setopt complete_in_word       # allow completion from within a word/phrase
setopt nocorrect                # spelling correction for commands
setopt list_ambiguous         # complete as much of a completion until it gets ambiguous.
setopt nolisttypes
setopt listpacked
setopt automenu
unsetopt BEEP