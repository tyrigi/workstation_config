# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

PROMPT_COMMAND='DIR=`pwd|sed -e "s!$HOME!~!"`; if [ ${#DIR} -gt 30 ]; then CurDir=${DIR:0:15}...${DIR:${#DIR}-20}; else CurDir=$DIR; fi'
PS1="\[\033[0;32m\]\u\[\033[0m\] \[\033[1;36m\][\$CurDir]\[\033[m\] \[\033[1;32m\]\$\[\033[m\]"


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#######################################################################################################
# IoT Lab customizations
#######################################################################################################
#Enable bash command completion
if [ -f /etc/bash_completion ]; then
. /etc/bash_completion
fi

#Frequently used environment variables
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export GTEST_DIR=/home/tyler/Build_Tools/googletest
export CLASSPATH=/home/tyler/Build_Tools/junit-4.12.jar
export ANDROID_NDK=/home/tyler/Build_Tools/android-ndk-r10e
export ANDROID_SDK=/home/tyler/Android/Sdk
export SQLITE_DIR=/home/tyler/Build_Tools/sqlite3
export BIG_UP=../../../../../../../

#Stuff for Python for Android
export ANDROIDSDK=/home/tyler/Android/Sdk/platforms/android-25
export ANDROIDNDK=/home/tyler/Build_Tools/android-ndk-r10e
export ANDROIDAPI=25
export ANDROIDNDKVER=r10e

#Python auto-complete fix
export PYTHONSTARTUP=$HOME/.pythonrc

#Frequently used commands
alias get-id="git rev-parse HEAD | xclip -select c && xclip -selection c -o"
alias refresh="source ~/.bashrc"
alias dirs="dirs -v"
alias cd="HOME=/home/tyler/Alljoyn cd"

#Functions to speed up testing
        #Quickly find *.so library for test binaries
        #TODO: add failsafes for non-existant/unfindable files
function ajn_lib () {
	unset path
	unset LD_LIBRARY_PATH
	for i in `seq 1 10`;
	do
	if [ "$1" == "" ]; then
		break
	else
	while true
	do
	path="$path../"
	if [[ $(find $path -maxdepth 1 -name ".bashrc" -type f -exec echo "{}" \;) ]]; then
                echo "$1 not found"
                break
        else
	if [[ $(find $path -maxdepth 10 -name "$1" -type f -not -path "*/obj/*" -exec echo "{}" \;) ]]; then
		export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(dirname `find $path -maxdepth 10 -name "$1" -type f -not -path "*/obj/*" -exec readlink -f {} \; | head -n 1`)
		break
	fi
	fi
	done
	fi
	shift
        echo $LD_LIBRARY_PATH
	done
}
        #Quickly download all testing repositories with specified branch
