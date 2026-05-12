#!/usr/bin/env zsh

#! ██████╗░░█████╗░  ███╗░░██╗░█████╗░████████╗  ███████╗██████╗░██╗████████╗
#! ██╔══██╗██╔══██╗  ████╗░██║██╔══██╗╚══██╔══╝  ██╔════╝██╔══██╗██║╚══██╔══╝
#! ██║░░██║██║░░██║  ██╔██╗██║██║░░██║░░░██║░░░  █████╗░░██║░░██║██║░░░██║░░░
#! ██║░░██║██║░░██║  ██║╚████║██║░░██║░░░██║░░░  ██╔══╝░░██║░░██║██║░░░██║░░░
#! ██████╔╝╚█████╔╝  ██║░╚███║╚█████╔╝░░░██║░░░  ███████╗██████╔╝██║░░░██║░░░
#! ╚═════╝░░╚════╝░  ╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░  ╚══════╝╚═════╝░╚═╝░░░╚═╝░░░

# Let HyDE immediately load prompts
# For now supported prompts are Starship and Powerlevel10k (p10k)

# Exit early if HYDE_ZSH_PROMPT is not set to 1
if [[ "${HYDE_ZSH_PROMPT}" != "1" ]]; then
    return
fi

if command -v starship &>/dev/null; then
    autoload -Uz vcs_info
    precmd() { vcs_info }
    setopt PROMPT_SUBST
    zstyle ':vcs_info:git:*' formats ' %F{blue}git:(%F{red}%b%F{blue})%f'
    zstyle ':vcs_info:*' enable git
    stty -ixon
    export TERM=xterm-256color
    PROMPT='%F{cyan}%n%f %F{yellow}%~%f${vcs_info_msg_0_} %(?.%F{green}➜.%F{red}✗)%f '
# ===== END Initialize Starship prompt =====
elif [ -r $HOME/.p10k.zsh ] || [ -r $ZDOTDIR/.p10k.zsh ]; then
    # ===== START Initialize Powerlevel10k theme =====
    POWERLEVEL10K_TRANSIENT_PROMPT=same-dir
    P10k_THEME=${P10k_THEME:-/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme}
    [[ -r $P10k_THEME ]] && source $P10k_THEME
    # To customize prompt, run `p10k configure` or edit $HOME/.p10k.zsh
    if [[ -f $HOME/.p10k.zsh ]]; then
        source $HOME/.p10k.zsh
    elif [[ -f $ZDOTDIR/.p10k.zsh ]]; then
        source $ZDOTDIR/.p10k.zsh
    fi
# ===== END Initialize Powerlevel10k theme =====
fi
