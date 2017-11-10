#!/bin/bash


BIN="${HOME}/bin"
SUDO_USER="$(who am i | awk '{print $1}')"
FULL_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
SOURCE="$(cd "$(dirname "$0")" && pwd)"
RED="\033[1;31m" # Red
NC="\033[0m"     # No Color
RPI="${HOME}/.rpi"
PIRC="${SOURCE}/pirc"

abort() { echo -e "${RED}$* ${NC}" >&2 && exit 1; }
[[ $USER == "root" ]] && abort \
  "Can't be run as root, must be run as $SUDO_USER."

if [[ ! -h $PIRC && ! -f $PIRC ]]; then
  ln -s $PIRC ${HOME}/.pirc 
fi

TESTPIRC=$(/bin/grep '^\s\s. ${HOME}/.pirc' ~/.bashrc)
if [[ -f ${HOME}/.bashrc ]] && [[ ! $TESTPIRC =~ '. ${HOME}/.pirc' ]]; then
  echo '##' >> ${HOME}/.bashrc
  echo '# DELUXE-RPI-ENV-SRC' >> ${HOME}/.bashrc
  echo '##' >> ${HOME}/.bashrc
  echo 'if [[ -f ${HOME}/.pirc ]]; then' >> ${HOME}/.bashrc
  echo '  . ${HOME}/.pirc' >> ${HOME}/.bashrc
  echo 'fi' >> ${HOME}/.bashrc
fi

# setup ~/bin
if [[ ! -d $BIN ]];
then
  mkdir $BIN
fi
cd ${SOURCE}/bin

# link binaries
for i in $(ls); do
  if [[ ! -L ${HOME}/bin/${i:0:${#i} -3} ]] && \
     [[ ! -f ${HOME}/bin/${i:0:${#i} -3} ]];
  then
    echo linking $i
    ln -s ${SOURCE}/bin/${i} ${HOME}/bin/${i:0:${#i} -3}
  fi
done
cd $OLDPWD

# set vim.tiny as the git editor
git config --global user.email "flannon@5eight5.com"
git config --global user.name "Flannon Jackson"
git config --global core.editor $(which vim.tiny)
