# SeaweedFS

See [SeaweedFS Wiki](https://github.com/seaweedfs/seaweedfs/wiki).

## Testing with s3cmd

Install [s3cmd](https://github.com/s3tools/s3cmd).

```sh
sudo apt install s3cmd
```

Configure `s3cmd` using the `ReadOnly` credentials from the secret `seaweedfs-s3-user-readonly`.

```sh
s3cmd --configure
```

Configure the endpoints to use **SeaweedFS** instead of AWS S3.

```text
Use "s3.amazonaws.com" for S3 Endpoint and not modify it to the target Amazon S3.
S3 Endpoint [s3.amazonaws.com]: seaweedfs-s3.int.fivebytestudios.com

Use "%(bucket)s.s3.amazonaws.com" to the target Amazon S3. "%(bucket)s" and "%(location)s" vars can be used
if the target S3 system supports dns based buckets.
DNS-style bucket+hostname:port template for accessing a bucket [%(bucket)s.s3.amazonaws.com]: seaweedfs-s3.int.fivebytestudios.com
```

This uses path-style requests (`seaweedfs-s3.int.fivebytestudios.com/<bucket>`) since there is no DNS,
gateway listener, or certificate for `<bucket>.seaweedfs-s3.int.fivebytestudios.com`.

For everything else, just press enter until you get to this prompt at the end.

```text
Save settings? [y/N] y
```

## S3 Users

S3 users are defined in `s3.identities` in [values.yaml](values.yaml). Credentials are
`${VAR}` references, which SeaweedFS resolves from the environment variables in
`seaweedfs.filer.secretExtraEnvironmentVars`, each read from a sealed secret
`seaweedfs-s3-user-<user>`.

To add a user:

1. Add the identity to `s3.identities`, and its 2 environment variables to
   `seaweedfs.filer.secretExtraEnvironmentVars`.
2. Add the user to [create-sealed-secrets-s3-users.sh](create-sealed-secrets-s3-users.sh),
   including the namespace and directory of the client's copy of the secret if needed.
3. Generate the sealed secrets:

   ```sh
   ./create-sealed-secrets-s3-users.sh <user>
   ```

Running the script for an existing user rotates its credentials. SeaweedFS only reads
credentials and identities on startup, so restart the filer if the environment variables
didn't change.

## Weed Shell

```sh
kubectl exec --stdin --tty --namespace=seaweedfs service/seaweedfs-master -- weed shell
```
