# bazarr

See [dockerhub](https://hub.docker.com/r/linuxserver/bazarr)

## Setup

Mostly follows [Setup Guide](https://wiki.bazarr.media/Getting-Started/Setup-Guide/) from the [Bazarr Wiki](https://wiki.bazarr.media/), see details below.

### General

- **Proxy**
  - set to **HTTP(S)**
  - Host: `vpn-http-proxy.media.svc.cluster.local`
  - Port: `8080`
  - Ignored Addresses: add `.media.svc.cluster.local`
- **Updates**
  - disable **Automatic**

### Sonarr

- Use Sonarr: `Enabled`
- Host
  - Address: `sonarr.media.svc.cluster.local`
  - Port: `80`
  - API Key: (copy from [Sonarr Settings - General](https://sonarr.int.fivebytestudios.com/settings/general))

### Radarr

- Use Sonarr: `Enabled`
- Host
  - Address: `radarr.media.svc.cluster.local`
  - Port: `80`
  - API Key: (copy from [Radarr Settings - General](https://radarr.int.fivebytestudios.com/settings/general))
- Options
  - Minimum Score For Movies: `80` (from [TraSH Guide](https://trash-guides.info/Bazarr/Bazarr-suggested-scoring/#radarr-subtitle-minimum-score))

### Languages

- Languages Filter: add `English`
- Languages Profile: add
  - name: English
  - languages:
    - Language: English
      - Subtitles Type: Normal or hearing-impaired
      - Search only when: Always
- Default Language Profiles For Newly Added Shows
  - Series: enable
    - Profile: English
  - Movies: enable
    - Profile: English

### Providers

- add OpenSubtitles.com with credentials from BitWarden

### Subtitles

- Subtitle File Options
  - Hearing-impaired subtitles extension: `.sdh`
- Upgrading Subtitles
  - Upgrade Previously Downloaded Subtitles: `on`, set to `30`
  - Upgrade Manually Downloaded or Translated Subtitles: `off`
- Audio Synchronization / Alignment
  - Automatic Subtitles Audio Synchronization: `on` (from [TRaSH Guide](https://trash-guides.info/Bazarr/Bazarr-suggested-scoring/#synchronization-score-threshold))
    - Series Score Threshold For Audio Sync: `96`
    - Movies Score Threshold For Audio Sync: `86`

### Mass Edit

Follow [First Time Installation Configuration](https://wiki.bazarr.media/Getting-Started/First-time-installation-configuration/) to update all existing movies and series to use a language profile.
