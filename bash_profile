export PATH=/usr/local/bin:$PATH

# Virtualenv
if [[ $(which pyenv 2>/dev/null) ]]; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi
if [[ -n "$(which virtualenv 2>/dev/null)" ]]; then
  export WORKON_HOME=$HOME/.virtualenvs
  export PATH="$HOME/.virtualenvs/home/bin:$PATH"
  [[ -f  /usr/local/bin/virtualenvwrapper.sh ]] && . /usr/local/bin/virtualenvwrapper.sh
  powerline=$(find $HOME/.virtualenvs/ -name powerline -type d | wc -l)
  if [[ $powerline -gt 0 ]]; then
    . $HOME/.virtualenvs/home/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh
  fi
fi

# Tmux
if command -v tmux>/dev/null; then
  #export "TERM=screen-256color"
  [[ -z $TMUX ]] && exec tmux new-session -A -s main
fi

# golang
if command -v go >/dev/null; then
  export GOPATH=$HOME/.go
  export PATH="$HOME/.go/bin:$PATH"
fi

#aliases
if [[ $(uname | grep -E -i '^Cygwin') ]]; then
  source $HOME/.cygaliases
elif [[ $(uname) == "Darwin" ]]; then
  [[ $(which gotty) ]] || [[ $(which go) ]] && go get github.com/yudai/gotty
  stty werase undef
  bind '\C-w:unix-filename-rubout' # Fix ctrl+w to not clear whole word but separators
fi
[[ -f $HOME/.bash_aliases ]] && source $HOME/.bash_aliases

#completion
[[ -f $HOME/.bash_history ]] && complete -W "$(echo `cat $HOME/.bash_history | egrep '^ssh ' | sort | uniq | sed 's/^ssh //'`;)" ssh
[[ -n "$(which brew 2>/dev/null)" && -h $(brew --prefix)/etc/bash_completion ]] && . $(brew --prefix)/etc/bash_completion
[[ -f $HOME/.git-completion.sh ]] || ( curl --silent https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > $HOME/.git-completion.sh && chmod +x $HOME/.git-completion.sh)
. $HOME/.git-completion.sh
if [[ ! -f $HOME/.docker-compose-completion.bash ]]; then
  if [[ $(which docker-compose 2>/dev/null) ]]; then
    curl --silent -L https://raw.githubusercontent.com/docker/compose/$(docker-compose version --short)/contrib/completion/bash/docker-compose > $HOME/.docker-compose-completion.bash && chmod +x $HOME/.docker-compose-completion.bash
  fi
fi
[[ $(which docker-compose 2>/dev/null) ]] && . $HOME/.docker-compose-completion.bash
[[ -f $HOME/.docker-completion.bash ]] || ( curl --silent -L https://raw.githubusercontent.com/docker/docker/master/contrib/completion/bash/docker > $HOME/.docker-completion.bash && chmod +x $HOME/.docker-completion.bash )
. $HOME/.docker-completion.bash

# NVM
if [[ -d "$HOME/.nvm" ]]; then
  export NVM_DIR="$HOME/.nvm"
  if [[ $(which brew 2>/dev/null) ]]; then
    [[ -s "$(brew --prefix nvm)/nvm.sh" ]] && . "$(brew --prefix nvm)/nvm.sh"
  else
    [[ -s "$HOME/.nvm/nvm.sh" ]] && . "$HOME/.nvm/nvm.sh"
  fi
fi

# RVM
if [[ -d "$HOME/.rvm" ]]; then
  [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
  export PATH="$PATH:$HOME/.rvm/bin:$GEM_HOME/bin" # Add RVM to PATH for scripting
fi


# Hashi
[[ -d "$HOME/software/packer" ]] && export PATH="$HOME/software/packer:$PATH"
[[ -d "$HOME/software/terraform" ]] && export PATH="$HOME/software/terraform/bin:$PATH"

# Gradle
if [[ -d "$HOME/.gradle" ]]; then
  export GRADLE_HOME="$HOME/.gradle/wrapper/dists/gradle-2.5-bin/7mk8vyobxfh3eazpg3pi2y9mv/gradle-2.5"
  export PATH="$GRADLE_HOME/bin:$PATH"
fi

# custom exports such as API keys
[[ -f $HOME/.exports ]] && . $HOME/.exports

# enhancd
[[ -d $HOME/.enhancd ]] && . $HOME/repos/github/enhancd/init.sh

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
