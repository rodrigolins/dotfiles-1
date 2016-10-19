#!/bin/sh

##
# Colorization
##
NORMAL=""
[[ -x $(command -v tput) ]] && NORMAL=$(tput sgr0)


function info() {
  local GREEN=""
  [[ -x $(command -v tput) ]] && GREEN=$(tput setaf 2; tput bold)


  local TEXT='INFO'
  
  echo "[$GREEN$TEXT$NORMAL]: $*"
}

function notice() {
  local TEXT='NOTICE'
  local YELLOW=""
  [[ -x $(command -v tput) ]] && YELLOW=$(tput setaf 3)
  
  echo "[$YELLOW$TEXT$NORMAL]: $*"
}

function warning() {
  local RED=""
  [[ -x $(command -v tput) ]] && RED=$(tput setaf 1)
  local TEXT='WARNING'
  
  echo "[$RED$TEXT$NORMAL]: $*"
}

##
# Configuration
##
CONFIG_FILES=( cygaliases bash_aliases bash_profile gitaliases gitconfig gitignore_default vimrc tmux.conf exports )
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INCLUDES=()
OPERATION=0
SOURCE_DIR="$HOME/Source"

##
# Program checks
##
BREW_EXISTS=$(type -p brew 2>/dev/null)
GIT_EXISTS=$(type -p git 2>/dev/null)
RUBY_EXISTS=$(type -p ruby 2>/dev/null)
PYTHON_EXISTS=$(type -p python 2>/dev/null)
GO_EXISTS=$(type -p go 2>/dev/null)
NVM_EXISTS=$(test -d ~/.nvm)
POWERLINE_EXISTS=$(type -p powerline 2>/dev/null)
TMUX_EXISTS=$(type -p tmux 2>/dev/null)

##
# Local program checks
##
LOCAL_BREW_EXISTS=$(type -p /usr/local/bin/brew 2>/dev/null)
LOCAL_GIT_EXISTS=$(type -p /usr/local/bin/git 2>/dev/null)
LOCAL_RUBY_EXISTS=$(type -p /usr/local/bin/ruby 2>/dev/null)
LOCAL_PYTHON_EXISTS=$(type -p /usr/local/bin/python 2>/dev/null)
LOCAL_GO_EXISTS=$(type -p /usr/local/bin/go 2>/dev/null)
LOCAL_NVM_EXISTS=$NVM_EXISTS
LOCAL_POWERLINE_EXISTS=$POWERLINE_EXISTS
LOCAL_TMUX_EXISTS=$TMUX_EXISTS

##
# Actions
##
INSTALL=1
UNINSTALL=2
INSTALL_BREW_ONLY=3
INSTALL_GIT_ONLY=4
INSTALL_NEOBUNDLE_ONLY=5
INSTALL_RUBY_ONLY=6
INSTALL_PYTHON_ONLY=7
INSTALL_GO_ONLY=8
INSTALL_NVM_ONLY=9
INSTALL_POWERLINE_ONLY=10
INSTALL_TMUX_ONLY=11
UNINSTALL_NEOBUNDLE_ONLY=12