function pull-all() {
        RUNDIR=$(pwd)
        cd ${2:-./}
        touch .root.flag
        if [[ -e ./core ]]; then
            rm -rf core
        fi
        if [[ -e ./services ]]; then
            rm -rf services
        fi
	mkdir core
	mkdir services
	(cd core && git clone https://git.allseenalliance.org/gerrit/core/alljoyn.git -b $1)
	(cd core && git clone https://git.allseenalliance.org/gerrit/core/ajtcl.git -b $1)
	(cd core && git clone https://git.allseenalliance.org/gerrit/core/alljoyn-js.git -b $1)
	(cd core && git clone https://git.allseenalliance.org/gerrit/core/test.git -b $1)
	(cd services && git clone https://git.allseenalliance.org/gerrit/services/base.git -b $1)
	(cd services && git clone https://git.allseenalliance.org/gerrit/services/base_tcl.git -b $1)
        cd $RUNDIR
}
        #Navigate to specified file (fast way to get to test binaries)
        #TODO: add failsafes for non-existant/unfindable files
function moveto() {
	unset path
	unset destination
	for i in `seq 1 10`;
	do
	if [ "$1" == "" ]; then
		break
	else
	while true
	do
	if [[ $(find $path -maxdepth 1 -name ".root.flag" -type f -exec echo "{}" \;) ]]; then
                echo "$1 not found"
                break
        else
	if [[ $(find $path -maxdepth 20 -name "$1" -type f -not -path "*/obj/*" -exec echo "{}" \;) ]]; then
		cd $(dirname `find $path -maxdepth 10 -name "$1" -type f -not -path "*/obj/*" -exec echo "{}" \; | head -n 1`)
		break
	fi
	fi
	path="$path../"
	done
	fi
	shift
	done
}
        #Go back up to the repository root (whatever directory has the SConstruct file)
function moveup() {
	unset path
	while true
	do
	path="$path../"
	if [[ $(find $path -maxdepth 1 -name ".bashrc" -type f -exec echo "{}" \;) ]]; then
                echo "SConstruct not found in any parent directories"
                break
        else
	if [[ $(find $path -maxdepth 1 -name "SConstruct" -type f -exec echo "{}" \;) ]]; then
		cd $(dirname `find $path -maxdepth 1 -name "SConstruct" -type f -exec echo "{}" \; | head -n 1`)
		break
	fi
	fi
	done
}
        #Return location of PolicyDB configurations
function policyconf() {
    find $POLICY_CONF -name "$1" -type f -exec readlink -f {} \; | head -n 1
}

function swapbuild() {
    if [[ $TEST_ROOT ]]; then
        cd $TEST_ROOT/../
    else
        echo "Unrecognized testing environment."
    fi
    refresh
}

# Get a fresh copy of all testing repositories, then build a copy of the core, thin core, and test tools for each of the following:
# Debug Bundled Router
# Release Bundled Router
# Debug Stand-alone Router
# Release Stand-alone Router
function update-alljoyn() {
    export RED='\033[0;31m'
    export GREEN='\033[0;32m'
    export NC='\033[0m'
    cd ~/Alljoyn
    if [ ! -d ./bundle-deb ]; then mkdir ./bundle-deb; fi
    if [ ! -d ./bundle-rel ]; then mkdir ./bundle-rel; fi
    if [ ! -d ./solo-deb ]; then mkdir ./solo-deb; fi
    if [ ! -d ./solo-rel ]; then mkdir ./solo-rel; fi
    if [ "$1" == "" ]; then
        echo "Must specify a release: update-alljoyn [branch]"
        break
    else
        echo "Pulling AllJoyn Source..."
        pull-all $1 bundle-deb &>/dev/null &
        GET1=$!
        pull-all $1 bundle-rel &>/dev/null &
        GET2=$!
        pull-all $1 solo-deb &>/dev/null &
        GET3=$!
        pull-all $1 solo-rel &>/dev/null &
        GET4=$!
        cd ~/Alljoyn/oprt/linksys/; rm -rf alljoyn
        git clone https://git.allseenalliance.org/gerrit/core/alljoyn.git -b RB16.10 &>/dev/null &
        GET5=$!
        cd ~/Alljoyn/oprt/tp-link/; rm -rf alljoyn
        git clone https://git.allseenalliance.org/gerrit/core/alljoyn.git -b RB16.10 &>/dev/null &
        GET6=$!
        echo "Building Debug with Bundled Router"
        echo "Alljoyn Core..."
        cd ~/Alljoyn/bundle-deb/core/alljoyn 
        wait $GET1
        scons BINDINGS=c,cpp,java VARIANT=debug BR=on --jobs=4 &>/dev/null 
        if [ $? -eq 0 ]; then echo -e "${GREEN}Successful build.${NC}"; else echo -e "${RED}There were errors!${NC}"; fi
        echo "AllJoyn Thin Core..."
        cd ~/Alljoyn/bundle-deb/core/ajtcl 
        scons BINDINGS=c,cpp,java VARIANT=debug BR=on --jobs=4 &>/dev/null 
        if [ $? -eq 0 ]; then echo -e "${GREEN}Successful build.${NC}"; else echo -e "${RED}There were errors!${NC}"; fi
        echo "AllJoyn Test Tools..."
        cd ~/Alljoyn/bundle-deb/core/test/scl 
        scons BINDINGS=c,cpp,java VARIANT=debug BR=on --jobs=4 &>/dev/null 
        if [ $? -eq 0 ]; then echo -e "${GREEN}Successful build.${NC}"; else echo -e "${RED}There were errors!${NC}"; fi
        echo "Building Release with Bundled Router"
        echo "AllJoyn Core..."
        cd ~/Alljoyn/bundle-rel/core/alljoyn 
        wait $GET2
        scons BINDINGS=c,cpp,java VARIANT=release BR=on --jobs=4 &>/dev/null 
        if [ $? -eq 0 ]; then echo -e "${GREEN}Successful build.${NC}"; else echo -e "${RED}There were errors!${NC}"; fi
        echo "AllJoyn Thin Core..."
        cd ~/Alljoyn/bundle-rel/core/ajtcl 
        scons BINDINGS=c,cpp,java VARIANT=release BR=on --jobs=4 &>/dev/null 
        if [ $? -eq 0 ]; then echo -e "${GREEN}Successful build.${NC}"; else echo -e "${RED}There were errors!${NC}"; fi
        echo "AllJoyn Test Tools..."
        cd ~/Alljoyn/bundle-rel/core/test/scl 
        scons BINDINGS=c,cpp,java VARIANT=release BR=on --jobs=4 &>/dev/null 
        if [ $? -eq 0 ]; then echo -e "${GREEN}Successful build.${NC}"; else echo -e "${RED}There were errors!${NC}"; fi
        echo "Building Debug with Stand-alone Router"
        echo "AllJoyn Core..."
        cd ~/Alljoyn/solo-deb/core/alljoyn 
        wait $GET3
        scons BINDINGS=c,cpp,java VARIANT=debug BR=off --jobs=4 &>/dev/null 
        if [ $? -eq 0 ]; then echo -e "${GREEN}Successful build.${NC}"; else echo -e "${RED}There were errors!${NC}"; fi
        echo "AllJoyn Thin Core..."
        cd ~/Alljoyn/solo-deb/core/ajtcl 
        scons BINDINGS=c,cpp,java VARIANT=debug BR=off --jobs=4 &>/dev/null 
        if [ $? -eq 0 ]; then echo -e "${GREEN}Successful build.${NC}"; else echo -e "${RED}There were errors!${NC}"; fi
        echo "AllJoyn Test Tools..."
        cd ~/Alljoyn/solo-deb/core/test/scl 
        scons BINDINGS=c,cpp,java VARIANT=debug BR=off --jobs=4 &>/dev/null 
        if [ $? -eq 0 ]; then echo -e "${GREEN}Successful build.${NC}"; else echo -e "${RED}There were errors!${NC}"; fi
        echo "Building Release with Stand-alone Router"
        echo "AllJoyn Core..."
        cd ~/Alljoyn/solo-rel/core/alljoyn 
        wait $GET4
        scons BINDINGS=c,cpp,java VARIANT=release BR=off --jobs=4 &>/dev/null 
        if [ $? -eq 0 ]; then echo -e "${GREEN}Successful build.${NC}"; else echo -e "${RED}There were errors!${NC}"; fi
        echo "AllJoyn Thin Core..."
        cd ~/Alljoyn/solo-rel/core/ajtcl 
        scons BINDINGS=c,cpp,java VARIANT=release BR=off --jobs=4 &>/dev/null 
        if [ $? -eq 0 ]; then echo -e "${GREEN}Successful build.${NC}"; else echo -e "${RED}There were errors!${NC}"; fi
        echo "AllJoyn Test Tools..."
        cd ~/Alljoyn/solo-rel/core/test/scl 
        scons BINDINGS=c,cpp,java VARIANT=release BR=off --jobs=4 &>/dev/null 
        if [ $? -eq 0 ]; then echo -e "${GREEN}Successful build.${NC}"; else echo -e "${RED}There were errors!${NC}"; fi

        echo "Building Linksys Packages"
        cd ~/Alljoyn/oprt/linksys/openwrt
        wait $GET5
        make package/feeds/alljoyn/alljoyn/clean &>/dev/null
        make package/feeds/alljoyn/alljoyn/prepare &>/dev/null
        make package/feeds/alljoyn/alljoyn/compile -j5 &>/dev/null
        echo "Building TP-Link Packages"
        wait $GET6
        make package/feeds/alljoyn/alljoyn/clean &>/dev/null
        make package/feeds/alljoyn/alljoyn/prepare &>/dev/null
        make package/feeds/alljoyn/alljoyn/compile -j5 &>/dev/null
        cd ~/Alljoyn
        echo "All Done!"        
    fi
}


function logit() {
    $1 2>&1 | tee $2
}

#Check if I'm in a testing environment
unset path 
while true
do 
if [[ $(find $path -maxdepth 1 -name ".bashrc" -type f -exec echo "{}" \;) ]]; then #Found $HOME before .ajn_root.flag, definitely not testing env.
    unset AJN_CORE
    unset AJTCL
    unset CORE_TEST
    unset TCL_TEST
    unset TEST_ROOT
    unset AJN_JS
    unset POLICY_CONF
    break
else
if [[ $(find $path -maxdepth 1 -name ".ajn_root.flag" -type f -exec echo "{}" \;) ]]; then #Found .ajn_root.flag before .root.flag, not testing
    break
    else
    if [[ $(find $path -maxdepth 1 -name ".root.flag" -type f -exec echo "{}" \;) ]]; then #Valid testing environment!
        unset path
        while true
        do
        if [[ $(find $path -maxdepth 1 -name ".bashrc" -type f -exec echo "{}" \;) ]]; then #Went too far, in the home directory now
            break
        else
        if [[ $(find $path -maxdepth 1 -name ".root.flag" -type f -exec echo "{}" \;) ]]; then #Found the root of the working test environment
            export TEST_ROOT=$(dirname `find $path -maxdepth 1 -name ".root.flag" -type f -exec readlink -f {} \; | head -n 1`)
            break
        fi
        fi
        path="$path../"
        done
        export AJN_CORE=$TEST_ROOT/core/alljoyn
        export AJTCL=$TEST_ROOT/core/ajtcl
        export CORE_TEST=$TEST_ROOT/core/test/scl
        export TCL_TEST=$TEST_ROOT/core/test/tcl
        export AJN_JS=$TEST_ROOT/core/alljoyn-js
        export POLICY_CONF=$TEST_ROOT/core/test/config/policydb
        echo -e "AllJoyn Core: $(cd $AJN_CORE && git rev-parse HEAD)\nAJTCL: $(cd $AJTCL && git rev-parse HEAD)\nTest Tools: $(cd $CORE_TEST && git rev-parse HEAD)" | xclip -selection c
        break
    fi
fi
fi
path="$path../"
done
