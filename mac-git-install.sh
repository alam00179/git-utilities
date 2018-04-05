#!/usr/local/bin/bash

# mac-git-install.sh in https://github.com/wilsonmar/git-utilities
# This establishes all the utilities related to use of Git,
# customized based on specification in file secrets.sh within the same repo.
# See https://github.com/wilsonmar/git-utilities/blob/master/README.md
# Based on https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup
# and https://git-scm.com/docs/git-config
# and https://medium.com/my-name-is-midori/how-to-prepare-your-fresh-mac-for-software-development-b841c05db18
# https://www.bonusbits.com/wiki/Reference:Mac_OS_DevOps_Workstation_Setup_Check_List

# TOC: Functions (GPG_MAP_MAIL2KEY, Python, Python3, Java, Node, Go, Docker) > 
# Secrets > OSX > XCode/Ruby > bash.profile > Brew > gitconfig > Git web browsers > p4merge > linters > Git clients > git users > git tig > BFG > gitattributes > Text Editors > git [core] > git coloring > rerere > prompts > bash command completion > git command completion > Git alias keys > Git repos > git flow > git hooks > Large File Storage > gcviewer, jmeter, jprofiler > code review > git signing > Cloud CLI/SDK > Selenium > SSH KeyGen > SSH Config > Paste SSH Keys in GitHub > GitHub Hub > dump contents > disk space > show log

set -a


######### Bash function definitions:


fancy_echo() {
  local fmt="$1"; shift
  # shellcheck disable=SC2059
  printf "\\n>>> $fmt\\n" "$@"
}

