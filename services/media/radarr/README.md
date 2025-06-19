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
