#!/bin/bash

echo "RUNNING..."

#####################################
### DOWNLOAD REMOTE CONFIGURATION
CONFIG_LOCAL_FILE="/var/www/private/config.yml"

# Download environment config if environment passed
if [ -z "$CONFIG_URL" ];
then
    echo "Get default config.yml from image"
else
    echo "Config URL detected. Download config file: ${CONFIG_URL}"

    # Download from curl
    response=$(curl -k --write-out %{http_code} --silent --output ${CONFIG_LOCAL_FILE} ${CONFIG_URL})

    if [ $response -eq 200 ];
    then
        echo "downloaded config file OK. Checking file content is valid..."

        # Check valid file contents (in this case, contains string 'host')
        if grep -Fq "token" ${CONFIG_LOCAL_FILE}
        then
            echo "VALID."

            if grep -Fq "$" ${CONFIG_LOCAL_FILE}
            then
	            echo "Prepend the <?php for this file content..."
	            sed -i -e '1i<?php \' ${CONFIG_LOCAL_FILE}
            fi

        else
            echo "INVALID file content (not found text 'token' in config file)."
            echo "Exit."
            exit 1
        fi
    else

        # Stop this container because can not download config file.
        #
        echo "File Not Found. HTTP Status Code: ${response}."
        echo "Exit."
        exit 1
    fi
fi


#############################################$
# Replace environment LOGENTRIES_TOKEN
envtpl /etc/syslog-ng/conf.d/logentries.conf

## run supervisord
supervisord


# Call parent entrypoint (CMD)
/sbin/my_init
