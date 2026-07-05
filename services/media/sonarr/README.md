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
    - ~~On Grab~~
    - On File Import
    - On File Upgrade
    - On Import Complete
    - On Rename
    - ~~On Series Add~~
    - ~~On Series Delete~~
    - On Episode File Delete
    - On Episode File Delete For Upgrade
    - ~~On Health Issue~~
    - ~~On Health Restored~~
    - ~~On Application Upgrade~~
    - ~~On Manual Interaction Required~~
  - **Host** `jellyfin.media.svc.cluster.local`
  - **Port** `80`
  - **API Key** create `New API Key` named `sonarr` at [https://jellyfin.int.fivebytestudios.com/web/#/dashboard/keys](Jellyfin API Keys)
  - **Send Notifications** off
  - **Update Library** on
  - **Map Paths From** `/data/media/tv`
  - **Map Paths To** `/media/tv`
