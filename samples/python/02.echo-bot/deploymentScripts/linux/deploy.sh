#!/bin/bash

# ----------------------
# KUDU Deployment Script
# Version: 1.0.17
# ----------------------

# Helpers
# -------

exitWithMessageOnError () {
  if [ ! $? -eq 0 ]; then
    echo "An error has occurred during web site deployment."
    echo $1
    exit 1
  fi
}

# Prerequisites
# -------------

# Verify node.js installed
hash node 2>/dev/null
exitWithMessageOnError "Missing node.js executable, please install node.js, if already installed make sure it can be reached from current environment."

# Setup
# -----

SCRIPT_DIR="${BASH_SOURCE[0]%\\*}"
SCRIPT_DIR="${SCRIPT_DIR%/*}"
ARTIFACTS=$SCRIPT_DIR/../artifacts
KUDU_SYNC_CMD=${KUDU_SYNC_CMD//\"}

if [[ ! -n "$DEPLOYMENT_SOURCE" ]]; then
  DEPLOYMENT_SOURCE=$SCRIPT_DIR
fi

if [[ ! -n "$NEXT_MANIFEST_PATH" ]]; then
  NEXT_MANIFEST_PATH=$ARTIFACTS/manifest

  if [[ ! -n "$PREVIOUS_MANIFEST_PATH" ]]; then
    PREVIOUS_MANIFEST_PATH=$NEXT_MANIFEST_PATH
  fi
fi

if [[ ! -n "$DEPLOYMENT_TARGET" ]]; then
  DEPLOYMENT_TARGET=$ARTIFACTS/wwwroot
else
  KUDU_SERVICE=true
fi

if [[ ! -n "$KUDU_SYNC_CMD" ]]; then
  # Install kudu sync
  echo Installing Kudu Sync
  npm install kudusync -g --silent
  exitWithMessageOnError "npm failed"

  if [[ ! -n "$KUDU_SERVICE" ]]; then
    # In case we are running locally this is the correct location of kuduSync
    KUDU_SYNC_CMD=kuduSync
  else
    # In case we are running on kudu service this is the correct location of kuduSync
    KUDU_SYNC_CMD=$APPDATA/npm/node_modules/kuduSync/bin/kuduSync
  fi
fi

# Utility Functions
# -----------------

upgradePython () {
  echo "apt-get update"
  apt-get update

  echo "apt-get install python3.5"
  apt-get install python3.5

  PYTHON_RUNTIME=python-3.5
  PYTHON_VER=3.5
  PYTHON_EXE=%SYSTEMDRIVE%\python3.5\python.exe
  PYTHON_ENV_MODULE=virtualenv
}

##################################################################################################################################
# Deployment
# ----------

echo ===== Starting python custom deploy.sh =====

# 1. KuduSync
if [[ "$IN_PLACE_DEPLOYMENT" -ne "1" ]]; then
  "$KUDU_SYNC_CMD" -v 50 -f "$DEPLOYMENT_SOURCE" -t "$DEPLOYMENT_TARGET" -n "$NEXT_MANIFEST_PATH" -p "$PREVIOUS_MANIFEST_PATH" -i ".git;.hg;.deployment;deploy.sh;deploymentTemplates"
  exitWithMessageOnError "Kudu Sync failed"
fi

# 2. Upgrade python version
#upgradePython

echo "show python versions"
ls /usr/bin/python*

echo "python --version"
python --version

echo "python3 --version"
python3 --version

echo "python3m --version"
python3m --version

# 4. Install packages 
#echo "python3 -m pip install --upgrade pip"
#python3 -m pip install --upgrade pip
#Requirement already up-to-date: pip in /usr/local/lib/python3.5/dist-packages

#echo "apt-get install python-setuptools"
#apt-get install python-setuptools
#E: Could not open lock file /var/lib/dpkg/lock - open (13: Permission denied) 

echo pip install -U setuptools
pip install -U setuptools
#Successfully installed setuptools-44.1.1

echo python3 -m pip install -U setuptools
python3 -m pip install -U setuptools
#Successfully installed setuptools-49.2.0

#echo "python -m pip config set global.extra-index-url https://pkgs.dev.azure.com/ConversationalAI/BotFramework/_packaging/SDK/pypi/simple/"
#python -m pip config set global.extra-index-url https://pkgs.dev.azure.com/ConversationalAI/BotFramework/_packaging/SDK/pypi/simple/

echo "cd dependencies"
cd dependencies

echo "python3 -m pip install cryptography==2.8.0"
python3 -m pip install cryptography==2.8.0
#Successfully installed cffi-1.14.0 cryptography-2.8 pycparser-2.20 six-1.15.0

echo "python3 -m pip install yarl==1.4.2 -f ./"
python3 -m pip install yarl==1.4.2 -f ./
#Successfully installed idna-2.10 multidict-4.7.6 yarl-1.4.2

#echo "python3 -m pip install multidict -f ./"
#python3 -m pip install multidict -f ./
#Requirement already satisfied: multidict in /home/.local/lib/python3.5/site-packages (4.7.6)

echo "python3 -m pip install aiohttp -f ./"
python3 -m pip install aiohttp -f ./
#Successfully installed aiohttp-3.6.2 async-timeout-3.0.1 attrs-19.3.0 chardet-3.0.4 idna-ssl-1.1.0 typing-extensions-3.7.4.2

#echo "python3 -m pip install idna-ssl -f ./"
#python3 -m pip install idna-ssl -f ./
#Requirement already satisfied: idna>=2.0 in /home/.local/lib/python3.5/site-packages (from idna-ssl) (2.10) 

#echo "python3 -m pip install --requirement ../azure-unresolved-requirements.txt -f ./ --no-index"
#python3 -m pip install --requirement ../azure-unresolved-requirements.txt -f ./ --no-index

echo "python3 -m pip install --requirement ../requirements.txt -f ./ --no-index"
python3 -m pip install --requirement ../requirements.txt -f ./ --no-index
#Successfully installed PyJWT-1.5.3 adal-1.2.1 botbuilder-core-4.10.0.20200724.dev149696 botbuilder-integration-aiohttp-4.10.0.20200724.dev149696 botbuilder-schema-4.10.0.20200724.dev149696 botframework-connector-4.10.0.20200724.dev149696 certifi-2020.6.20 isodate-0.6.0 jsonpickle-1.2 msal-1.2.0 msrest-0.6.10 oauthlib-3.1.0 python-dateutil-2.8.1 requests-2.23.0 requests-oauthlib-1.3.0 urllib3-1.25.10        

# python -m pip install -r requirements.txt --extra-index-url https://pkgs.dev.azure.com/ConversationalAI/BotFramework/_packaging/SDK/pypi/simple/

echo "This in reponse to WARNING: The script pyjwt is installed in '/home/.local/bin' which is not on PATH."
echo "export PATH=/home/.local/bin:$PATH"
export PATH=/home/.local/bin:$PATH

exitWithMessageOnError "pip install failed"
cd - > /dev/null

##################################################################################################################################
echo "Finished successfully."
