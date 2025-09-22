# Mosquitto

## Testing

Subscribe to all messages:

```sh
mosquitto_sub --id test-$(hostname) --host mqtt.home-assistant.int.fivebytestudios.com --topic '#' --verbose
```
