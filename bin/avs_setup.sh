#!/bin/bash

##
# This script expects the following environment variables to be set,
# AVSPRODUCTID
# AVSCLIENTID
# AVSCLIENTSECRET
##

FULL_PATH="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
SOURCE="$(cd "$(dirname "$0")" && pwd)"
CONFDIR="$(cd $SOURCE/.. && pwd)"
AVSUSER="$(whoami)"
AVSHOME="/opt/avs"
AVSREPO="alexa-avs-sample-app"
AVSSAMPLEAPPDIR="$AVSHOME/$AVSREPO"
AVSINSTALLSCRIPT="automated_install.sh"
VALID="$AVSSAMPLEAPPDIR/.valid"

usage() {
cat << EOF
usage:
  $ export AVSPRODUCTID="xxxxx"
  $ export AVSCLIENTID="xxxxxxxxxxxxx"
  $ export AVSCLIENTSECRET="xxxxxxxxxxxxxxxxxxxxx"

  $ $0
EOF
}

# If the environment vars are not set bail and play the usage
[[  -z $AVSPRODUCTID ||  -z $AVSCLIENTID ||  -z $AVSCLIENTSECRET ]] && usage && exit 2

[[ ! -d $AVSHOME ]] && sudo mkdir $AVSHOME && sudo chown $AVSUSER: $AVSHOME
cd $AVSHOME
if [[ ! -d $AVSSAMPLEAPPDIR ]]; then
  git clone https://github.com/alexa/alexa-avs-sample-app.git
fi

AVSINSTALLSCRIPTSUM="$(cd $AVSSAMPLEAPPDIR && md5sum $AVSINSTALLSCRIPT | cut -d ' ' -f 1)"
AVSREFERENCESCRIPTSUM="$(cd $CONFDIR/etc && md5sum $AVSINSTALLSCRIPT |  cut -d ' ' -f 1)"

# Check that the current version of the install scrip is the same 
# as the reference script
if [[ ! -f $VALID ]]; then
  touch $VALID
  [[ $AVSINSTALLSCRIPTSUM != $AVSREFERENCESCRIPTSUM ]] && \
    echo "This version of $AVSINSTALLSCRIPT is not currently supported" && \
    exit 5
fi

# Run the erb template to load ProductID, ClientID and ClientSecret
# into the install script 
[[ -f $AVSSAMPLEAPPDIR/$AVSINSTALLSCRIPT ]] && \
 erb $CONFDIR/templates/automated_install.sh.erb > \
 $AVSSAMPLEAPPDIR/$AVSINSTALLSCRIPT


cd $AVSSAMPLEAPPDIR
source $AVSINSTALLSCRIPT
