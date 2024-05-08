#!/bin/sh

## Executes pre-provision scripts

# App Service Environment
ASE=$(read -p "App Service Environment? (Y/N): ")

# Check if input matches "y", "yes", or "true"
if [[ $ASE =~ ^(y|yes|true)$ ]]; then
    export AZURE_APP_SERVICE_ENVIRONMENT=true
fi

# Zero trust
(cd $$PWD/zerotrust &&
    ./zeroTrustHeadsUp.sh)

exit 0
