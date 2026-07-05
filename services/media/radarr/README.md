# radarr

See [dockerhub](https://hub.docker.com/r/linuxserver/radarr)

## Setup

Under **General**, enable **Show Advanced** and set:

- **Host**
  - **Application URL** `https://radarr.int.fivebytestudios.com`

Under **Media Management**:

- configure **Movie Naming** to match [https://trash-guides.info/Radarr/Radarr-recommended-naming-scheme/#jellyfin](guide)
  - except prefer `CleanTitleThe` instead of `CleanTitle`
- add root folder `/data/media/movies`

Under **Connect**:

- log in as jellyfin admin user and create an api key named `radarr`
- add **Emby / Jellyfin** connection with settings:
  - **Name** `Jellyfin`
  - **Notification Triggers**
    - ~~On Grab~~
    - On File Import
    - On File Upgrade
    - On Rename
    - ~~On Movie Added~~ (can't be enabled on Jellyfin for some reason)
    - ~~On Movie Delete~~
    - On Movie File Delete
    - On Movie File Delete For Upgrade
    - ~~On Health Issue~~
    - ~~On Health Restored~~
    - ~~On Application Upgrade~~
    - ~~On Manual Interaction Required~~
  - **Host** `jellyfin.media.svc.cluster.local`
  - **Port** `80`
  - **API Key** create `New API Key` named `radarr` at [https://jellyfin.int.fivebytestudios.com/web/#/dashboard/keys](Jellyfin API Keys)
  - **Send Notifications** off
  - **Update Library** on
  - **Map Paths From** `/data/media/tv`
  - **Map Paths To** `/media/tv`
