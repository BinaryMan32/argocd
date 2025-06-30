# sonarr

See [dockerhub](https://hub.docker.com/r/linuxserver/sonarr)

## Setup

Under **General**, enable **Show Advanced** and set:

- **Host**
  - **Application URL** `https://sonarr.int.fivebytestudios.com`

Under **Media Management**:

- configure **Episode Naming** to match [https://trash-guides.info/Sonarr/Sonarr-recommended-naming-scheme/#optional-jellyfin](guide)
  - except prefer `TitleTheYear` instead of `TitleYear`
- add root folder `/data/media/tv`

Under **Connect**:

- log in as jellyfin admin user and create an api key named `radarr`
- add **Emby / Jellyfin** connection with settings:
  - **Name** `Jellyfin`
  - **Notification Triggers**
    - On Grab
    - On File Import
    - On File Upgrade
    - On Import Complete
    - On Rename
    - On Series Add
    - On Series Delete
    - On Episode File Delete
    - On Episode File Delete For Upgrade
    - On Application Upgrade
  - **Host** `jellyfin.media.svc.cluster.local`
  - **Port** `80`
  - **API Key** (from jellyfin settings)
  - **Update Library** (enabled by default)
