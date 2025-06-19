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