##
# Parse arguments
##
for arg in "$@"; do
  case $arg in
    # Install arguments
    -i|--install)             OPERATION=$INSTALL ;;
    --install-brew-only)      OPERATION=$INSTALL_BREW_ONLY ;;
    --install-git-only)       OPERATION=$INSTALL_GIT_ONLY ;;
    --install-neobundle-only) OPERATION=$INSTALL_NEOBUNDLE_ONLY ;;
    --install-ruby-only)      OPERATION=$INSTALL_RUBY_ONLY ;;
    --install-python-only)    OPERATION=$INSTALL_PYTHON_ONLY ;;
    --install-go-only)        OPERATION=$INSTALL_GO_ONLY ;;
    --install-nvm-only)       OPERATION=$INSTALL_NVM_ONLY ;;
    --install-powerline-only) OPERATION=$INSTALL_POWERLINE_ONLY ;;
    --install-tmux-only)      OPERATION=$INSTALL_TMUX_ONLY ;;

    # Uninstall arguments
    -u|--uninstall)             OPERATION=$UNINSTALL ;;
    --uninstall-neobundle-only) OPERATION=$UNINSTALL_NEOBUNDLE_ONLY ;;
    
    # Includes arguments
    -a|--all)             INCLUDES=('brew' 'git' 'neobundle' 'ruby' 'python' 'go' 'nvm' 'powerline' 'tmux') ;;
    -b|--brew)            INCLUDES=("${INCLUDES[@]}" 'brew') ;;
    -g|--git)             INCLUDES=("${INCLUDES[@]}" 'git') ;;
    -n|--neobundle)       INCLUDES=("${INCLUDES[@]}" 'neobundle') ;;
    -r|--ruby)            INCLUDES=("${INCLUDES[@]}" 'ruby') ;;
    -p|--python)          INCLUDES=("${INCLUDES[@]}" 'python') ;;
    -go|--go)             INCLUDES=("${INCLUDES[@]}" 'go') ;;
    -nvm|--nvm)           INCLUDES=("${INCLUDES[@]}" 'nvm') ;;
    -power|--powerline)   INCLUDES=("${INCLUDES[@]}" 'powerline') ;;
    -t|--tmux)            INCLUDES=("${INCLUDES[@]}" 'tmux') ;;
    
    *)
      echo "Invalid param: $arg"
      exit
    ;;
  esac
done

##
# Installation methods
##
function install_brew() {
  if [[ $BREW_EXISTS ]]; then
    notice "Brew already installed."
  else
    if [[ $RUBY_EXISTS ]]; then
      info "Installing brew..."
    
      ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
      
      BREW_EXISTS=$(type -p brew 2>/dev/null)
    else
      warning "Could not find ruby"
    fi
  fi
}

function install_configuration() {
  info "Installing configuration..."
  
  for config_file in "${CONFIG_FILES[@]}"; do
    local SOURCE="$DIR/$config_file"
    local DESTINATION="$HOME/.$config_file"
  
    if [ -f $SOURCE ]; then
      if [ -h $DESTINATION ]; then
        notice "Replacing existing sym-link for $DESTINATION."

        unlink $DESTINATION
        ln -s $SOURCE $DESTINATION
      elif [ -f $DESTINATION ]; then
        warning "$DESTINATION is a file and will not be sym-linked."
      else
        info "Adding sym-link for $SOURCE to $DESTINATION"

        ln -s $SOURCE $DESTINATION
      fi
    fi
  done

  if [[ ! -h "$HOME/.bashrc" ]]; then
    info "Adding sym-link for .bash_profile to .bashrc"
    ln -s $DIR/bash_profile $HOME/.bashrc
  fi
  
}

function install_git() {
  if [[ $LOCAL_GIT_EXISTS ]]; then
    notice "Git already installed."
  else
    if [[ $(uname) = "Darwin" ]]; then
      if [[ !$BREW_EXISTS ]]; then
        install_brew
      fi
    
      brew update
      brew install git
    elif [[ $(uname) = "Linux" ]]; then
      PREFIX=""
      FILEPREFIX=git-master
      [[ -x $(command -v yum) ]] && PREFIX="sudo yum --nogpgcheck install -y wget unzip gcc gcc-c++ make automake autoconf openssl openssl-devel curl curl-devel gettext-devel expat-devel curl-devel zlib-devel openssl-devel libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev"
      [[ -x $(command -v apt-get) ]] && PREFIX="sudo apt-get install -y wget unzip libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev"
      cd /tmp
      rm -rf $FILEPREFIX
      wget https://github.com/git/git/archive/master.zip -O $FILEPREFIX.zip
      unzip $FILEPREFIX.zip && cd $FILEPREFIX
      make prefix=/usr/local
      sudo make prefix=/usr/local install
      cd -
    elif [[ $(uname) =~ CYGWIN.*$ ]]; then
      for i in bash libcurl4 libexpat1 libiconv2 libintl8 libopenssl100 perl perl-Error perl-Term-ReadKey python zlib0 cygutils less openssh rsync
        do 
          apt-cyg install $i
        done
      apt-cyg --mirror ftp://ftp.cygwinports.org/pub/cygwinports
      apt-cyg install git
      apt-cyg --mirror ftp://mirror.mcs.anl.gov/pub/cygwin
    else 
      warning "$(uname) is not supported"
    fi
    GIT_EXISTS=$(type -p /usr/local/bin/git 2>/dev/null)
    LOCAL_GIT_EXISTS=$(type -p /usr/local/bin/git 2>/dev/null)
  fi
}

