#!/bin/bash

# Force users to login before seeing any pins.
if [ "$ALLOW_NEW_REGISTRATIONS" == "" ]; then
    ALLOW_NEW_REGISTRATIONS=true
fi


sudo docker images |grep pinry || echo "No docker image found, building..." || ./build_docker.sh

echo "=================================================================================="
echo "Note: Please copy this key and keep it in a secure place."
echo "Then you should manually edit your pinry/local_settings.py"
echo "and replace SECRET_KEY with new secret-key if you had previously generated a"
echo "pinry/local_settings.py."
echo "If no previous pinry/local_settings.py generated, you can have a look and edit it."
echo "If you want to use docker-compose, just edit docker-compose.yml and use 'docker-compose up'"

SECRET_KEY=$(sudo docker run pinry/pinry /scripts/gen_key.sh)

echo ""
echo "Your secret-key is(also saved/overwritten your pinry/production_secret_key.txt):"
echo ""
echo ${SECRET_KEY}
echo "=================================================================================="

if [ ! -f ./pinry/local_settings.py ];
then
    cp ./pinry/local_settings.example.py ./pinry/local_settings.py
    sed -i "s/secret\_key\_place\_holder/${SECRET_KEY}/" ./pinry/local_settings.py
fi

# Force users to login before seeing any pins.
if [ -n "$PRIVATE" ]; then
    sed -i "s/PUBLIC = True/PUBLIC = False/" ./pinry/local_settings.py
fi

# Enable people from creating new accounts.
if [ -n "$ALLOW_NEW_REGISTRATIONS" ]; then
    sed -i "s/ALLOW_NEW_REGISTRATIONS = False/ALLOW_NEW_REGISTRATIONS = True/" ./pinry/local_settings.py
fi
