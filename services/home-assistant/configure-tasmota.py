#!/usr/bin/env python3
import argparse
import base64
import dataclasses
import json
import subprocess
import urllib
import urllib.parse
import urllib.request

SECRET_NAME = 'mqtt'
SECRET_USER_PREFIX = 'tasmota-'

MOSQUITTO_HOST = 'mqtt.home-assistant.int.fivebytestudios.com'
MOSQUITTO_PORT = '1883'

@dataclasses.dataclass
class Device:
  host: str
  name: str
  
  @property
  def mosquitto_client(self):
    return 'TASMOTA_' + self.name.upper()

  @property
  def mosquitto_topic(self):
    return 'tasmota_' + self.name.lower()


DEVICES = [
  Device(host='192.168.3.97', name='Bench'),
  Device(host='192.168.3.117', name='Desktop'),
  Device(host='192.168.3.38', name='FlashForge'),
  Device(host='192.168.3.11', name='Music'),
  Device(host='192.168.3.8', name='TV'),
]


def get_credentials(secret_name, prefix):
  command = ['kubectl', '--namespace=home-assistant', 'get', 'secret', secret_name, '--output=json']
  data = json.loads(subprocess.run(command, check=True, capture_output=True).stdout)['data']
  return { key: base64.b64decode(data[prefix + key]).decode('ascii') for key in ['username', 'password'] }


# https://tasmota.github.io/docs/Commands/#the-power-of-backlog
def configure_tasmota(device, commands):
  params = urllib.parse.urlencode([
    ('cmnd', 'Backlog ' + ';'.join([' '.join(command) for command in commands]))
  ])
  url = f'http://{device.host}/cm?{params}'
  print(url)
  urllib.request.urlopen(url)


# https://tasmota.github.io/docs/Commands/#mqtt
def credentials_commands(credentials):
  return [
    ('MqttUser', credentials['username']),
    ('MqttPassword', credentials['password']),
  ]


# https://tasmota.github.io/docs/Commands/#mqtt
def server_config_commands():
  return [
    ('MqttHost', MOSQUITTO_HOST),
    ('MqttPort', MOSQUITTO_PORT),
  ]


# https://tasmota.github.io/docs/Commands/#mqtt
def client_config_commands(device):
  return [
    ('MqttClient', device.mosquitto_client),
    ('Topic', device.mosquitto_topic),
  ]


def main():
  parser = argparse.ArgumentParser()
  parser.add_argument('--client', action='store_true', help='update client config')
  parser.add_argument('--server', action='store_true', help='update server config')
  parser.add_argument('--credentials', action='store_true', help='update credentials')
  parser.add_argument('devices', nargs='*')
  parser.add_argument_group()
  args = parser.parse_args()

  common_commands = []

  if args.server:
    common_commands.extend(server_config_commands())

  if args.credentials:
    print(f'Fetching credentials from kubernetes secret')
    common_commands.extend(credentials_commands(get_credentials(SECRET_NAME, SECRET_USER_PREFIX)))

  devices = [d for d in DEVICES if d.name.lower() in args.devices] if args.devices else DEVICES
  for device in devices:
    print(f'Updating {device.name}')
    # Ensure that commands is a copy of the list
    commands = [] + common_commands
    if args.client:
      commands.extend(client_config_commands(device))
    if commands:
      configure_tasmota(device, commands)
  
  return 0


if __name__ == '__main__':
  exit(main())
