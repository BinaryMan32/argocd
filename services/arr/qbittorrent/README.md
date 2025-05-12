# QBittorrent

See [dockerhub](https://hub.docker.com/r/linuxserver/qbittorrent)

## Set Password

After deploying, you should see something like this in the qbittorrent pod logs:

```text
The WebUI administrator username is: admin
The WebUI administrator password was not set. A temporary password is provided for this session: PASSWORD
You should set your own password in program preferences.
```

To set the password:

1. Log in with the temporary password at <https://qbittorrent.int.fivebytestudios.com/>
2. Go to **Tools** > **Options...**
3. Click the **WebUI** tab
4. Set password using password manager
