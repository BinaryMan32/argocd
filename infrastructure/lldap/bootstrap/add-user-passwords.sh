#!/bin/sh
users_in=$1
authelia_password_file=$2
users_out=$3
jq --arg pass "$(cat $authelia_password_file)" 'if .id == "authelia" then .password=$pass end' $users_in > $users_out
echo "Updated user passwords in $users_out"
# TODO remove this
jq . $users_out