function install_tmux() {
  if [[ $LOCAL_TMUX_EXISTS ]]; then
    notice "tmux already installed."
  else
    if [[ $(uname) = "Darwin" ]]; then
      if [[ !$BREW_EXISTS ]]; then
        install_brew
      fi

      if [[ !$GIT_EXISTS ]]; then
        install_git
      fi
    
      brew update
      brew install tmux reattach-to-user-namespace

    elif [[ $(uname) = "Linux" ]]; then
      PREFIX=""
      [[ -x $(command -v yum) ]] && PREFIX="yum"
      [[ -x $(command -v apt-get) ]] && PREFIX="apt-get"
      sudo $PREFIX install -y tmux
    elif [[ $(uname) =~ CYGWIN.*$ ]]; then
      apt-cyg install tmux
    else 
      warning "$(uname) is not supported"
    fi

    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    GIT_EXISTS=$(type -p /usr/local/bin/git 2>/dev/null)
    LOCAL_GIT_EXISTS=$(type -p /usr/local/bin/git 2>/dev/null)
  fi
}

function install_includes() {
  info "Installing includes..."
  
  for include in "${INCLUDES[@]}"; do
    case $include in
      'brew')      install_brew ;;
      'git')       install_git ;;
      'neobundle') install_neobundle ;;
      'nvm')       install_nvm ;;
      'ruby')      install_ruby ;;
      'python')    install_python ;;
      'powerline') install_powerline ;;
      'go')        install_go ;;
      'tmux')      install_tmux ;;
      *) ;;
    esac
  done
}

function install_neobundle() {
  info "Installing neobundle..."
  
  local NEOBUNDLE_PATH="$HOME/.vim/bundle"
  local NEOBUNDLE_NAME='neobundle.vim'
  
  if [[ -d "$NEOBUNDLE_PATH/$NEOBUNDLE_NAME" ]]; then
    notice "NeoBundle already installed."
  else
    if [[ !$GIT_EXISTS ]]; then
      install_git
    fi
    
    mkdir -p $NEOBUNDLE_PATH

    if [[ -d $NEOBUNDLE_PATH ]]; then
      git clone git://github.com/Shougo/$NEOBUNDLE_NAME $NEOBUNDLE_PATH/$NEOBUNDLE_NAME
    else
      warning "Could not find $NEOBUNDLE_PATH"
    fi
  fi
}

function install_go() {
  if [[ $LOCAL_GO_EXISTS ]]; then
    notice "GO already installed."
  else

    if [[ $(uname) = "Darwin" ]]; then
      if [[ !$BREW_EXISTS ]]; then
        install_brew
      fi
    
      brew update
      brew install go
    elif [[ $(uname) = "Linux" ]]; then
      PREFIX=""
      [[ -x $(command -v yum) ]] && PREFIX="yum --nogpgcheck"
      [[ -x $(command -v apt-get) ]] && PREFIX=apt-get
      sudo $PREFIX -y install \
        golang
    else 
      warning "$(uname) is not supported"
    fi

    [[ ! -d $HOME/.go ]] && mkdir $HOME/.go

    GO_EXISTS=$(type -p go 2>/dev/null)
    LOCAL_GO_EXISTS=$(type -p /usr/local/bin/go 2>/dev/null)
  fi
}

