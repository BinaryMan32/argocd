# OctoPrint

Currently using octopi, might switch to octoprint container in the future.

## Installation

https://octoprint.org/download/ recommended installing from raspberry pi imager

Initial credentials are `pi`/`raspberry`.

Change hostname using `sudo raspi-config`:
System options
Hostname
vulcan
(exit and reboot)

Use `passwd` to change password.

Add to ~/.ssh/config:
```
Host vulcan
  Hostname vulcan.iot.wildfreddy.fivebytestudios.com
  User pi
```

Add keys:
```
ssh-copy-id vulcan 
```

## Install certificate

Generate a certificate in `vulcan.pem`:
```
kubectl apply -f vulcan-certificate.yaml
kubectl get secret vulcan-certificate \
  --template='{{index .data "tls.key" | base64decode}}{{index .data "tls.crt" | base64decode}}' \
  > vulcan.pem
kubectl delete -f vulcan-certificate.yaml
kubectl delete secret vulcan-certificate
```

Copy certificate to `/etc/ssl/` on octopi:
```
scp vulcan.pem vulcan:~
rm vulcan.pem
```

On `vulcan`, copy key to correct location:
```
ssh vulcan
sudo cp ~/vulcan.pem /etc/ssl/
rm vulcan.pem
```

Edit `/etc/haproxy/haproxy.cfg` to use new certificate and reload:
```
sudo sed -i -e s/snakeoil.pem/vulcan.pem/ /etc/haproxy/haproxy.cfg
sudo systemctl reload haproxy
```

Access at https://vulcan.iot.wildfreddy.fivebytestudios.com/
