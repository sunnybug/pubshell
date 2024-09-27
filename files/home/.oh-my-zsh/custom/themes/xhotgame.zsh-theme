# Clean, simple, compatible and meaningful.
# Tested on Linux, Unix and Windows under ANSI colors.
# It is recommended to use with a dark background.
# Colors: black, red, green, yellow, *blue, magenta, cyan, and white.
#
# Mar 2013 Yad Smood
 
# VCS
YS_VCS_PROMPT_PREFIX1=" %{$reset_color%}on%{$fg[blue]%} "
YS_VCS_PROMPT_PREFIX2=":%{$fg[cyan]%}"
YS_VCS_PROMPT_SUFFIX="%{$reset_color%}"
YS_VCS_PROMPT_DIRTY=" %{$fg[red]%}x"
YS_VCS_PROMPT_CLEAN=" %{$fg[green]%}o"
 
# Git info
local git_info='$(git_prompt_info)'
ZSH_THEME_GIT_PROMPT_PREFIX="${YS_VCS_PROMPT_PREFIX1}git${YS_VCS_PROMPT_PREFIX2}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$YS_VCS_PROMPT_SUFFIX"
ZSH_THEME_GIT_PROMPT_DIRTY="$YS_VCS_PROMPT_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN="$YS_VCS_PROMPT_CLEAN"
 
# SVN info
local svn_info='$(svn_prompt_info)'
ZSH_THEME_SVN_PROMPT_PREFIX="${YS_VCS_PROMPT_PREFIX1}svn${YS_VCS_PROMPT_PREFIX2}"
ZSH_THEME_SVN_PROMPT_SUFFIX="$YS_VCS_PROMPT_SUFFIX"
ZSH_THEME_SVN_PROMPT_DIRTY="$YS_VCS_PROMPT_DIRTY"
ZSH_THEME_SVN_PROMPT_CLEAN="$YS_VCS_PROMPT_CLEAN"
 
# Virtualenv
local venv_info='$(virtenv_prompt)'
YS_THEME_VIRTUALENV_PROMPT_PREFIX=" %{$fg[green]%}"
YS_THEME_VIRTUALENV_PROMPT_SUFFIX=" %{$reset_color%}%"
virtenv_prompt() {
        [[ -n "${VIRTUAL_ENV:-}" ]] || return
        echo "${YS_THEME_VIRTUALENV_PROMPT_PREFIX}${VIRTUAL_ENV:t}${YS_THEME_VIRTUALENV_PROMPT_SUFFIX}"
}
 
local exit_code="%(?,,C:%{$fg[red]%}%?%{$reset_color%})"
 
# Prompt format:
#
# PRIVILEGES USER @ MACHINE in DIRECTORY on git:BRANCH STATE [TIME] C:LAST_EXIT_CODE
# $ COMMAND
#
# For example:
#
# % ys @ ys-mbp in ~/.oh-my-zsh on git:master x [21:47:42] C:0
# $
PROMPT="
%{$terminfo[bold]$fg[blue]%}#%{$reset_color%} \
%{$fg[cyan]%}%n \
%{$reset_color%}@ \
%{$fg[green]%}%m \
%{$reset_color%}in \
%{$terminfo[bold]$fg[yellow]%}%~%{$reset_color%}\
${git_info}\
${svn_info}\
${venv_info}\
 \
$exit_code
%{$terminfo[bold]$fg[green]%}$ %{$reset_color%}"
 
 
autoload -Uz add-zsh-hook
add-zsh-hook preexec preexec
add-zsh-hook precmd precmd
 
# 修改 preexec 和 precmd，实现毫秒级计时
unction preexec() {
  timer=$(date +%s%3N) # 记录当前时间的毫秒数
}
 
function precmd() {
  if [ $timer ]; then
    end_timer=$(date +%s%3N) # 命令结束时的毫秒数
    timer_show=$((end_timer - timer)) # 计算耗时，单位为毫秒
 
    # 初始化时间单位
    local days=$((timer_show/86400000))
    local hours=$((timer_show%86400000/3600000))
    local minutes=$((timer_show%3600000/60000))
    local seconds=$((timer_show%60000/1000))
    local milliseconds=$((timer_show%1000))
 
    # 构建时间字符串
    local time_string=""
    [[ $days -gt 0 ]] && time_string="${time_string}${days}d "
    [[ $hours -gt 0 ]] && time_string="${time_string}${hours}h "
    [[ $minutes -gt 0 ]] && time_string="${time_string}${minutes}m "
    [[ $seconds -gt 0 ]] && time_string="${time_string}${seconds}s "
    [[ $milliseconds -gt 0 ]] && time_string="${time_string}${milliseconds}ms"
 
    # 设置 RPROMPT，加入空格
    if [[ $timer_show -ge 0 ]]; then # 如果有耗时，则显示
      RPROMPT='%{$fg_bold[yellow]%}('${time_string}') %f%{$fg_bold[white]%}[%*]%f'
    else
      RPROMPT='%{$fg_bold[white]%} [%*]%f'
    fi
    unset timer
  fi
}