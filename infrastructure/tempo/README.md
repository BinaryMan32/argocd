# Tempo

## Create SeaweedFS Bucket

1. Open [SeaweedFS Admin - Buckets](https://seaweedfs-admin.int.fivebytestudios.com/object-store/buckets)
2. If it doesn't already exist, create a bucket `tempo-traces`
    - Owner: **No owner**
    - check **Enable Object Versioning**
    - click **Create Bucket**
3. Under users, create a new user
    - Username: `tempo`
    - Permissions:
        - Read
        - Write
        - List
        - Tagging
    - Bucket Scope
        - Specific Buckets
            - select `tempo-traces`
    - uncheck **Generate access key automatically**
    - click **Create User**
4. Click the key icon on the new user to edit access keys
    - click **Create New Key**
    - Run `infrastructure/tempo/create-seaweedfs-secret.sh`
    - Paste credentials as requested
