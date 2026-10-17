#!/bin/sh
PASSWORD_FILE=/mosquitto/auth/mosquitto_password
mosquitto_passwd -c -b $PASSWORD_FILE $HOME_ASSISTANT_USERNAME $HOME_ASSISTANT_PASSWORD
mosquitto_passwd -b $PASSWORD_FILE $TASMOTA_USERNAME $TASMOTA_PASSWORD
mosquitto_passwd -b $PASSWORD_FILE $FLASHFORGE_USERNAME $FLASHFORGE_PASSWORD

# mosquitto won't open acl_file through a symlink (ConfigMap keys are symlinks)
install -m 0600 /auth-setup/mosquitto_acl /mosquitto/auth/mosquitto_acl
