#!/bin/bash

scriptRoot=$(cd "${BASH_SOURCE%/*}" && pwd)
source "${scriptRoot}/bin/create-settings.sh"
echo $SITE_NAME