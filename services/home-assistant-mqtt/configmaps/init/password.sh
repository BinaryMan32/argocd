#!/bin/sh
PASSWORD_FILE=/mosquitto/password/mosquitto_password
mosquitto_passwd -c -b $PASSWORD_FILE $HOME_ASSISTANT_USERNAME $HOME_ASSISTANT_PASSWORD
mosquitto_passwd -b $PASSWORD_FILE $TASMOTA_USERNAME $TASMOTA_PASSWORD
mosquitto_passwd -b $PASSWORD_FILE $FLASHFORGE_USERNAME $FLASHFORGE_PASSWORD
chown mosquitto:mosquitto $PASSWORD_FILE