function install_python() {
  if [[ $LOCAL_PYTHON_EXISTS ]]; then
    notice "Python already installed."
  else

    if [[ $(uname) = "Darwin" ]]; then
      if [[ !$BREW_EXISTS ]]; then
        install_brew
      fi
    
      brew update
      brew install python pyenv-virtualenv pyenv
    elif [[ $(uname) = "Linux" ]]; then
      PREFIX=""
      [[ -x $(command -v yum) ]] && PREFIX="yum --nogpgcheck"
      [[ -x $(command -v apt-get) ]] && PREFIX=apt-get
      sudo $PREFIX -y install \
        python python-pip

    elif [[ $(uname) =~ CYGWIN.*$ ]]; then
      apt-cyg install python
    else 
      warning "$(uname) is not supported"
    fi

    eval "$(pyenv init -)"
    pyenv install 2.7.12

    sudo pip install --upgrade pip virtualenv setuptools virtualenvwrapper
    export WORKON_HOME="~/.virtualenvs"
    mkdir -p ~/.virtualenvs
    export PATH="~/.virtualenvs/home/bin:$PATH"
    eval "$(pyenv virtualenv-init -)"
    source /usr/local/bin/virtualenvwrapper.sh
    mkvirtualenv home


    PYTHON_EXISTS=$(type -p python 2>/dev/null)
    LOCAL_PYTHON_EXISTS=$(type -p /usr/local/bin/python 2>/dev/null)
  fi
}

function install_powerline() {
  if [[ -d $HOME/.virtualenvs/home/lib/python2.7/site-packages/powerline ]]; then
    notice "Powerline already installed."
  else

    if [[ $(uname) = "Darwin" || $(uname) = "Linux" ]]; then
      if [[ !$PYTHON_EXISTS ]]; then
        install_python
      fi

      pip install powerline-status

      if [[ ! -h ~/.virtualenvs/home/lib/python2.7/site-packages/powerline/config_files ]]; then
        mv ~/.virtualenvs/home/lib/python2.7/site-packages/powerline/config_files ~/.virtualenvs/home/lib/python2.7/site-packages/powerline/config_files.bkup
        ln -s $(pwd)/powerline_config_files ~/.virtualenvs/home/lib/python2.7/site-packages/powerline/config_files
      fi

    else 
      warning "$(uname) is not supported"
    fi

    POWERLINE_EXISTS=$(type -p powerline 2>/dev/null)
    LOCAL_POWERLINE_EXISTS=$POWERLINE_EXISTS
  fi
}

function install_nvm() {
  if [[ $LOCAL_NODE_EXISTS ]]; then
    notice "Node already installed."
  else

    if [[ $(uname) = "Darwin" ]]; then
      if [[ !$BREW_EXISTS ]]; then
        install_brew
      fi
    
      brew update
      brew install nvm
    elif [[ $(uname) = "Linux" ]]; then
      if [[ -x $(command -v apt-get) ]]; then
        sudo apt-get install -y build-essential libssl-dev
      fi

      curl https://raw.githubusercontent.com/creationix/nvm/v0.30.2/install.sh | bash

    else 
      warning "$(uname) is not supported"
    fi

    mkdir $HOME/.nvm

    NODE_EXISTS=$(test -d ~/.nvm 2>/dev/null)
    LOCAL_NODE_EXISTS=$NODE_EXISTS
  fi
}

function install_ruby() {
  if [[ $LOCAL_RUBY_EXISTS ]]; then
    notice "Ruby already installed."
  else

    if [[ $(uname) = "Darwin" ]]; then
      if [[ !$BREW_EXISTS ]]; then
        install_brew
      fi
    
      brew update
      brew install gnupg
    fi

    if [[ $(uname) = "Darwin" || $(uname) = 'Linux' ]]; then
      gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
      \curl -sSL https://get.rvm.io | bash -s stable

    elif [[ $(uname) =~ CYGWIN.*$ ]]; then
      apt-cyg install ruby ruby-devel
    else 
      warning "$(uname) is not supported"
    fi

    RUBY_EXISTS=$(type -p ruby 2>/dev/null)
    LOCAL_RUBY_EXISTS=$(type -p /usr/local/bin/ruby 2>/dev/null)
  fi
}