# Add function to read in string and email, and return a KEY found for that email.
# GPG_MAP_MAIL2KEY associates the key and email in an array
function GPG_MAP_MAIL2KEY(){
KEY_ARRAY=($(echo "$str" | awk -F'sec   rsa2048/|2018* [SC]' '{print $2}' | awk '{print $1}'))
# Remove trailing blank: KEY="$(echo -e "${str}" | sed -e 's/[[:space:]]*$//')"
MAIL_ARRAY=($(echo "$str" | awk -F'<|>' '{print $2}'))
#Test if the array count of the emails and the keys are the same to avoid conflicts
if [ ${#KEY_ARRAY[@]} == ${#MAIL_ARRAY[@]} ]; then
   declare -A KEY_MAIL_ARRAY=()
   for i in "${!KEY_ARRAY[@]}"
   do
        KEY_MAIL_ARRAY[${MAIL_ARRAY[$i]}]=${KEY_ARRAY[$i]}
   done
   #Return key matching email passed into function
   echo "${KEY_MAIL_ARRAY[$1]}"
else
   #exit from script if array count of emails and keys are not the same
   exit 1 && fancy_echo "Email count and Key count do not match"
fi
}

function PYTHON_INSTALL(){
   # Python2 is a pre-requisite for git-cola & GCP installed below.
   # Python3 is a pre-requisite for aws.
   # Because there are two active versions of Pythong (2.7.4 and 3.6 now)...
     # See https://docs.brew.sh/Homebrew-and-Python
   # See https://docs.python-guide.org/en/latest/starting/install3/osx/
   
   if ! command -v python >/dev/null; then
      # No upgrade option.
      fancy_echo "Installing Python, a pre-requisite for git-cola & GCP ..."
      brew install python
      # Not brew install pyenv  # Python environment manager.

      # brew cask install --appdir="/Applications" anaconda
      # To use anaconda, add the /usr/local/anaconda3/bin directory to your PATH environment 
      # variable, eg (for bash shell):
      # export PATH=/usr/local/anaconda3/bin:"$PATH"

      # pip comes with brew install Python 2 >=2.7.9 or Python 3 >=3.4
      pip --version

      fancy_echo "Installing virtualenv to manage multiple Python versions ..."
      pip install virtualenv
      pip install virtualenvwrapper
      source /usr/local/bin/virtualenvwrapper.sh

      #brew install freetype  # http://www.freetype.org to render fonts
      #fancy_echo "Installing other popular Python helper modules ..."
      #pip install jupyter
      #pip install numpy
      #pip install scipy
      #pip install matplotlib
      #pip install ipython[all]
   else
      fancy_echo -e "\n$(python --version) already installed:"
   fi
   command -v python
   ls -al "$(command -v python)" # /usr/local/bin/python

   echo -e "\n$(python --version)"            >>$THISSCRIPT.log
         # Python 2.7.14
   echo -e "\n$(pip --version)"            >>$THISSCRIPT.log
         # pip 9.0.3 from /usr/local/lib/python2.7/site-packages (python 2.7)

   # Define command python as going to version 2.7:
      if grep -q "alias python=" "$BASHFILE" ; then    
         fancy_echo "Python 2.7 alias already in $BASHFILE"
      else
         fancy_echo "Adding Python 2.7 alias in $BASHFILE ..."
         echo "export alias python=/usr/local/bin/python2.7" >>"$BASHFILE"
      fi
   
      # To prevent the older MacOS default python being seen first in PATH ...
      if grep -q "/usr/local/opt/python/libexec/bin" "$BASHFILE" ; then    
         fancy_echo "Python PATH already in $BASHFILE"
      else
         fancy_echo "Adding Python PATH in $BASHFILE..."
         echo "export PATH=\"/usr/local/opt/python/libexec/bin:$PATH\"" >>"$BASHFILE"
      fi

         # Run .bash_profile to have changes take, run $FILEPATH:
         source "$BASHFILE"
         echo "$PATH"

   # There is also a Enthought Python Distribution -- www.enthought.com
}

function PYTHON3_INSTALL(){
   fancy_echo "Installing Python3 is a pre-requisite for AWS-CLI"
   # Because there are two active versions of Python (2.7.4 and 3.6 now)...
     # See https://docs.brew.sh/Homebrew-and-Python
   # See https://docs.python-guide.org/en/latest/starting/install3/osx/
   
   if ! command -v python3 >/dev/null; then
      # No upgrade option.
      fancy_echo "Installing Python3, a pre-requisite for awscli and azure ..."
      brew install python3

      # brew cask install --appdir="/Applications" anaconda
      # To use anaconda, add the /usr/local/anaconda3/bin directory to your PATH environment 
      # variable, eg (for bash shell):
      # export PATH=/usr/local/anaconda3/bin:"$PATH"
      #brew doctor fails run here due to /usr/local/anaconda3/bin/curl-config, etc.
      #Cask anaconda installs files under "/usr/local". The presence of such
      #files can cause warnings when running "brew doctor", which is considered
      #to be a bug in Homebrew-Cask.

      # pip comes with brew install python:
      fancy_echo "Installing virtualenv to manage multiple Python versions ..."
      pip3 install virtualenv
      pip3 install virtualenvwrapper
      source /usr/local/bin/virtualenvwrapper.sh

      #brew install freetype  # http://www.freetype.org to render fonts
      #fancy_echo "Installing other popular Python helper modules ..."
      #pip3 install jupyter
      # anaconda?
      #pip install numpy
      #pip install scipy
      #pip install matplotlib
      #pip install ipython[all]
	  
   else
      fancy_echo -e "\n$(python3 --version) already installed:"
   fi
   command -v python3
   ls -al "$(command -v python3)" # /usr/local/bin/python

   echo -e "\n$(python3 --version)"            >>$THISSCRIPT.log
      # Python 3.6.4
   echo -e "\n$(pip3 --version)"            >>$THISSCRIPT.log
      # pip 9.0.3 from /usr/local/lib/python3.6/site-packages (python 3.6)

   # NOTE: To make "python" command reach Python3 instead of 2.7, per docs.python-guide.org/en/latest/starting/install3/osx/
   # Put in PATH Python 3.6 bits at /usr/local/bin/ before Python 2.7 bits at /usr/bin/
}

function JAVA_INSTALL(){
   # See https://wilsonmar.github.io/java-on-apple-mac-osx/
   # and http://sourabhbajaj.com/mac-setup/Java/
   if ! command -v java >/dev/null; then
      # /usr/bin/java
      fancy_echo "Installing Java, a pre-requisite for Selenium, JMeter, etc. ..."
      # Don't rely on Oracle to install Java properly on your Mac.
      brew tap caskroom/versions
      brew cask install --appdir="/Applications" java8
   else
      # CAUTION: A specific version of JVM needs to be specified because code that use it need to be upgraded.
          fancy_echo "Java already installed"
   fi

   TEMP=$(java -version | grep "java version") # | cut -d'=' -f 2 ) # | awk -F= '{ print $2 }'
   JAVA_VERSION=${TEMP#*=};
   echo "JAVA_VERSION=$JAVA_VERSION"
   export JAVA_VERSION=$(java -version)
   echo -e "\n$(java -version)" >>$THISSCRIPT.log
      # java version "1.8.0_144"
      # Java(TM) SE Runtime Environment (build 1.8.0_144-b01)
      # Java HotSpot(TM) 64-Bit Server VM (build 25.144-b01, mixed mode)
   echo -e "$($JAVA_HOME)" >>$THISSCRIPT.log
      # /Library/Java/JavaVirtualMachines/jdk1.8.0_162.jdk/Contents/Home is a directory

   # https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
   if [ ! -z ${JAVA_HOME+x} ]; then  # variable has NOT been defined already.
      echo "$JAVA_HOME=$JAVA_HOME"
   else 
      echo "JAVA_HOME being set ..." # per http://sourabhbajaj.com/mac-setup/Java/
      echo "export JAVA_HOME=$(/usr/libexec/java_home -v $JAVA_VERSION)" >>$BASHFILE
      #echo "export JAVA_HOME=$(/usr/libexec/java_home -v 9)" >>$BASHFILE
   fi
   # /Library/Java/JavaVirtualMachines/jdk1.8.0_121.jdk/Contents/Home
   #   echo "export IDEA_JDK=$(/usr/libexec/java_home -v $JAVA_VERSION)" >>$BASHFILE
   #   echo "export RUBYMINE_JDK=$(/usr/libexec/java_home -v $JAVA_VERSION)" >>$BASHFILE
      source $BASHFILE

    # Associated: Maven (mvn) in /usr/local/opt/maven/bin/mvn
   if ! command -v mvn >/dev/null; then
      fancy_echo "Installing Maven for Java ..."
      brew install maven
   fi
   echo -e "$(mvn --version)" >>$THISSCRIPT.log

    # Alternative: ant, gradle

   # TODO: https://github.com/alexkaratarakis/gitattributes/blob/master/Java.gitattributes
}

function NODE_INSTALL(){
   # See https://wilsonmar.github.io/node-starter/

   # We begin with NVM to install Node versions: https://www.airpair.com/javascript/node-js-tutorial
   # in order to have several diffent versions of node installed simultaneously.
   # See https://github.com/creationix/nvm
   if [ ! -d "$HOME/.nvm" ]; then
      mkdir $HOME/.nvm
   fi

   if grep -q "export NVM_DIR=" "$BASHFILE" ; then    
      fancy_echo "export NVM_DIR= already in $BASHFILE"
   else
      fancy_echo "Adding export NVM_DIR= in $BASHFILE..."
      echo "export NVM_DIR=\"$HOME/.nvm\"" >>$BASHFILE
      source $BASHFILE
   fi

   if ! command -v nvm >/dev/null; then  # /usr/local/bin/node
      fancy_echo "Installing nvm (to manage node versions)"
      brew install nvm  # curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash

      # TODO: How to tell if nvm.sh has run?
      fancy_echo "Running /usr/local/opt/nvm/nvm.sh ..."
      source "/usr/local/opt/nvm/nvm.sh"  # nothing returned.
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "nvm already installed: UPGRADE requested..."
         brew upgrade nvm
      else
         fancy_echo "nvm already installed."
      fi
      nvm --version
      #0.33.8
   fi
   
   if ! command -v node >/dev/null; then  # /usr/local/bin/node
      fancy_echo "Installing node using nvm"
      nvm install node  # use nvm to install the latest version of node.
         # v9.10.1...
      nvm install --lts # lastest Long Term Support version
         # v8.11.1...

      # nvm install 8.9.4  # install a specific version
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "node already installed: UPGRADE requested..."
         # nvm i nvm  # instead of brew upgrade node
      else
         fancy_echo "node already installed."
      fi
   fi
   nvm on
   # $NVM_HOME


   #nvm use --delete-prefix v9.10.1  # to unset it.
   #nvm use node
      # nvm is not compatible with the npm config "prefix" option: currently set to "/usr/local/Cellar/nvm/0.33.8/versions/node/v9.10.1"
   #node --version   # v9.10.1...
   #npm --version    # 5.6.0

   #nvm use --delete-prefix v8.11.1
   #nvm use --lts
      # Now using node v8.11.1 (npm v5.6.0)

   #node --version   # v8.11.1
   #npm --version    # 5.6.0

   #nvm run 8.11.1 --version

   # nvm which 8.9.4

   # $NODE_ENV 
   
   # npm (node package manager) installed with node.
   # https://colorlib.com/wp/npm-packages-node-js/
   #npm install -g mocha  # testing framework
   #npm install -g chai   # assertion library  "should", "expect", "assert" for BDD and TDD styles of programming 
   # Alternative: karma, karma-cli
   # browserify, bower, grunt, gulp/gulp-cli, webpack, 
   # web: express, hapi, 
   # front-end: angular, react, redux, Ember.js, Marionette.js
   # Test React using Jest https://medium.com/@mathieux51/jest-selenium-webdriver-e25604969c6
   # moment.js, graphicmagick, yeoman-generator
   # cloud: aws-sdk 
   # less, UglifyJS2, eslint, jslint, cfn-lint
   # database: mongodb, redis 
   # montebank security app
   # nodemon, node-inspector

   echo -e "\n  npm list -g --depth=0" >>$THISSCRIPT.log
   echo -e "$(npm list -g --depth=0)" >>$THISSCRIPT.log
      # v8.11.1
      # v9.10.1
      # node -> stable (-> v9.10.1) (default)
      # stable -> 9.10 (-> v9.10.1) (default)
      # iojs -> N/A (default)
      # lts/* -> lts/carbon (-> v8.11.1)
      # lts/argon -> v4.9.1 (-> N/A)
      # lts/boron -> v6.14.1 (-> N/A)
      # lts/carbon -> v8.11.1

   # npm start

   # mocha
   # See https://github.com/creationix/howtonode.org by Tim Caswell
}


function GO_INSTALL(){
   if ! command -v go >/dev/null; then  # /usr/local/bin/go
      fancy_echo "Installing go ..."
      brew install go
   else
      # specific to each MacOS version
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         go version   # upgrading from.
         fancy_echo "go already installed: UPGRADE requested..."
         brew upgrade go
      else
         fancy_echo "go already installed."
      fi
   fi
   go version
      # go version go1.10.1 darwin/amd64

      if grep -q "export GOPATH=" "$BASHFILE" ; then    
         fancy_echo "GOPATH already in $BASHFILE"
      else
         fancy_echo "Adding GOPATH in $BASHFILE..."
         echo "export GOPATH=$HOME/golang" >>"$BASHFILE"
      fi
   
   # export GOROOT=$HOME/go
   # export PATH=$PATH:$GOROOT/bin
}


######### Starting:


TIME_START="$(date -u +%s)"
fancy_echo "This is for MacOS only. Starting timer ..."
# For Git on Windows, see http://www.rolandfg.net/2014/05/04/intellij-idea-and-git-on-windows/

THISSCRIPT="$0"   # "mac-git-install"
fancy_echo "Creating $THISSCRIPT.log ..."
echo "$THISSCRIPT.log $TIME_START"  >$THISSCRIPT.log  # new file
echo -e "\n   sw_vers ::"          >>$THISSCRIPT.log
echo -e "$(sw_vers)"               >>$THISSCRIPT.log
echo -e "\n   uname -a ::"         >>$THISSCRIPT.log
echo -e "$(uname -a)"              >>$THISSCRIPT.log

# The Available space from 2nd line, 6th item: 190920080
   #Filesystem   1024-blocks      Used Available Capacity iused               ifree %iused  Mounted on
   # /dev/disk1s1   488245284 294551984 190920080    61% 2470677 9223372036852305130    0%   /
FREE_DISKBLOCKS_START=$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6) 



######### TODO: Install git-secrets utility to decrypt secrets.sh.secret stored in GitHub:


# git clone https://github.com/wilsonmar/git-secret
# video: https://asciinema.org/a/41811?autoplay=1


######### Read and use secrets.sh file:


# If the file still contains defaults, it should not be used:
SECRETSFILE="secrets.sh"
if [ ! -f "$SECRETSFILE" ]; then #  NOT found:
   fancy_echo "$SECRETSFILE not found. Aborting run ..."
   exit
fi

if grep -q "wilsonmar@gmail.com" "$SECRETSFILE" ; then  # not customized:
   fancy_echo "Please edit file $SECRETSFILE with your own credentials. Aborting this run..."
   exit  # so script ends now
else
   fancy_echo "Reading from $SECRETSFILE ..."
   #chmod +x $SECRETSFILE
   source "$SECRETSFILE"
   echo -e "\n   $SECRETSFILE ::" >>$THISSCRIPT.log
   echo "GIT_NAME=$GIT_NAME">>$THISSCRIPT.log
   echo "GIT_ID=$GIT_ID" >>$THISSCRIPT.log
   echo "GIT_EMAIL=$GIT_EMAIL" >>$THISSCRIPT.log
   echo "GIT_USERNAME=$GIT_USERNAME" >>$THISSCRIPT.log
   echo "GITS_PATH=$GITS_PATH" >>$THISSCRIPT.log
   echo "GITHUB_ACCOUNT=$GITHUB_ACCOUNT" >>$THISSCRIPT.log
   echo "GITHUB_REPO=$GITHUB_REPO" >>$THISSCRIPT.log
   # DO NOT echo $GITHUB_PASSWORD. Do not cat $SECRETFILE because it contains secrets.
   echo "WORK_REPO=$WORK_REPO" >>$THISSCRIPT.log # i.e. git://example.com/some-big-repo.git"
   echo "CLOUD=$CLOUD" >>$THISSCRIPT.log
   echo "GIT_BROWSER=$GIT_BROWSER" >>$THISSCRIPT.log
   echo "GIT_CLIENT=$GIT_CLIENT" >>$THISSCRIPT.log
   echo "GIT_EDITOR=$GIT_EDITOR" >>$THISSCRIPT.log
   echo "GUI_TEST=$GUI_TEST" >>$THISSCRIPT.log
fi 


# Read first parameter from command line supplied at runtime to invoke:
MY_RUNTYPE=$1
fancy_echo "MY_RUNTYPE=$MY_RUNTYPE"
if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then # variable made lower case.
   echo "All packages here will be upgraded ..."
fi


######### OSX configuration:


fancy_echo "Configure OSX Finder to show hidden files too:"
defaults write com.apple.finder AppleShowAllFiles YES
# NOTE: Additional config dotfiles for Mac?
# NOTE: See osx-init.sh in https://github.com/wilsonmar/DevSecOps/osx-init
#       installs other programs on Macs for developers.


# Ensure Apple's command line tools (such as cc) are installed by node:
if ! command -v cc >/dev/null; then
   fancy_echo "Installing Apple's xcode command line tools (this takes a while) ..."
   xcode-select --install 
   # Xcode installs its git to /usr/bin/git; recent versions of OS X (Yosemite and later) ship with stubs in /usr/bin, which take precedence over this git. 
else
   fancy_echo "Mac OSX Xcode already installed:"
fi
pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep version
   # Tools_Executables | grep version
   # version: 9.2.0.0.1.1510905681


######### bash.profile configuration:


BASHFILE=$HOME/.bash_profile

# if ~/.bash_profile has not been defined, create it:
if [ ! -f "$BASHFILE" ]; then #  NOT found:
   fancy_echo "Creating blank \"${BASHFILE}\" ..."
   touch "$BASHFILE"
   echo "PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" >>"$BASHFILE"
   # El Capitan no longer allows modifications to /usr/bin, and /usr/local/bin is preferred over /usr/bin, by default.
else
   LINES=$(wc -l < "${BASHFILE}")
   fancy_echo "\"${BASHFILE}\" already created with $LINES lines."

   fancy_echo "Backing up file $BASHFILE to $BASHFILE-$RANDOM.bak ..."
   RANDOM=$((1 + RANDOM % 1000));  # 5 digit randome number.
   cp "$BASHFILE" "$BASHFILE-$RANDOM.backup"
fi


###### bash.profile locale settings missing in OS X Lion+:


# See https://stackoverflow.com/questions/7165108/in-os-x-lion-lang-is-not-set-to-utf-8-how-to-fix-it
# https://unix.stackexchange.com/questions/87745/what-does-lc-all-c-do
# LC_ALL forces applications to use the default language for output, and forces sorting to be bytewise.
if grep -q "LC_ALL" "$BASHFILE" ; then    
   fancy_echo "LC_ALL Locale setting already in $BASHFILE"
else
   fancy_echo "Adding LC_ALL Locale in $BASHFILE..."
   echo "# Added by mac-git-install.sh ::" >>"$BASHFILE"
   echo "export LC_ALL=en_US.utf-8" >>"$BASHFILE"
   #export LANG="en_US.UTF-8"
   #export LC_CTYPE="en_US.UTF-8"
   
   # Run .bash_profile to have changes take, run $FILEPATH:
   source "$BASHFILE"
fi 
#locale
   # LANG="en_US.UTF-8"
   # LC_COLLATE="en_US.UTF-8"
   # LC_CTYPE="en_US.utf-8"
   # LC_MESSAGES="en_US.UTF-8"
   # LC_MONETARY="en_US.UTF-8"
   # LC_NUMERIC="en_US.UTF-8"
   # LC_TIME="en_US.UTF-8"
   # LC_ALL=


###### Install homebrew using whatever Ruby is installed:


# Ruby comes with MacOS:
fancy_echo "Using whatever Ruby version comes with MacOS:"
ruby -v  # ruby 2.5.0p0 (2017-12-25 revision 61468) [x86_64-darwin16]
echo -e "\n$(ruby -v)"      >>$THISSCRIPT.log


if ! command -v brew >/dev/null; then
    fancy_echo "Installing homebrew using Ruby..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew tap caskroom/cask
else
    # Upgrade if run-time attribute contains "upgrade":
    if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
       brew --version
       fancy_echo "Brew already installed: UPGRADE requested..."
       brew upgrade
    else
       fancy_echo "Brew already installed:"
    fi
fi
#brew --version
echo -e "\n$(brew --version)"            >>$THISSCRIPT.log
   # Homebrew 1.5.12
   # Homebrew/homebrew-core (git revision 9a81e; last commit 2018-03-22)


#brew tap caskroom/cask
# Casks are GUI program installers defined in https://github.com/caskroom/homebrew-cask/tree/master/Casks
# brew cask installs GUI apps (see https://caskroom.github.io/)
export HOMEBREW_CASK_OPTS="--appdir=/Applications"



######### ~/.gitconfig initial settings:


GITCONFIG=$HOME/.gitconfig  # file

if [ ! -f "$GITCONFIG" ]; then 
   fancy_echo "$GITCONFIG! file not found."
else
   fancy_echo "Git is configured in new $GITCONFIG "
   fancy_echo "Backing up $GITCONFIG file to $GITCONFIG-$RANDOM.bak ..."
   RANDOM=$((1 + RANDOM % 1000));  # 5 digit randome number.
   cp "$GITCONFIG" "$GITCONFIG-$RANDOM.backup"
   fancy_echo "git config command creates new $GITCONFIG file..."
fi


######### Git web browser setting:



# Install browser using Homebrew to display GitHub to paste SSH key at the end.
fancy_echo "GIT_BROWSER=$GIT_BROWSER in secrets.sh ..."
      echo "The last one installed is set as the Git browser."


if [[ "$GIT_BROWSER" == *"safari"* ]]; then
   if ! command -v safari >/dev/null; then
      fancy_echo "No install needed on MacOS for GIT_BROWSER=\"safari\"."
      # /usr/bin/safaridriver
   else
      fancy_echo "No upgrade on MacOS for GIT_BROWSER=\"safari\"."
   fi
   git config --global web.browser safari

   #fancy_echo "Opening safari ..."
   #safari
fi


# See Complications at
# https://stackoverflow.com/questions/19907152/how-to-set-google-chrome-as-git-default-browser

# [web]
# browser = google-chrome
#[browser "chrome"]
#    cmd = C:/Program Files (x86)/Google/Chrome/Application/chrome.exe
#    path = C:/Program Files (x86)/Google/Chrome/Application/

if [[ "$GIT_BROWSER" == *"chrome"* ]]; then
   # google-chrome is the most tested and popular.
   if [ ! -d "/Applications/Google Chrome.app" ]; then 
      fancy_echo "Installing GIT_BROWSER=\"google-chrome\" using Homebrew ..."
      brew cask uninstall google-chrome
      brew cask install --appdir="/Applications" google-chrome
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading GIT_BROWSER=\"google-chrome\" using Homebrew ..."
         brew cask upgrade google-chrome
      else
         fancy_echo "GIT_BROWSER=\"google-chrome\" already installed."
      fi
   fi
   git config --global web.browser google-chrome

   # fancy_echo "Opening Google Chrome ..."
   # open "/Applications/Google Chrome.app"
fi


if [[ "$GIT_BROWSER" == *"firefox"* ]]; then
   # firefox is more respectful of user data.
   if [ ! -d "/Applications/Firefox.app" ]; then 
      fancy_echo "Installing GIT_BROWSER=\"firefox\" using Homebrew ..."
      brew cask uninstall firefox
      brew cask install --appdir="/Applications" firefox
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading GIT_BROWSER=\"firefox\" using Homebrew ..."
         brew cask upgrade firefox
      else
         fancy_echo "GIT_BROWSER=\"firefox\" already installed."
      fi
   fi
   git config --global web.browser firefox

   #fancy_echo "Opening firefox ..."
   #open "/Applications/Firefox.app"
fi


if [[ "$GIT_BROWSER" == *"brave"* ]]; then
   # brave is more respectful of user data.
   if [ ! -d "/Applications/Brave.app" ]; then 
      fancy_echo "Installing GIT_BROWSER=\"brave\" using Homebrew ..."
      brew cask uninstall brave
      brew cask install --appdir="/Applications" brave
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading GIT_BROWSER=\"brave\" using Homebrew ..."
         brew cask upgrade brave
      else
         fancy_echo "GIT_BROWSER=\"brave\" already installed."
      fi
   fi
   git config --global web.browser brave

   # fancy_echo "Opening brave ..."
   # open "/Applications/brave.app"
fi

# Other alternatives listed at https://git-scm.com/docs/git-web--browse.html

   # brew install links

   #git config --global web.browser cygstart
   #git config --global browser.cygstart.cmd cygstart


######### Diff/merge tools:


# Based on https://gist.github.com/tony4d/3454372 
fancy_echo "Configuring to enable git mergetool..."
if [[ $GITCONFIG = *"[difftool]"* ]]; then  # contains text.
   fancy_echo "[difftool] p4merge already in $GITCONFIG"
else
   fancy_echo "Adding [difftool] p4merge in $GITCONFIG..."
   git config --global merge.tool p4mergetool
   git config --global mergetool.p4mergetool.cmd "/Applications/p4merge.app/Contents/Resources/launchp4merge \$PWD/\$BASE \$PWD/\$REMOTE \$PWD/\$LOCAL \$PWD/\$MERGED"
   # false = prompting:
   git config --global mergetool.p4mergetool.trustExitCode false
   git config --global mergetool.keepBackup true

   git config --global diff.tool p4mergetool
   git config --global difftool.prompt false
   git config --global difftool.p4mergetool.cmd "/Applications/p4merge.app/Contents/Resources/launchp4merge \$LOCAL \$REMOTE"

   # Auto-type in "adduid":
   # gpg --edit-key "$KEY" answer adduid"
   # NOTE: By using git config command, repeated invocation would not duplicate lines.

   # git mergetool
   # You will be prompted to run "p4mergetool", hit enter and the visual merge editor will launch.

   # See https://danlimerick.wordpress.com/2011/06/19/git-for-window-tip-use-p4merge-as-mergetool/
   # git difftool

fi


######### Local Linter services:


# This Bash file was run through online at https://www.shellcheck.net/
# See https://github.com/koalaman/shellcheck#user-content-in-your-editor

# To ignore/override an error identified:
# shellcheck disable=SC1091

brew install shellcheck

# This enables Git hooks to run on pre-commit to check Bash scripts being committed.


######### Git clients:


fancy_echo "GIT_CLIENT=$GIT_CLIENT in secrets.sh ..."
echo "The last one installed is set as the Git client."
# See https://www.slant.co/topics/465/~best-git-clients-for-macos
          # git, cola, github, gitkraken, smartgit, sourcetree, tower, magit, gitup. 
          # See https://git-scm.com/download/gui/linux
          # https://www.slant.co/topics/465/~best-git-clients-for-macos


if ! command -v git >/dev/null; then
    fancy_echo "Installing git using Homebrew ..."
    brew install git
else
    if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
       git --version
       fancy_echo "Git already installed: UPGRADE requested..."
       # To avoid response "Error: git not installed" to brew upgrade git
       brew uninstall git
       # QUESTION: This removes .gitconfig file?
       brew install git
    else
       fancy_echo "Git already installed:"
    fi
fi
echo -e "\n$(git --version)"            >>$THISSCRIPT.log
#git --version
    # git version 2.14.3 (Apple Git-98)

#[core]
#  editor = vim
#  whitespace = fix,-indent-with-non-tab,trailing-space,cr-at-eol
#  excludesfile = ~/.gitignore
#[push]
#  default = matching

#[diff]
#  tool = vimdiff
#[difftool]
#  prompt = false

if [[ "$GIT_CLIENT" == *"cola"* ]]; then
   # https://git-cola.github.io/  (written in Python)
   # https://medium.com/@hamen/installing-git-cola-on-osx-eaa9368b4ee
   if ! command -v git-cola >/dev/null; then  # not recognized:
      PYTHON_INSTALL  # function defined at top of this file.
      fancy_echo "Installing GIT_CLIENT=\"cola\" using Homebrew ..."
      brew install git-cola
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading GIT_CLIENT=\"cola\" using Homebrew ..."
         brew upgrade git-cola
      else
         fancy_echo "GIT_CLIENT=\"cola\" already installed"
      fi
   fi
   git-cola --version
      # cola version 3.0

   fancy_echo "Starting git-cola in background ..."
   git-cola &
fi


# GitHub Desktop is written by GitHub, Inc.,
# open sourced at https://github.com/desktop/desktop
# so people can just click a button on GitHub to download a repo from an internet browser.
if [[ "$GIT_CLIENT" == *"github"* ]]; then
    # https://desktop.github.com/
    if [ ! -d "/Applications/GitHub Desktop.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"github\" using Homebrew ..."
        brew cask uninstall github
        brew cask install --appdir="/Applications" github
    else
        if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
           fancy_echo "Upgrading GIT_CLIENT=\"github\" using Homebrew ..."
           brew cask upgrade github
        else
           fancy_echo "GIT_CLIENT=\"github\" already installed"
        fi
    fi
   fancy_echo "Opening GitHub Desktop ..."
   open "/Applications/GitHub Desktop.app"
fi



if [[ "$GIT_CLIENT" == *"gitkraken"* ]]; then
    # GitKraken from https://www.gitkraken.com/ and https://blog.axosoft.com/gitflow/
    if [ ! -d "/Applications/GitKraken.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"gitkraken\" using Homebrew ..."
        brew cask uninstall gitkraken
        brew cask install --appdir="/Applications" gitkraken
    else
        if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
           fancy_echo "Upgrading GIT_CLIENT=\"gitkraken\" using Homebrew ..."
           brew cask upgrade gitkraken
        else
           fancy_echo "GIT_CLIENT=\"gitkraken\" already installed"
        fi
    fi
   fancy_echo "Opening GitKraken ..."
   open "/Applications/GitKraken.app"
fi


if [[ "$GIT_CLIENT" == *"sourcetree"* ]]; then
    # See https://www.sourcetreeapp.com/
    if [ ! -d "/Applications/Sourcetree.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"sourcetree\" using Homebrew ..."
        brew cask uninstall sourcetree
        brew cask install --appdir="/Applications" sourcetree
    else
        if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
           fancy_echo "Upgrading GIT_CLIENT=\"sourcetree\" using Homebrew ..."
           brew cask upgrade sourcetree
           # WARNING: This requires your MacOS password.
        else
           fancy_echo "GIT_CLIENT=\"sourcetree\" already installed:"
        fi
    fi
   fancy_echo "Opening Sourcetree ..."
   open "/Applications/Sourcetree.app"
fi


if [[ "$GIT_CLIENT" == *"smartgit"* ]]; then
    # SmartGit from https://syntevo.com/smartgit
    if [ ! -d "/Applications/SmartGit.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"smartgit\" using Homebrew ..."
        brew cask uninstall smartgit
        brew cask install --appdir="/Applications" smartgit
    else
        if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
           fancy_echo "Upgrading GIT_CLIENT=\"smartgit\" using Homebrew ..."
           brew cask upgrade smartgit
        else
           fancy_echo "GIT_CLIENT=\"smartgit\" already installed:"
        fi
    fi
   fancy_echo "Opening SmartGit ..."
   open "/Applications/SmartGit.app"
fi


if [[ "$GIT_CLIENT" == *"tower"* ]]; then
    # Tower from https://www.git-tower.com/learn/git/ebook/en/desktop-gui/advanced-topics/git-flow
    if [ ! -d "/Applications/Tower.app" ]; then 
        fancy_echo "Installing GIT_CLIENT=\"tower\" using Homebrew ..."
        brew cask uninstall tower
        brew cask install --appdir="/Applications" tower
    else
        if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
           fancy_echo "Upgrading GIT_CLIENT=\"tower\" using Homebrew ..."
           brew cask upgrade tower
        else
           fancy_echo "GIT_CLIENT=\"tower\" already installed"
        fi
    fi

   fancy_echo "Opening Tower ..."
   open "/Applications/Tower.app"
fi


if [[ "$GIT_CLIENT" == *"magit"* ]]; then
    # See https://www.slant.co/topics/465/viewpoints/18/~best-git-clients-for-macos~macvim
    #     "Useful only for people who use Emacs text editor."
    # https://magit.vc/manual/magit/
    if ! command -v magit >/dev/null; then
        fancy_echo "Installing GIT_CLIENT=\"magit\" using Homebrew ..."
         brew tap dunn/emacs
         brew install magit
    else
        if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
           fancy_echo "Upgrading GIT_CLIENT=\"magit\" using Homebrew ..."
           brew upgrade magit
        else
           fancy_echo "GIT_CLIENT=\"magit\" already installed:"
        fi
    fi
   # TODO: magit -v
   # magit & 
fi


if [[ "$GIT_CLIENT" == *"gitup"* ]]; then
   # http://gitup.co/
   # https://github.com/git-up/GitUp
   # https://gitup.vc/manual/gitup/
   if ! command -v gitup >/dev/null; then
      fancy_echo "Installing GIT_CLIENT=\"gitup\" using Homebrew ..."
      # https://s3-us-west-2.amazonaws.com/gitup-builds/stable/GitUp.zip
      brew cask install --appdir="/Applications" gitup
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "Upgrading GIT_CLIENT=\"gitup\" using Homebrew ..."
         brew upgrade gitup
      else
         fancy_echo "GIT_CLIENT=\"gitup\" already installed:"
      fi
   fi
   # gitup -v

   fancy_echo "Starting GitUp in background ..."
   # gitup &
fi



######### Git tig repo viewer:


if [[ "$GIT_TOOLS" == *"tig"* ]]; then
   if ! command -v tig >/dev/null; then  # in /usr/local/bin/tig
      fancy_echo "Installing tig for formatting git logs ..."
      brew install tig
      # See https://jonas.github.io/tig/
      # A sample of the default configuration has been installed to:
      #   /usr/local/opt/tig/share/tig/examples/tigrc
      # to override the system-wide default configuration, copy the sample to:
      #   /usr/local/etc/tigrc
      # Bash completion has been installed to:
      #   /usr/local/etc/bash_completion.d
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         tig version | grep tig  
          # git version 2.16.3
          # tig version 2.2.9
         fancy_echo "tig already installed: UPGRADE requested..."
         brew upgrade tig 
      else
         fancy_echo "tig already installed:"
      fi
  fi
  echo -e "\n   tig --version:" >>$THISSCRIPT.log
  echo -e "$(tig --version)" >>$THISSCRIPT.log
   # tig version 2.3.3
fi


######### BFG to identify and remove passwords and large or troublesome blobs.


# See https://rtyley.github.io/bfg-repo-cleaner/ 

# Install sub-folder under git-utilities:
# git clone https://github.com/rtyley/bfg-repo-cleaner --depth=0

#git clone --mirror $WORK_REPO  # = git://example.com/some-big-repo.git

#JAVA_INSTALL

#java -jar bfg.jar --replace-text banned.txt \
#    --strip-blobs-bigger-than 100M \
#    $SECRETSFILE


######### Git Large File Storage:


# Git Large File Storage (LFS) replaces large files such as audio samples, videos, datasets, and graphics with text pointers inside Git, while storing the file contents on a remote server like GitHub.com or GitHub Enterprise. During install .gitattributes are defined.
# See https://git-lfs.github.com/
# See https://help.github.com/articles/collaboration-with-git-large-file-storage/
# https://www.atlassian.com/git/tutorials/git-lfs
# https://www.youtube.com/watch?v=p3Pse1UkEhI

if [[ "$GIT_TOOLS" == *"lfs"* ]]; then
   if ! command -v git-lfs >/dev/null; then  # in /usr/local/bin/git-lfs
      fancy_echo "Installing git-lfs for managing large files in git ..."
      brew install git-lfs
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         git-lfs version 
            # git-lfs/2.4.0 (GitHub; darwin amd64; go 1.10)
         fancy_echo "git-lfs already installed: UPGRADE requested..."
         brew upgrade git-lfs 
      else
         fancy_echo "git-lfs already installed:"
      fi
   fi
   echo -e "\n   git-lfs version:" >>$THISSCRIPT.log
   echo -e "$(git-lfs version)" >>$THISSCRIPT.log
   # git-lfs/2.4.0 (GitHub; darwin amd64; go 1.10)

   # Update global git config (creates hooks pre-push, post-checkout, post-commit, post-merge)
   #  git lfs install

   # Update system git config:
   #  git lfs install --system

   # See https://help.github.com/articles/configuring-git-large-file-storage/
   # Set LFS to kick into action based on file name extensions such as *.psd by
   # running command:  (See https://git-scm.com/docs/gitattributes)
   # git lfs track "*.psd"
   #    The command appends to the repository's .gitattributes file:
   # *.psd filter=lfs diff=lfs merge=lfs -text

   #  git lfs track "*.mp4"
   #  git lfs track "*.mp3"
   #  git lfs track "*.jpeg"
   #  git lfs track "*.jpg"
   #  git lfs track "*.png"
   #  git lfs track "*.ogg"
   # CAUTION: Quotes are important in the entries above.
   # CAUTION: Git clients need to be LFS-aware.

   # Based on https://github.com/git-lfs/git-lfs/issues/1720
   git config lfs.transfer.maxretries 10

   # Define alias to stop lfs
   #git config --global alias.plfs "\!git -c filter.lfs.smudge= -c filter.lfs.required=false pull && git lfs pull"
   #$ git plfs
fi

######### TODO: .gitattributes


# See https://github.com/alexkaratarakis/gitattributes for templates
# Make sure .gitattributes is tracked
# git add .gitattributes
# TODO: https://github.com/alexkaratarakis/gitattributes/blob/master/Common.gitattributes


######### Text editors:


# Specified in secrets.sh
          # nano, pico, vim, sublime, code, atom, macvim, textmate, emacs, intellij, sts, eclipse.
          # NOTE: nano and vim are built into MacOS, so no install.
fancy_echo "GIT_EDITOR=$GIT_EDITOR..."
      echo "The last one installed is the Git default."

# INFO: https://danlimerick.wordpress.com/2011/06/12/git-for-windows-tip-setting-an-editor/
# https://insights.stackoverflow.com/survey/2018/#development-environments-and-tools
#    Says vim is the most popular among Sysadmins. 

if [[ "$GIT_CLIENT" == *"nano"* ]]; then
   git config --global core.editor nano
fi

if [[ "$GIT_CLIENT" == *"vim"* ]]; then
   git config --global core.editor vim
fi

if [[ "$GIT_CLIENT" == *"pico"* ]]; then
   git config --global core.editor pico
fi

if [[ "$GIT_EDITOR" == *"sublime"* ]]; then
   # /usr/local/bin/subl
   if [ ! -d "/Applications/Sublime Text.app" ]; then 
      fancy_echo "Installing Sublime Text text editor using Homebrew ..."
      brew cask uninstall sublime-text
      brew cask install --appdir="/Applications" sublime-text
 
      if grep -q "/usr/local/bin/subl" "$BASHFILE" ; then    
         fancy_echo "PATH to Sublime already in $BASHFILE"
      else
         fancy_echo "Adding PATH to SublimeText in $BASHFILE..."
         echo "" >>"$BASHFILE"
         echo "export PATH=\"\$PATH:/usr/local/bin/subl\"" >>"$BASHFILE"
         source "$BASHFILE"
      fi 
 
      if grep -q "alias subl=" "$BASHFILE" ; then
         fancy_echo "PATH to Sublime already in $BASHFILE"
      else
         echo "" >>"$BASHFILE"
         echo "alias subl='open -a \"/Applications/Sublime Text.app\"'" >>"$BASHFILE"
         source "$BASHFILE"
      fi 
      # Only install the following during initial install:
      # TODO: Configure Sublime for spell checker, etc. https://github.com/SublimeLinter/SublimeLinter-shellcheck
      # install Package Control see https://gist.github.com/patriciogonzalezvivo/77da993b14a48753efda
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         subl --version
            # Sublime Text Build 3143
         fancy_echo "Sublime Text already installed: UPGRADE requested..."
            # To avoid response "Error: git not installed" to brew upgrade git
         brew cask reinstall sublime-text
      else
         fancy_echo "Sublime Text already installed:"
      fi
   fi
   git config --global core.editor code
   echo -e "\n$(subl --version)" >>$THISSCRIPT.log
   #subl --version
      # Sublime Text Build 3143

   #fancy_echo "Opening Sublime Text app in background ..."
   #subl &
fi


if [[ "$GIT_CLIENT" == *"textedit"* ]]; then 
   # TextEdit comes with MacOS:
      if grep -q "alias textedit=" "$BASHFILE" ; then    
         fancy_echo "PATH to TextEdit.app already in $BASHFILE"
      else
         fancy_echo "Adding PATH to TextEdit.app in $BASHFILE..."
         echo "alias textedit='open -a \"/Applications/TextEdit.app\"'" >>"$BASHFILE"
      fi 
   git config --global core.editor textedit
fi


if [[ "$GIT_EDITOR" == *"code"* ]]; then
    if ! command -v code >/dev/null; then
        fancy_echo "Installing Visual Studio Code text editor using Homebrew ..."
        brew install visual-studio-code
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          code --version
          fancy_echo "VS Code already installed: UPGRADE requested..."
          # No upgrade - "Error: No available formula with the name "visual-studio-code" 
          brew uninstall visual-studio-code
          brew install visual-studio-code
       else
          fancy_echo "VS Code already installed:"
       fi
    fi
    git config --global core.editor code
    echo "Visual Studio Code: $(code --version)" >>$THISSCRIPT.log
    # code --version
      # 1.21.1
      # 79b44aa704ce542d8ca4a3cc44cfca566e7720f1
      # x64

   # https://github.com/timonwong/vscode-shellcheck
   fancy_echo "Installing Visual Studio Code Shellcheck extension"
   code --install-extension timonwong.shellcheck
   #fancy_echo "Opening Visual Studio Code ..."
   #open "/Applications/Visual Studio Code.app"
   #fancy_echo "Starting code in background ..."
   #code &
fi


if [[ "$GIT_EDITOR" == *"atom"* ]]; then
   if ! command -v atom >/dev/null; then
      fancy_echo "Installing GIT_EDITOR=\"atom\" text editor using Homebrew ..."
      brew cask install --appdir="/Applications" atom
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          atom --version
             # 
          fancy_echo "GIT_EDITOR=\"atom\" already installed: UPGRADE requested..."
          # To avoid response "Error: No available formula with the name "atom"
          brew uninstall atom
          brew install atom
       else
          fancy_echo "GIT_EDITOR=\"atom\" already installed:"
       fi
    fi
    git config --global core.editor atom

    # TODO: Add plug-in https://github.com/AtomLinter/linter-shellcheck

   # Configure plug-ins:
   #apm install linter-shellcheck

   echo -e "\n$(atom --version)"            >>$THISSCRIPT.log
   #atom --version
      # Atom    : 1.20.1
      # Electron: 1.6.9
      # Chrome  : 56.0.2924.87
      # Node    : 7.4.0
      # Wilsons-MacBook-Pro

   #fancy_echo "Starting atom in background ..."
   #atom &
fi


if [[ "$GIT_EDITOR" == *"macvim"* ]]; then
    if [ ! -d "/Applications/MacVim.app" ]; then
        fancy_echo "Installing GIT_EDITOR=\"macvim\" text editor using Homebrew ..."
        brew cask uninstall macvim
        brew cask install --appdir="/Applications" macvim
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          fancy_echo "GIT_EDITOR=\"macvim\" already installed: UPGRADE requested..."
          # To avoid response "==> No Casks to upgrade" on uprade:
          brew cask uninstall macvim
          brew cask install --appdir="/Applications" macvim
          # TODO: Configure macvim text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"macvim\" already installed:"
       fi
    fi
 
    if grep -q "alias macvim=" "$BASHFILE" ; then
       fancy_echo "PATH to MacVim already in $BASHFILE"
    else
       echo "alias macvim='open -a \"/Applications/MacVim.app\"'" >>"$BASHFILE"
       source "$BASHFILE"
    fi 

   # git config --global core.editor macvim
   # TODO: macvim --version
   #fancy_echo "Starting macvim in background ..."
   #macvim &
fi


if [[ "$GIT_EDITOR" == *"textmate"* ]]; then
    if [ ! -d "/Applications/textmate.app" ]; then 
        fancy_echo "Installing GIT_EDITOR=\"textmate\" text editor using Homebrew ..."
        brew cask uninstall textmate
        brew cask install --appdir="/Applications" textmate
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          mate -v
          fancy_echo "GIT_EDITOR=\"textmate\" already installed: UPGRADE requested..."
          brew cask uninstall textmate
          brew cask install --appdir="/Applications" textmate
          # TODO: Configure textmate text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"textmate\" already installed:"
       fi
   fi

        # Per https://stackoverflow.com/questions/4011707/how-to-start-textmate-in-command-line
        # Create a symboling link to bin folder
        ln -s /Applications/TextMate.app/Contents/Resources/mate "$HOME/bin/mate"

        if grep -q "export EDITOR=" "$BASHFILE" ; then    
           fancy_echo "export EDITOR= already in $BASHFILE."
        else
           fancy_echo "Concatenating \"export EDITOR=\" in $BASHFILE..."
           echo "export EDITOR=\"/usr/local/bin/mate -w\" " >>"$BASHFILE"
        fi

   echo -e "\n$(mate -v)" >>$THISSCRIPT.log
   #mate -v
      #mate 2.12 (2018-03-08) 
   git config --global core.editor textmate

   #fancy_echo "Starting mate (textmate) in background ..."
   #mate &
fi


if [[ "$GIT_EDITOR" == *"emacs"* ]]; then
    if ! command -v emacs >/dev/null; then
        fancy_echo "Installing emacs text editor using Homebrew ..."
        brew cask install --appdir="/Applications" emacs
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          emacs --version
             # /usr/local/bin/emacs:41: warning: Insecure world writable dir /Users/wilsonmar/gits/wilsonmar in PATH, mode 040777
             # GNU Emacs 25.3.1
          fancy_echo "emacs already installed: UPGRADE requested..."
          brew cask upgrade emacs
          # TODO: Configure emacs using bash shell commands.
       else
          fancy_echo "emacs already installed:"
       fi
    fi
    git config --global core.editor emacs
    echo -e "\n$(emacs --version)" >>$THISSCRIPT.log
    #emacs --version

    # Evaluate https://github.com/git/git/tree/master/contrib/emacs

   #fancy_echo "Opening emacs in background ..."
   #emacs &
fi


if [[ "$GIT_EDITOR" == *"intellij"* ]]; then
    # See http://macappstore.org/intellij-idea-ce/
   if [ ! -d "/Applications/IntelliJ IDEA CE.app" ]; then 
       fancy_echo "Installing GIT_EDITOR=\"intellij\" text editor using Homebrew ..."
       brew cask uninstall intellij-idea-ce
       brew cask install --appdir="/Applications" intellij-idea-ce 
       # alias idea='open -a "`ls -dt /Applications/IntelliJ\ IDEA*|head -1`"'
        # TODO: Configure intellij text editor using bash shell commands.
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         # TODO: idea  --version
            # 
         fancy_echo "GIT_EDITOR=\"intellij\" already installed: UPGRADE requested..."
         brew cask upgrade intellij-idea-ce 
      else
         fancy_echo "GIT_EDITOR=\"intellij\" already installed:"
      fi
    fi

    # See https://emmanuelbernard.com/blog/2017/02/27/start-intellij-idea-command-line/   
        if grep -q "alias idea=" "$BASHFILE" ; then    
           fancy_echo "alias idea= already in $BASHFILE."
        else
           fancy_echo "Concatenating \"alias idea=\" in $BASHFILE..."
           echo "alias idea='open -a \"$(ls -dt /Applications/IntelliJ\ IDEA*|head -1)\"'" >>"$BASHFILE"
           source "$BASHFILE"
        fi 
    git config --global core.editor idea
    # TODO: idea --version

   #fancy_echo "Opening IntelliJ IDEA CE ..."
   #open "/Applications/IntelliJ IDEA CE.app"
   #fancy_echo "Opening (Intellij) idea in background ..."
   #idea &
fi
# See https://www.jetbrains.com/help/idea/using-git-integration.html

# https://gerrit-review.googlesource.com/Documentation/dev-intellij.html


if [[ "$GIT_EDITOR" == *"sts"* ]]; then
    # See http://macappstore.org/sts/
    if [ ! -d "/Applications/STS.app" ]; then 
        fancy_echo "Installing GIT_EDITOR=\"sts\" text editor using Homebrew ..."
        brew cask uninstall sts
        brew cask install --appdir="/Applications" sts
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          # TODO: sts --version
             # 
          fancy_echo "GIT_EDITOR=\"sts\" already installed: UPGRADE requested..."
          brew cask uninstall sts
          brew cask install --appdir="/Applications" sts
          # TODO: Configure sts text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"sts\" already installed:"
       fi
    fi
    # Based on https://emmanuelbernard.com/blog/2017/02/27/start-intellij-idea-command-line/   
        if grep -q "alias sts=" "$BASHFILE" ; then    
           fancy_echo "alias sts= already in $BASHFILE."
        else
           fancy_echo "Concatenating \"export sts=\" in $BASHFILE..."
           echo " " >>"$BASHFILE"
           echo "alias sts='open -a \"/Applications/STS.app\"'" >>"$BASHFILE"
           source "$BASHFILE"
        fi 
    git config --global core.editor sts
    # TODO: sts --version

   #fancy_echo "Opening STS ..."
   #open "/Applications/STS.app"
   #fancy_echo "Opening sts in background ..."
   #sts &
fi


if [[ "$GIT_EDITOR" == *"eclipse"* ]]; then
    # See http://macappstore.org/eclipse-ide/
    if [ ! -d "/Applications/Eclipse.app" ]; then 
        fancy_echo "Installing GIT_EDITOR=\"eclipse\" text editor using Homebrew ..."
        brew cask uninstall eclipse-ide
        brew cask install --appdir="/Applications" eclipse-ide
    else
       if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
          # TODO: eclipse-ide --version
             # 
          fancy_echo "GIT_EDITOR=\"eclipse\" already installed: UPGRADE requested..."
          brew cask uninstall eclipse-ide
          brew cask install --appdir="/Applications" eclipse-ide
          # TODO: Configure eclipse text editor using bash shell commands.
       else
          fancy_echo "GIT_EDITOR=\"eclipse\" already installed:"
       fi
    fi

   if grep -q "alias eclipse=" "$BASHFILE" ; then    
       fancy_echo "alias eclipse= already in $BASHFILE."
   else
       fancy_echo "Concatenating \"alias eclipse=\" in $BASHFILE..."
       echo "alias eclipse='open \"/Applications/Eclipse.app\"'" >>"$BASHFILE"
       source "$BASHFILE"
   fi 
   #git config --global core.editor eclipse

   # See http://www.codeaffine.com/gonsole/ = Git Console for the Eclipse IDE (plug-in)
   # https://rherrmann.github.io/gonsole/repository/
   # The plug-in uses JGit, a pure Java implementation of Git, to interact with the repository.
   #git config --global core.editor eclipse
   # TODO: eclipse-ide --version

   #fancy_echo "Opening eclipse in background ..."
   #eclipse &
   # See https://www.cs.colostate.edu/helpdocs/eclipseCommLineArgs.html
fi


######### Eclipse settings:


# Add the "clean-sheet" Ergonomic Eclipse Theme for Windows 10 and Mac OS X.
# http://www.codeaffine.com/2015/11/04/clean-sheet-an-ergonomic-eclipse-theme-for-windows-10/


######### ~/.gitconfig [user] and [core] settings:


# ~/.gitconfig file contain this examples:
#[user]
#	name = Wilson Mar
#	id = WilsonMar+GitHub@gmail.com
#	email = wilsonmar+github@gmail.com

   fancy_echo "Adding [user] info in in $GITCONFIG ..."
   git config --global user.name     "$GIT_NAME"
   git config --global user.email    "$GIT_EMAIL"
   git config --global user.id       "$GIT_ID"
   git config --global user.username "$GIT_USERNAME"

#[core]
#	# Use custom `.gitignore`
#	excludesfile = ~/.gitignore
#   hitespace = space-before-tab,indent-with-non-tab,trailing-space

#fancy_echo "Configuring core git settings ..."
   # Use custom `.gitignore`
   git config --global core.excludesfile "~/.gitignore"
   # Treat spaces before tabs, lines that are indented with 8 or more spaces, and all kinds of trailing whitespace as an error
   git config --global core.hitespace "space-before-tab,indent-with-non-tab,trailing-space"


######### Git coloring in .gitconfig:


# If git config color.ui returns true, skip:
git config color.ui | grep 'true' &> /dev/null
if [ $? == 0 ]; then
   fancy_echo "git config --global color.ui already true (on)."
else # false or blank response:
   fancy_echo "Setting git config --global color.ui true (on)..."
   git config --global color.ui true
fi

#[color]
#	ui = true

if grep -q "color.status=auto" "$GITCONFIG" ; then    
   fancy_echo "color.status=auto already in $GITCONFIG"
else
   fancy_echo "Adding color.status=auto in $GITCONFIG..."
   git config --global color.status auto
   git config --global color.branch auto
   git config --global color.interactive auto
   git config --global color.diff auto
   git config --global color.pager true

   # normal, black, red, green, yellow, blue, magenta, cyan, white
   # Attributes: bold, dim, ul, blink, reverse, italic, strike
   git config --global color.status.added     "green   normal bold"
   git config --global color.status.changed   "blue    normal bold"
   git config --global color.status.header    "white   normal dim"
   git config --global color.status.untracked "cyan    normal bold"

   git config --global color.branch.current   "yellow  reverse"
   git config --global color.branch.local     "yellow  normal bold"
   git config --global color.branch.remote    "cyan    normal dim"

   git config --global color.diff.meta        "yellow  normal bold"
   git config --global color.diff.frag        "magenta normal bold"
   git config --global color.diff.old         "blue    normal strike"
   git config --global color.diff.new         "green   normal bold"
   git config --global color.diff.whitespace  "red     normal reverse"
fi


######### diff-so-fancy color:


if [[ "$GIT_TOOLS" == *"diff-so-fancy"* ]]; then
   if ! command -v diff-so-fancy >/dev/null; then
      fancy_echo "Installing GIT_TOOLS=\"diff-so-fancy\" using Homebrew ..."
      brew install diff-so-fancy
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "GIT_EDITOR=\"diff-so-fancy\" already installed: UPGRADE requested..."
         brew cask upgrade diff-so-fancy
      else
         fancy_echo "GIT_EDITOR=\"diff-so-fancy\" already installed:"
      fi
   fi
   # Configuring based on https://github.com/so-fancy/diff-so-fancy
   git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

   # Default Git colors are not optimal. We suggest the following colors instead.
   git config --global color.diff-highlight.oldNormal    "red bold"
   git config --global color.diff-highlight.oldHighlight "red bold 52"
   git config --global color.diff-highlight.newNormal    "green bold"
   git config --global color.diff-highlight.newHighlight "green bold 22"

   git config --global color.diff.meta       "yellow"
   git config --global color.diff.frag       "magenta bold"
   git config --global color.diff.commit     "yellow bold"
   git config --global color.diff.old        "red bold"
   git config --global color.diff.new        "green bold"
   git config --global color.diff.whitespace "red reverse"

   # Should the first block of an empty line be colored. (Default: true)
   git config --bool --global diff-so-fancy.markEmptyLines false

   # Simplify git header chunks to a more human readable format. (Default: true)
   git config --bool --global diff-so-fancy.changeHunkIndicators false

   # stripLeadingSymbols - Should the pesky + or - at line-start be removed. (Default: true)
   git config --bool --global diff-so-fancy.stripLeadingSymbols false

   # useUnicodeRuler By default the separator for the file header uses Unicode line drawing characters. If this is causing output errors on your terminal set this to false to use ASCII characters instead. (Default: true)
   git config --bool --global diff-so-fancy.useUnicodeRuler false

   # To bypass diff-so-fancy. Use --no-pager for that:
   #git --no-pager diff
fi



######### Reuse Recorded Resolution of conflicted merges


# See https://git-scm.com/docs/git-rerere
# and https://git-scm.com/book/en/v2/Git-Tools-Rerere

#[rerere]
#  enabled = 1
#  autoupdate = 1
   git config --global rerere.enabled  "1"
   git config --global rerere.autoupdate  "1"



######### ~/.bash_profile prompt settings:


# https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
# See http://maximomussini.com/posts/bash-git-prompt/

# BTW, for completion of bash commands on MacOS:
# brew install bash-completion
# Also see https://github.com/barryclark/bashstrap

if ! command -v brew >/dev/null; then
   fancy_echo "Installing bash-git-prompt using Homebrew ..."
   # From https://github.com/magicmonty/bash-git-prompt
   brew install bash-git-prompt

   if grep -q "gitprompt.sh" "$BASHFILE" ; then    
      fancy_echo "gitprompt.sh already in $BASHFILE"
   else
      fancy_echo "Adding gitprompt.sh in $BASHFILE..."
      echo "if [ -f \"/usr/local/opt/bash-git-prompt/share/gitprompt.sh\" ]; then" >>"$BASHFILE"
      echo "   __GIT_PROMPT_DIR=\"/usr/local/opt/bash-git-prompt/share\" " >>"$BASHFILE"
      echo "   source \"/usr/local/opt/bash-git-prompt/share/gitprompt.sh\" " >>"$BASHFILE"
      echo "fi" >>"$BASHFILE"
   fi
else
    if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
       # ?  --version
       fancy_echo "Brew already installed: UPGRADE requested..."
       brew upgrade bash-git-prompt
    else
       fancy_echo "brew bash-git-prompt already installed:"
    fi
fi
# ? --version


######### bash colors:


   if grep -q "export CLICOLOR" "$BASHFILE" ; then    
      fancy_echo "export CLICOLOR already in $BASHFILE"
   else
      fancy_echo "Adding export CLICOLOR in $BASHFILE..."
      echo "export CLICOLOR=1" >>"$BASHFILE"
   fi

######### Git command completion in ~/.bash_profile:


# So you can type "git st" and press Tab to complete as "git status".
# See video on this: https://www.youtube.com/watch?v=VI07ouVS5FE
# If git-completion.bash file is already in home folder, download it:
FILE=.git-completion.bash
FILEPATH=~/.git-completion.bash
# If git-completion.bash file is mentioned in  ~/.bash_profile, add it:
if [ -f $FILEPATH ]; then 
   fancy_echo "List file to confirm size:"
   ls -al $FILEPATH
      # -rw-r--r--  1 wilsonmar  staff  68619 Mar 21 10:31 /Users/wilsonmar/.git-completion.bash
else
   fancy_echo "Download in home directory the file maintained by git people:"
   curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o $FILEPATH
   # alt # cp $FILE  ~/$FILEPATH
fi

# if internet download fails, use saved copy in GitHub repo:
if [ ! -f $FILEPATH ]; then 
   fancy_echo "Copy file saved in GitHub repo:"
   cp $FILE  $FILEPATH
fi

# show first line of file:
# line=$(read -r FIRSTLINE < ~/.git-completion.bash )


######### Git alias keys


# If git-completion.bash file is not already in  ~/.bash_profile, add it:
if grep -q "$FILEPATH" "$BASHFILE" ; then    
   fancy_echo "$FILEPATH already in $BASHFILE"
else
   fancy_echo "Adding code for $FILEPATH in $BASHFILE..."
   echo "# Added by mac-git-install.sh ::" >>"$BASHFILE"
   echo "if [ -f $FILEPATH ]; then" >>"$BASHFILE"
   echo "   . $FILEPATH" >>"$BASHFILE"
   echo "fi" >>"$BASHFILE"
   cat $FILEPATH >>"$BASHFILE"
fi 

# Run .bash_profile to have changes above take:
   source "$BASHFILE"


######### Difference engine p4merge:


if [[ "$GIT_TOOLS" == *"p4merge"* ]]; then
   # See https://www.perforce.com/products/helix-core-apps/merge-diff-tool-p4merge
   if [ ! -d "/Applications/p4merge.app" ]; then 
      fancy_echo "Installing p4merge diff engine app using Homebrew ..."
      brew cask uninstall p4merge
      brew cask install --appdir="/Applications" p4merge
      # TODO: Configure p4merge using shell commands.
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         # p4merge --version
         fancy_echo "p4merge diff engine app already installed: UPGRADE requested..."
         # To avoid response "Error: git not installed" to brew upgrade git
         brew cask reinstall p4merge
      else
         fancy_echo "p4merge diff engine app already installed:"
      fi
   fi
   # TODO: p4merge --version err in pop-up

   if grep -q "alias p4merge=" "$BASHFILE" ; then    
      fancy_echo "p4merge alias already in $BASHFILE"
   else
      fancy_echo "Adding p4merge alias in $BASHFILE..."
      echo "alias p4merge='/Applications/p4merge.app/Contents/MacOS/p4merge'" >>"$BASHFILE"
   fi 
fi

# TODO: Different diff/merge engines


######### Git Repository:

   git config --global github.user   "$GITHUB_ACCOUNT"
   git config --global github.token  token

# https://github.com/
# https://gitlab.com/
# https://bitbucket.org/
# https://travis-ci.org/


######### TODO: Git Flow helper:


if [[ "$GIT_TOOLS" == *"git-flow"* ]]; then
   # GitFlow is a branching model for scaling collaboration using Git, created by Vincent Driessen. 
   # See https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow
   # See https://datasift.github.io/gitflow/IntroducingGitFlow.html
   # https://danielkummer.github.io/git-flow-cheatsheet/
   # https://github.com/nvie/gitflow
   # https://vimeo.com/16018419
   # https://buildamodule.com/video/change-management-and-version-control-deploying-releases-features-and-fixes-with-git-how-to-use-a-scalable-git-branching-model-called-gitflow

   # Per https://github.com/nvie/gitflow/wiki/Mac-OS-X
   if ! command -v git-flow >/dev/null; then
      fancy_echo "Installing git-flow ..."
      brew install git-flow
   else
      fancy_echo "git-flow already installed."
   fi

   #[gitflow "prefix"]
   #  feature = feature-
   #  release = release-
   #  hotfix = hotfix-
   #  support = support-
   #  versiontag = v

   #git clone --recursive git@github.com:<username>/gitflow.git
   #cd gitflow
   #git branch master origin/master
   #git flow init -d
   #git flow feature start <your feature>
fi


######### git local hooks 


# Based https://wilsonmar.github.io/git-hooks/
if [ ! -f ".git/hooks/git-commit" ]; then 
   fancy_echo "git-commit file not found in .git/hooks. Copying hooks folder ..."
   rm .git/hooks/*.sample  # samples are not run
   cp hooks/* .git/hooks   # copy
   chmod +x .git/hooks/*   # make executable
else
   fancy_echo "git-commit file found in .git/hooks. Skipping ..."
fi


######### JAVA_TOOLS:


if [[ "$JAVA_TOOLS" == *"gcviewer"* ]]; then
   if ! command -v gcviewer >/dev/null; then
      fancy_echo "Installing JAVA_TOOLS=gcviewer ..."
      brew install gcviewer
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         # gcviewer --version
         fancy_echo "JAVA_TOOLS=gcviewer already installed: UPGRADE requested..."
         brew upgrade gcviewer 
            # gcviewer 1.35 already installed
      else
         fancy_echo "gcviewer already installed:"
      fi
      #echo -e "\n$(gcviewer --version)" >>$THISSCRIPT.log
   fi
fi

if [[ "$JAVA_TOOLS" == *"jmeter"* ]]; then
   if ! command -v jmeter >/dev/null; then
      fancy_echo "Installing JAVA_TOOLS=jmeter ..."
      brew install jmeter
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         jmeter --version
         fancy_echo "JAVA_TOOLS=jmeter already installed: UPGRADE requested..."
         brew install jmeter 
      else
         fancy_echo "jmeter already installed:"
      fi
   echo -e "\n$(jmeter --version)" >>$THISSCRIPT.log
   fi
fi

if [[ "$JAVA_TOOLS" == *"jprofiler"* ]]; then
   if ! command -v jprofiler >/dev/null; then
      fancy_echo "Installing JAVA_TOOLS=jprofiler ..."
      brew cask install --appdir="/Applications" jprofiler
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         jprofiler --version
         fancy_echo "JAVA_TOOLS=jprofiler already installed: UPGRADE requested..."
         brew cask install --appdir="/Applications" jprofiler 
      else
         fancy_echo "jprofiler already installed:"
      fi
   fi
   echo -e "\n$(jprofiler --version)" >>$THISSCRIPT.log
fi

# https://www.bonusbits.com/wiki/HowTo:Setup_Charles_Proxy_on_Mac
# brew install nmap

######### TODO: Code review:


# Prerequisite: Python
# sudo easy_install pip
# sudo pip install -U setuptools
# sudo pip install git-review


######### Git Signing:

if [[ "$GIT_TOOLS" == *"signing"* ]]; then

   # About http://notes.jerzygangi.com/the-best-pgp-tutorial-for-mac-os-x-ever/
   # See http://blog.ghostinthemachines.com/2015/03/01/how-to-use-gpg-command-line/
      # from 2015 recommends gnupg instead
   # Cheat sheet of commands at http://irtfweb.ifa.hawaii.edu/~lockhart/gpg/

   # If GPG suite is used, add the GPG key to ~/.bash_profile:
   if grep -q "GPG_TTY" "$BASHFILE" ; then    
      fancy_echo "GPG_TTY already in $BASHFILE."
   else
      fancy_echo "Concatenating GPG_TTY export in $BASHFILE..."
      echo "export GPG_TTY=$(tty)" >> "$BASHFILE"
         # echo $(tty) results in: -bash: /dev/ttys003: Permission denied
   fi 

   # NOTE: gpg is the command even though the package is gpg2:
   if ! command -v gpg >/dev/null; then
      fancy_echo "Installing GPG2 for commit signing..."
      brew install gpg2
      # See https://www.gnupg.org/faq/whats-new-in-2.1.html
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         gpg --version  # outputs many lines!
         fancy_echo "GPG2 already installed: UPGRADE requested..."
         # To avoid response "Error: git not installed" to brew upgrade git
         brew uninstall GPG2 
         # NOTE: This does not remove .gitconfig file.
         brew install GPG2 
      else
         fancy_echo "GPG2 already installed:"
      fi
   fi
   echo -e "\n$(gpg --version | grep gpg)" >>$THISSCRIPT.log
   #gpg --version | grep gpg
      # gpg (GnuPG) 2.2.5 and many lines!
   # NOTE: This creates folder ~/.gnupg

   # Mac users can store GPG key passphrase in the Mac OS Keychain using the GPG Suite:
   # https://gpgtools.org/
   # See https://spin.atomicobject.com/2013/11/24/secure-gpg-keys-guide/

   # Like https://gpgtools.tenderapp.com/kb/how-to/first-steps-where-do-i-start-where-do-i-begin-setup-gpgtools-create-a-new-key-your-first-encrypted-mail
   if [ ! -d "/Applications/GPG Keychain.app" ]; then 
      fancy_echo "Installing gpg-suite app to store GPG keys ..."
      brew cask uninstall gpg-suite
      brew cask install --appdir="/Applications" gpg-suite  # See http://macappstore.org/gpgtools/
      # Renamed from gpgtools https://github.com/caskroom/homebrew-cask/issues/39862
      # See https://gpgtools.org/
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "gpg-suite app already installed: UPGRADE requested..."
         brew cask reinstall gpg-suite 
      else
         fancy_echo "gpg-suite app already installed:"
      fi
   fi
   # TODO: How to gpg-suite --version

   # Per https://gist.github.com/danieleggert/b029d44d4a54b328c0bac65d46ba4c65
   # git config --global gpg.program /usr/local/MacGPG2/bin/gpg2


   fancy_echo "Looking in ${#str} byte key chain for GIT_ID=$GIT_ID ..."
   str="$(gpg --list-secret-keys --keyid-format LONG )"
   # RESPONSE FIRST TIME: gpg: /Users/wilsonmar/.gnupg/trustdb.gpg: trustdb created
   echo "$str"
   # Using regex per http://tldp.org/LDP/abs/html/bashver3.html#REGEXMATCHREF
   if [[ "$str" =~ "$GIT_ID" ]]; then 
      fancy_echo "A GPG key for $GIT_ID already generated."
   else  # generate:
      # See https://help.github.com/articles/generating-a-new-gpg-key/
      fancy_echo "Generate a GPG2 pair for $GIT_ID in batch mode ..."
      # Instead of manual: gpg --gen-key  or --full-generate-key
      # See https://superuser.com/questions/1003403/how-to-use-gpg-gen-key-in-a-script
      # And https://gist.github.com/woods/8970150
      # And http://www.gnupg.org/documentation/manuals/gnupg-devel/Unattended-GPG-key-generation.html
      cat >foo <<EOF
      %echo Generating a default key
      Key-Type: default
      Subkey-Type: default
      Name-Real: $GIT_NAME
      Name-Comment: 2 long enough passphrase
      Name-Email: $GIT_ID
      Expire-Date: 0
      Passphrase: $GPG_PASSPHRASE
      # Do a commit here, so that we can later print "done" :-)
      %commit
      %echo done
EOF
    gpg --batch --gen-key foo
    rm foo  # temp intermediate work file.
    # Sample output from above command:
    #gpg: Generating a default key
   #gpg: key AC3D4CED03B81E02 marked as ultimately trusted
   #gpg: revocation certificate stored as '/Users/wilsonmar/.gnupg/openpgp-revocs.d/B66D9BD36CC672341E419283AC3D4CED03B81E02.rev'
   #gpg: done

   fancy_echo "List GPG2 pairs just generated ..."
   str="$(gpg --list-secret-keys --keyid-format LONG )"
   # IF BLANK: gpg: checking the trustdb & gpg: no ultimately trusted keys found
   echo "$str"
   # RESPONSE AFTER a key is created:
   # Sample output:
   #sec   rsa2048/7FA75CBDD0C5721D 2018-03-22 [SC]
   #      B66D9BD36CC672341E419283AC3D4CED03B81E02
   #uid                 [ultimate] Wilson Mar (2 long enough passphrase) <WilsonMar+GitHub@gmail.com>
   #ssb   rsa2048/31653F7418AEA6DD 2018-03-22 [E]

   # To delete a key pair:
   #gpg --delete-secret-key 7FA75CBDD0C5721D
       # Delete this key from the keyring? (y/N) y
       # This is a secret key! - really delete? (y/N) y
       # Click <delete key> in the GUI. Twice.
   #gpg --delete-key 7FA75CBDD0C5721D
       # Delete this key from the keyring? (y/N) y

   fi

   fancy_echo "Retrieve from response Key for $GIT_ID ..."
   # Thanks to Wisdom Hambolu (wisyhambolu@gmail.com) for this:
   KEY=$(GPG_MAP_MAIL2KEY "$GIT_ID")  # 16 chars. 

   # PROTIP: Store your GPG key passphrase so you don't have to enter it every time you 
   #       sign a commit by using https://gpgtools.org/

   # If key is not already set in .gitconfig, add it:
   if grep -q "$KEY" "$GITCONFIG" ; then    
      fancy_echo "Signing Key \"$KEY\" already in $GITCONFIG"
   else
      fancy_echo "Adding SigningKey=$KEY in $GITCONFIG..."
      git config --global user.signingkey "$KEY"

      # Auto-type in "adduid":
      # gpg --edit-key "$KEY" <"adduid"
      # NOTE: By using git config command, repeated invocation would not duplicate lines.
   fi 

   # See https://help.github.com/articles/signing-commits-using-gpg/
   # Configure Git client to sign commits by default for a local repository,
   # in ANY/ALL repositories on your computer, run:
      # NOTE: This updates the "[commit]" section within ~/.gitconfig
   git config commit.gpgsign | grep 'true' &> /dev/null
   # if coding suggested by https://github.com/koalaman/shellcheck/wiki/SC2181
   if [ $? == 0 ]; then
      fancy_echo "git config commit.gpgsign already true (on)."
   else # false or blank response:
      fancy_echo "Setting git config commit.gpgsign false (off)..."
      git config --global commit.gpgsign false
      fancy_echo "To activate: git config --global commit.gpgsign true"
   fi
fi


######### TODO: Insert GPG in GitHub:


# https://help.github.com/articles/telling-git-about-your-gpg-key/
# From https://gist.github.com/danieleggert/b029d44d4a54b328c0bac65d46ba4c65
# Add public GPG key to GitHub
# open https://github.com/settings/keys
# keybase pgp export -q $KEY | pbcopy

# https://help.github.com/articles/adding-a-new-gpg-key-to-your-github-account/


######### Use git-secret to manage secrets in a git repository:


if [[ "$GIT_TOOLS" == *"secret"* ]]; then
   if ! command -v git-secret >/dev/null; then
      fancy_echo "Installing git-secret for managing secrets in a Git repo ..."
      brew install git-secret
      # See https://github.com/sobolevn/git-secret
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         git-secret --version  # 0.2.2
         fancy_echo "git-secret already installed: UPGRADE requested..."
         brew upgrade git-secret 
      else
         fancy_echo "git-secret already installed:"
      fi
   fi
   echo -e "\n$(git-secret --version | grep gpg)" >>$THISSCRIPT.log
fi
   # QUESTION: Supply passphrase or create keys without passphrase


######### Cloud CLI/SDK:


# See https://cloud.google.com/sdk/docs/
echo "CLOUD=$CLOUD"

if [[ $CLOUD == *"vagrant"* ]]; then  # /usr/local/bin/vagrant
   if ! command -v vagrant >/dev/null; then
      fancy_echo "Installing vagrant ..."
      brew cask install --appdir="/Applications" vagrant
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "vagrant already installed: UPGRADE requested..."
         vagrant --version
            # Vagrant 2.0.0
         brew cask upgrade vagrant
      else
         fancy_echo "vagrant already installed."
      fi
   fi
   echo -e "\n$(vagrant --version)" >>$THISSCRIPT.log


   if [ ! -d "/Applications/VirtualBox.app" ]; then 
   #if ! command -v virtualbox >/dev/null; then  # /usr/local/bin/virtualbox
      fancy_echo "Installing virtualbox ..."
      brew cask install --appdir="/Applications" virtualbox
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "virtualbox already installed: UPGRADE requested..."
         # virtualbox --version
         brew cask upgrade virtualbox
      else
         fancy_echo "virtualbox already installed."
      fi
   fi
   #echo -e "\n$(virtualbox --version)" >>$THISSCRIPT.log


   if [ ! -d "/Applications/Vagrant Manager.app" ]; then 
      fancy_echo "Installing vagrant-manager ..."
      brew cask install --appdir="/Applications" vagrant-manager
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "vagrant-manager already installed: UPGRADE requested..."
         brew cask upgrade vagrant-manager
      else
         fancy_echo "vagrant-manager already installed."
      fi
   fi
   
   # Create a test directory and cd into the test directory.
   #vagrant init precise64  # http://files.vagrantup.com/precise64.box
   #vagrant up
   #vagrant ssh  # into machine
   #vagrant suspend
   #vagrant halt
   #vagrant destroy 
fi


if [[ $CLOUD == *"docker"* ]]; then  # contains gcp.
   # First remove boot2docker and Kitematic https://github.com/boot2docker/boot2docker/issues/437
   if ! command -v docker >/dev/null; then  # /usr/local/bin/docker
      fancy_echo "Installing docker ..."
      brew install docker  docker-compose  docker-machine  xhyve  docker-machine-driver-xhyve
      # This creates folder ~/.docker
      # Docker images are stored in $HOME/Library/Containers/com.docker.docker
      brew link --overwrite docker
      # /usr/local/bin/docker -> /Applications/Docker.app/Contents/Resources/bin/docker
      brew link --overwrite docker-machine
      brew link --overwrite docker-compose
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "docker already installed: UPGRADE requested..."
         docker version
         brew upgrade docker-machine-driver-xhyve
         brew upgrade xhyve
         brew upgrade docker-compose  
         brew upgrade docker-machine 
         brew upgrade docker 
      else
         fancy_echo "docker already installed."
      fi
   fi
   echo -e "\n$(docker --version)" >>$THISSCRIPT.log
      # Docker version 18.03.0-ce, build 0520e24
   echo -e "\n$(docker version)" >>$THISSCRIPT.log
      # Client:
       # Version:	18.03.0-ce
       # API version:	1.37
       # Go version:	go1.9.4
       # Git commit:	0520e24
       # Built:	Wed Mar 21 23:06:22 2018
       # OS/Arch:	darwin/amd64
       # Experimental:	false
       # Orchestrator:	swarm

   # docker-machine --help
   # Create a machine:
   # docker-machine create default --driver xhyve --xhyve-experimental-nfs-share
   # docker-machine create -d virtualbox dev1
   # eval $(docker-machine env default)
   # docker-machine upgrade dev1
   # docker-machine rm dev2fi

# See https://wilsonmar.github.io/gcp
if [[ $CLOUD == *"gcp"* ]]; then  # contains gcp.
   if [ ! -f "$(command -v gcloud) " ]; then  # /usr/local/bin/gcloud not installed
      fancy_echo "Installing CLOUD=$CLOUD = brew cask install --appdir="/Applications" google-cloud-sdk ..."
      PYTHON_INSTALL  # function defined at top of this file.
      brew tap caskroom/cask
      brew cask install --appdir="/Applications" google-cloud-sdk  # to ./google-cloud-sdk
      gcloud --version
         # Google Cloud SDK 194.0.0
         # bq 2.0.30
         # core 2018.03.16
         # gsutil 4.29
   else
      fancy_echo "CLOUD=$CLOUD = google-cloud-sdk already installed."
   fi
   # NOTE: gcloud command on its own results in an error.

   # Define alias:
      if grep -q "alias gcs=" "$BASHFILE" ; then    
         fancy_echo "alias gcs= already in $BASHFILE"
      else
         fancy_echo "Adding alias gcs in $BASHFILE ..."
         echo "alias gcs='cd ~/.google-cloud-sdk;ls'" >>"$BASHFILE"
      fi

   fancy_echo "Run \"gcloud init\" "
   # See https://cloud.google.com/appengine/docs/standard/python/tools/using-local-server
   # about creating the app.yaml configuration file and running dev_appserver.py  --port=8085
   fancy_echo "Run \"gcloud auth login\" for web page to authenticate login."
      # successful auth leads to https://cloud.google.com/sdk/auth_success
   fancy_echo "Run \"gcloud config set account your-account\""
      # Response is "Updated property [core/account]."
fi


if [[ $CLOUD == *"aws"* ]]; then  # contains aws.
   fancy_echo "awscli requires Python3."
   # See https://docs.aws.amazon.com/cli/latest/userguide/cli-install-macos.html#awscli-install-osx-pip
   PYTHON3_INSTALL  # function defined at top of this file.
   # :  # break out immediately. Not execute the rest of the if strucutre.

   if ! command -v aws >/dev/null; then
      fancy_echo "Installing awscli using PIP ..."
      pip3 install awscli --upgrade --user
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "awscli already installed: UPGRADE requested..."
         aws --version
            # aws-cli/1.11.160 Python/2.7.10 Darwin/17.4.0 botocore/1.7.18
         pip3 upgrade awscli --upgrade --user
      else
         fancy_echo "awscli already installed."
      fi
   fi
   echo -e "\n$(aws --version)" >>$THISSCRIPT.log
   # aws --version
            # aws-cli/1.11.160 Python/2.7.10 Darwin/17.4.0 botocore/1.7.18

   # TODO: https://github.com/bonusbits/devops_bash_config_examples/blob/master/shared/.bash_aws
   # https://github.com/bonusbits/devops_bash_config_examples/blob/master/shared/.bash_cfnl
fi


if [[ $CLOUD == *"terraform"* ]]; then  # contains aws.
   if ! command -v terraform >/dev/null; then
      fancy_echo "Installing terraform ..."
      brew install terraform 
      # see https://www.terraform.io/
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "terraform already installed: UPGRADE requested..."
         terraform --version
            # terraform-cli/1.11.160 Python/2.7.10 Darwin/17.4.0 botocore/1.7.18
         pip3 upgrade terraform 
      else
         fancy_echo "terraform already installed."
      fi
   fi
   echo -e "\n$(terraform --version)" >>$THISSCRIPT.log
   # terraform --version
            # Terraform v0.11.5

      if grep -q "=\"terraform" "$BASHFILE" ; then    
         fancy_echo "Terraform already in $BASHFILE"
      else
         fancy_echo "Adding Terraform aliases in $BASHFILE ..."
         echo "alias tf=\"terraform \$1\"" >>"$BASHFILE"
         echo "alias tfa=\"terraform apply\"" >>"$BASHFILE"
         echo "alias tfd=\"terraform destroy\"" >>"$BASHFILE"
         echo "alias tfs=\"terraform show\"" >>"$BASHFILE"
      fi
fi


if [[ $CLOUD == *"azure"* ]]; then  # contains azure.
   # See https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos?view=azure-cli-latest
   # Issues at https://github.com/Azure/azure-cli/issues

   # NOTE: The az CLI does not use a Python virtual environment. So ...
   PYTHON3_INSTALL  # function defined at top of this file.
   # Python location '/usr/local/opt/python/bin/python3.6'

   if ! command -v az >/dev/null; then  # not installed.
      fancy_echo "Installing azure using Homebrew ..."
      brew install azure-cli
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "azure-cli already installed: UPGRADE requested..."
         az --version | grep azure-cli
            # azure-cli (2.0.18)
            # ... and many other lines.
         brew upgrade azure-cli
      else
         fancy_echo "azure-cli already installed."
      fi
   fi
   echo -e "\n$(az --version | grep azure-cli)" >>$THISSCRIPT.log
   # az --version | grep azure-cli
      # azure-cli (2.0.30)
      # ... and many other lines.
fi

# TODO: OpenStack
# https://docs.openstack.org/mitaka/user-guide/common/cli_install_openstack_command_line_clients.html

# TODO: IBM's Cloud CLI from brew? brew search did not find it.
# is installed on MacOS by package IBM_Cloud_CLI_0.6.6.pkg from
# page https://console.bluemix.net/docs/cli/reference/bluemix_cli/get_started.html#getting-started
# or curl -fsSL https://clis.ng.bluemix.net/install/osx | sh
# Once installed, the command is "bx login".
# IBM's BlueMix cloud for AI has a pre-prequisite in NodeJs.
# npm install watson-visual-recognition-utils -g
# npm install watson-speech-to-text-utils -g
# See https://www.ibm.com/blogs/bluemix/2017/02/command-line-tools-watson-services/


if [[ $CLOUD == *"cf"* ]]; then  # contains aws.
   # See https://docs.cloudfoundry.org/cf-cli/install-go-cli.html
   if ! command -v cf >/dev/null; then
      fancy_echo "Installing cf (Cloud Foundry CLI) ..."
      brew install cloudfoundry/tap/cf-cli
      # see https://github.com/cloudfoundry/cli

      # To uninstall on Mac OS, delete the binary /usr/local/bin/cf, and the directory /usr/local/share/doc/cf-cli.
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         fancy_echo "cf already installed: UPGRADE requested..."
         cf --version
            # cf version 6.35.2+88a03e995.2018-03-15
         brew upgrade cloudfoundry/tap/cf-cli
      else
         fancy_echo "cf already installed."
      fi
   fi
   echo -e "\n$(cf --version)" >>$THISSCRIPT.log
   cf --version
      # cf version 6.35.2+88a03e995.2018-03-15
fi


# Docker:
# https://github.com/bonusbits/devops_bash_config_examples/blob/master/shared/.bash_docker


######### SSH-KeyGen:


#RANDOM=$((1 + RANDOM % 1000))  # 5 digit random number.
#FILE="$USER@$(uname -n)-$RANDOM"  # computer node name.
FILE="$USER@$(uname -n)"  # computer node name.
fancy_echo "Diving into folder ~/.ssh ..."

if [ ! -d ".ssh" ]; then # found:
   fancy_echo "Making ~/.ssh folder ..."
   mkdir ~/.ssh
fi

pushd ~/.ssh  # specification of folder didn't work.

FILEPATH="$HOME/.ssh/$FILE"
if [ -f "$FILE" ]; then # found:
   fancy_echo "File \"${FILEPATH}\" already exists."
else
   fancy_echo "ssh-keygen creating \"${FILEPATH}\" instead of id_rsa ..."
   ssh-keygen -f "${FILE}" -t rsa -N ''
      # -Comment, -No passphrase or -P
fi


######### ~/.ssh/config file of users:


SSHCONFIG=~/.ssh/config
if [ ! -f "$SSHCONFIG" ]; then 
   fancy_echo "$SSHCONFIG file not found. Creating..."
   touch $SSHCONFIG
else
   OCCURENCES=$(echo ${SSHCONFIG} | grep -o '\<HostName\>')
   fancy_echo "$SSHCONFIG file already created with $OCCURENCES entries."
   # Do not delete $SSHCONFIG file!
fi
echo -e "\n   $SSHCONFIG ::" >>$THISSCRIPT.log
echo -e "$(cat $SSHCONFIG)" >>$THISSCRIPT.log



# See https://www.saltycrane.com/blog/2008/11/creating-remote-server-nicknames-sshconfig/
if grep -q "$FILEPATH" "$SSHCONFIG" ; then    
   fancy_echo "SSH \"$FILEPATH\" to \"$GITHUB_ACCOUNT\" already in $SSHCONFIG"
else
   # Do not delete $SSHCONFIG

   # Check if GITHUB_ACCOUNT has content:
   if [ ! -f "$GITHUB_ACCOUNT" ]; then 
   fancy_echo "Adding SSH $FILEPATH to \"$GITHUB_ACCOUNT\" in $SSHCONFIG..."
   echo "# For: git clone git@github.com:${GITHUB_ACCOUNT}/some-repo.git from $GIT_ID" >> $SSHCONFIG
   echo "Host github.com" >> $SSHCONFIG
   echo "    Hostname github.com" >> $SSHCONFIG
   echo "    User git" >> $SSHCONFIG
   echo "    IdentityFile $FILEPATH" >> $SSHCONFIG
   echo "Host gist.github.com" >> $SSHCONFIG
   echo "    Hostname github.com" >> $SSHCONFIG
   echo "    User git" >> $SSHCONFIG
   echo "    IdentityFile $FILEPATH" >> $SSHCONFIG
   fi
fi


######### Download GITHUB_REPO_URL


# TODO: Setup GITS_PATH

GITHUB_REPO_URL="https://github.com/$GITHUB_ACCOUNT/$GITHUB_REPO.git"
fancy_echo "GITHUB_REPO_URL=$GITHUB_REPO_URL"



######### Paste SSH Keys in GitHub:


# NOTE: pbcopy is a Mac-only command:
if [ "$(uname)" == "Darwin" ]; then
   pbcopy < "$FILE.pub"  # in future pbcopy of password and file transfer of public key.
#elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
fi

   fancy_echo "Now you copy contents of \"${FILEPATH}.pub\", "
   echo "and paste into GitHub, Settings, New SSH Key ..."
#   open https://github.com/settings/keys
   ## TODO: Add a token using GitHub API from credentials in secrets.sh 

   fancy_echo "Pop up from folder ~/.ssh ..."
   popd


######### Selenium browser drivers:


# To click and type on browser as if a human would do.
# See http://seleniumhq.org/
if [[ $GUI_TEST == *"selenium"* ]]; then  # contains azure.

   # per ttps://developer.mozilla.org/en-US/docs/Learn/Tools_and_testing/Cross_browser_testing/Your_own_automation_environment

   # Download the latest webdrivers into folder /usr/bin: https://www.seleniumhq.org/about/platforms.jsp
   # Edge:     https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/
   # Safari:   https://webkit.org/blog/6900/webdriver-support-in-safari-10/
      # See https://itisatechiesworld.wordpress.com/2015/04/15/steps-to-get-selenium-webdriver-running-on-safari-browser/
      # says it's unstable since Yosemite
   # Brave: https://github.com/brave/muon/blob/master/docs/tutorial/using-selenium-and-webdriver.md
      # Much more complicated!
   # PhantomJs headless

   if [[ $GIT_BROWSER == *"chrome"* ]]; then  # contains azure.
      # Chrome:   https://sites.google.com/a/chromium.org/chromedriver/downloads
      if ! command -v chromedriver >/dev/null; then  # not installed.
         brew install chromedriver  # to /usr/local/bin/chromedriver
      fi

      PS_OUTPUT=$(ps | grep chromedriver)
      if grep -q "chromedriver" "$PS_OUTFILE" ; then # chromedriver 2.36 is already installed
         fancy_echo "chromedriver already running."
      else
         fancy_echo "Deleting chromedriver.log from previous session ..."
         rm chromedriver.log

         fancy_echo "Starting chromedriver in background ..."
         chromedriver & # invoke:
            # Starting ChromeDriver 2.36.540469 (1881fd7f8641508feb5166b7cae561d87723cfa8) on port 9515
            # Only local connections are allowed.
            # [1522424121.500][SEVERE]: bind() returned an error, errno=48: Address already in use (48)
         ps | grep chromedriver
            # 1522423621378   chromedriver   INFO  chromedriver 0.20.0
            # 1522423621446   chromedriver   INFO  Listening on 127.0.0.1:4444
      fi 
   fi


   if [[ $GIT_BROWSER == *"firefox"* ]]; then  # contains azure.
      # Firefox:  https://github.com/mozilla/geckodriver/releases
      if ! command -v geckodriver >/dev/null; then  # not installed.
         brew install geckodriver  # to /usr/local/bin/geckodriver
      fi

      if grep -q "/usr/local/bin/chromedriver" "$BASHFILE" ; then    
         fancy_echo "PATH to chromedriver already in $BASHFILE"
      else
         fancy_echo "Adding PATH to /usr/local/bin/chromedriver in $BASHFILE..."
         echo "" >>"$BASHFILE"
         echo "export PATH=\"\$PATH:/usr/local/bin/chromedriver\"" >>"$BASHFILE"
         source "$BASHFILE"
      fi 

      PS_OUTPUT=$(ps | grep geckodriver)
      if grep -q "geckodriver" "$PS_OUTFILE" ; then    
         fancy_echo "geckodriver already running."
      else
         fancy_echo "Starting geckodriver in background ..."
         geckodriver & # invoke:
            # 1522423621378   geckodriver INFO  geckodriver 0.20.0
            # 1522423621446   geckodriver INFO  Listening on 127.0.0.1:4444
         ps | grep geckodriver
      fi 
   fi

   # TODO: install opencv for Selenium to recognize images
   # TODO: install tesseract for Selenium to recognize text within images


######### GitHub hub to manage GitHub functions:

if [[ "$GIT_TOOLS" == *"hub"* ]]; then
   GO_INSTALL  # prerequiste
   if ! command -v hub >/dev/null; then  # in /usr/local/bin/hub
      fancy_echo "Installing hub for managing GitHub from a Git client ..."
      brew install hub
      # See https://hub.github.com/

      # fancy_echo "Adding git hub in $BASHFILE..."
      # echo "alias git=hub" >>"$BASHFILE"
   else
      if [[ "${MY_RUNTYPE,,}" == *"upgrade"* ]]; then
         hub version | grep hub  
           # git version 2.16.3
           # hub version 2.2.9
         fancy_echo "hub already installed: UPGRADE requested..."
         brew upgrade hub 
      else
         fancy_echo "hub already installed:"
      fi
   fi
   echo -e "\n   hub git version:" >>$THISSCRIPT.log
   echo -e "$(hub version)" >>$THISSCRIPT.log
fi


######### Python test coding languge:


   if [[ $GIT_LANG == *"python"* ]]; then  # contains azure.
      # Python:
      # See https://saucelabs.com/resources/articles/getting-started-with-webdriver-in-python-on-osx
      # Get bindings: http://selenium-python.readthedocs.io/installation.html

      # TODO: Check aleady installed:
         pip install selenium   # password is requested. 
            # selenium in /usr/local/lib/python2.7/site-packages

      # TODO: If webdrive is installed:
         pip install webdriver

      if [[ $GIT_BROWSER == *"chrome"* ]]; then  # contains azure.
         python python-tests/chrome_pycon_search.py chrome
         # python python-tests/chrome-google-search-quit.py
      fi
      if [[ $GIT_BROWSER == *"firefox"* ]]; then  # contains azure.
         python python-tests/firefox_github_ssh_add.py
         # python python-tests/firefox_unittest.py  # not working due to indents
         # python python-tests/firefox-test-chromedriver.py
      fi
      if [[ $GIT_BROWSER == *"safari"* ]]; then  # contains azure.
         fancy_echo "Need python python-tests/safari_github_ssh_add.py"
      fi

      # TODO: https://github.com/alexkaratarakis/gitattributes/blob/master/Python.gitattributes
   fi   

   # phantomjs --wd  # headless webdriver
fi # selenium

# Now to add/commit - https://marklodato.github.io/visual-git-guide/index-en.html
# TODO: Protractor for AngularJS
# For coding See http://www.techbeamers.com/selenium-webdriver-python-tutorial/

# TODO: Java Selenium script


######### Dump contents:


#Listing of all brew cask installed (including dependencies automatically added):"
echo -e "\n   brew info --all ::" >>$THISSCRIPT.log
echo -e "$(brew info --all)" >>$THISSCRIPT.log
#Listing of all brews installed (including dependencies automatically added):""
# brew list
echo -e "\n   ls ~/Library/Caches/Homebrew ::" >>$THISSCRIPT.log
echo -e "$(ls ~/Library/Caches/Homebrew)" >>$THISSCRIPT.log

# List contents of ~/.gitconfig
echo -e "\n   $GITCONFIG ::" >>$THISSCRIPT.log
echo -e "$(cat $GITCONFIG)" >>$THISSCRIPT.log
# List using git config --list:
echo -e "\n   git config --list ::" >>$THISSCRIPT.log
echo -e "$(git config --list)" >>$THISSCRIPT.log

# List ~/.bash_profile:
echo -e "\n   $BASHFILE ::" >>$THISSCRIPT.log
echo -e "$(cat $BASHFILE)" >>$THISSCRIPT.log


#########  brew cleanup


#brew cleanup --force
#rm -f -r /Library/Caches/Homebrew/*


######### Disk space consumed:


FREE_DISKBLOCKS_END=$(df | sed -n -e '2{p;q}' | cut -d' ' -f 6) 
DIFF=$(((FREE_DISKBLOCKS_START-FREE_DISKBLOCKS_END)/2048))
echo -e "\n   $DIFF MB of disk space consumed during this script run." >>$THISSCRIPT.log
# 380691344 / 182G = 2091710.681318681318681 blocks per GB
# 182*1024=186368 MB
# 380691344 / 186368 G = 2042 blocks per MB

exit
TIME_END=$(date -u +%s);
DIFF=$((TIME_END-TIME_START))
MSG = "End of script after $((DIFF/60))m $((DIFF%60))s seconds elapsed."
fancy_echo "$MSG"
echo -e "\n$MSG" >>$THISSCRIPT.log


######### Open editor to show log:


fancy_echo "Opening editor in background to display log ..."
case "$GIT_EDITOR" in
        atom)
            echo atom
            atom $THISSCRIPT.log &
            ;;
        code)
            echo code
            code $THISSCRIPT.log &
            ;;
        eclipse)
            echo eclipse
            eclipse $THISSCRIPT.log &
            ;;
        emacs)
            echo emacs
            emacs $THISSCRIPT.log &
            ;;
        macvim)
            echo macvim
            macvim $THISSCRIPT.log &
            ;;
        nano)
            echo nano
            nano $THISSCRIPT.log &
            ;;
        pico)
            echo pico
            pico $THISSCRIPT.log &
            ;;
        sublime)
            echo sublime
            subl $THISSCRIPT.log &
            ;;
        textedit)
            echo textedit
            textedit $THISSCRIPT.log &
            ;;
        textmate)
            echo textmate
            textmate $THISSCRIPT.log &
            ;;
        vim)
            echo vim
            vim $THISSCRIPT.log &
            ;;
        *)
            echo "$GIT_EDITOR not recognized."
            exit 1
esac


exit