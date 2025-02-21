# Home Assistant

Deploys home-assistant using [k8s-at-home helm chart][k8s-at-home].

Once it's deployed, forward a local port to the service:

```sh
kubectl -n home-assistant port-forward svc/home-assistant 8123:8123
```

And visit <http://localhost:8123/>

Or use the ingress via <https://home-assistant.wildfreddy.fivebytestudios.com/>

## Secrets

From the `home-assistant-secrets` subdir run:

```sh
helm install -n home-assistant --create-namespace home-assistant-secrets .
```

## Configuring Devices

To set client credentials on all tasmota devices, run:

```sh
./configure-tasmota.py --credentials
```

## Testing MQTT (Mosquitto)

Subscribe to all messages:

```sh
mosquitto_sub --id test-$(hostname) --host mqtt.home-assistant.int.fivebytestudios.com --topic '#' --verbose
```

## Setup

### MQTT

Add the `MQTT` integration with parameters:

- host: `mqtt`
- port: `1883`
- user: from `mqtt` secret, key `home-assistant-username`
- password: from `mqtt` secret, key `home-assistant-password`

### Tasmota

The `Tasmota` integration should be automatically detected.
Add it and then set the `Area` for each device as noted below.

| Device             | Area (icon)       |
| ------------------ | ----------------- |
| Tasmota_Bench      | Lab (`mdi:tools`) |
| Tasmota_Desktop    | Bedroom           |
| Tasmota_FlashForge | Lab (`mdi:tools`) |
| Tasmota_Music      | Living Room       |
| Tasmota_TV         | Living Room       |

### Shelly

Add `Shelly` integration:

- host: `192.168.3.160`
- port: leave at default `80`

Device `shelly3em` should be auto recognized.

### TP-Link Kasa

Add TP-Link Kasa `HS300` power strips with the integration `TP-Link Smart Home`.
Use area Rack (`mdi:server`).

- `192.168.3.100`

## Reverse Proxy Error

Log messages:

```text
2021-10-09 16:02:20 WARNING (MainThread) [homeassistant.components.http.forwarded] A request from a reverse proxy was received from 10.42.1.6, but your HTTP integration is not set-up for reverse proxies; This request will be blocked in Home Assistant 2021.7 unless you configure your HTTP integration to allow this header
2021-10-09 16:02:20 WARNING (MainThread) [homeassistant.components.webhook] Received message for unregistered webhook eb011e1261e28caab006ef765835a8b7358c0cf8c5f9291aa0dfff2f5a291f68 from 10.42.1.6
```

As [documented in the home-assistant chart][home-assistant-bad-request], need to
configure which ips are allowed to send requests in the home assistant config.

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
  - 10.42.0.0/16
```

See also [home-assistant-reverse-proxies][].

Choose a CIDR which covers the `podCIDR` for all nodes:

```sh
kubectl get nodes -o=jsonpath='{range .items[*]}{.spec.podCIDR}{"\n"}{end}'
```

```text
10.42.0.0/24
10.42.1.0/24
10.42.2.0/24
10.42.3.0/24
```

[k8s-at-home]: https://github.com/k8s-at-home/charts/tree/master/charts/stable/home-assistant
[home-assistant-bad-request]: https://github.com/k8s-at-home/charts/tree/master/charts/stable/home-assistant#http-400-bad-request-while-accessing-from-your-browser
[home-assistant-reverse-proxies]: https://www.home-assistant.io/integrations/http#reverse-proxies