function install() {
  install_configuration
  
  if [[ ${#INCLUDES[@]} > 0 ]]; then
    install_includes
  fi
}

##
# Uninstall methods
##
function uninstall_configuration() {
  warning "Uninstalling configuration..."
  
  for config_file in "${CONFIG_FILES[@]}"; do
    local DESTINATION="$HOME/.$config_file"
  
    if [[ -f $DESTINATION || -d $DESTINATION ]]; then
      warning "Removing existing sym-link for $DESTINATION."
      unlink $DESTINATION
    fi

  done

  if [[ -h $HOME/.bashrc ]]; then
    warning "Removing existing sym-link for bashrc."
    unlink $HOME/.bashrc
  fi

}

function uninstall_nebundle() {
  warning "Uninstalling NeoBundle..."
  
  if [ -d $HOME/.vim/bundle/neobundle.vim ]; then
    rm -rf $HOME/.vim/bundle/neobundle.vim
  fi
}

function uninstall() {
  uninstall_configuration
}

case $OPERATION in
  # Install operations
  $INSTALL)                install ;;
  $INSTALL_BREW_ONLY)      install_brew ;;
  $INSTALL_GIT_ONLY)       install_git ;;
  $INSTALL_NEOBUNDLE_ONLY) install_neobundle ;;
  $INSTALL_RUBY_ONLY)      install_ruby ;;
  $INSTALL_NVM_ONLY)       install_nvm ;;
  $INSTALL_PYTHON_ONLY)    install_python ;;
  $INSTALL_GO_ONLY)        install_go ;;
  $INSTALL_POWERLINE_ONLY) install_powerline ;;
  $INSTALL_TMUX_ONLY)      install_tmux ;;
  
  # Uninstall operations
  $UNINSTALL)                uninstall ;;  
  $UNINSTALL_NEOBUNDLE_ONLY) uninstall_neobundle ;;
  
  # Manual
  *)
    echo "usage: ./setup.sh [-i|--install|--install-brew-only|--install-git-only|--install-neobundle-only|--install-python-only|--install-go-only|"
    echo "  --uninstall-neobundle-only][-a|--all][-b|--brew][-g|--git][-n|--neobundle][-r|--ruby][-g|--go]"
    echo
    echo "Options:"
    echo "  -i --install                Install configuration plus any specified includes"
    echo "  --install-brew-only         Install Homebrew only"
    echo "  --install-git-only          Install Git (requires Homebrew)"
    echo "  --install-go-only           Install only GoLang"
    echo "  --install-neobundle-only    Install only NeoBundle"
    echo "  --install-python-only       Install only Python"
    echo "  --install-ruby-only         Install only Ruby"
    echo "  -u      --uninstall         Uninstall configuration"
    echo "  --uninstall-neobundle-only  Uninstall only NeoBundle"
    echo "  -a      --all               Include all includes (see --install)"
    echo "  -b      --brew              Include Homebrew (see --install)"
    echo "  -g      --git               Include Git (see --install; requires brew)"
    echo "  -go     --go                Include GoLang (see --install; requires brew)"
    echo "  -n      --neobundle         Include NeoBundle (see --install; requires git)"
    echo "  -r      --ruby              Include Ruby (see --install; requires brew)"
    echo "  -p      --python            Include Python (see --install; requires brew)"
    echo "  -power  --powerline         Include Powerline (see --install; requires python)"
    echo "  -nvm    --nvm               Include NVM (see --install; requires python)"
    echo "  -t      --tmux              Include TMUX (see --install; requires brew)"
  ;;
esac
