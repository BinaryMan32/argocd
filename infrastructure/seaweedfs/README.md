# SeaweedFS

See [SeaweedFS Wiki](https://github.com/seaweedfs/seaweedfs/wiki).

## Testing with s3cmd

Install [s3cmd](https://github.com/s3tools/s3cmd).

```sh
sudo apt install s3cmd
```

Configure `s3cmd` using the `ReadOnly` credentials from the secret `seaweedfs-s3-config`.

```sh
s3cmd --configure
```

Configure the endpoints to use **SeaweedFS** instead of AWS S3.

```text
Use "s3.amazonaws.com" for S3 Endpoint and not modify it to the target Amazon S3.
S3 Endpoint [s3.amazonaws.com]: seaweedfs.int.fivebytestudios.com             

Use "%(bucket)s.s3.amazonaws.com" to the target Amazon S3. "%(bucket)s" and "%(location)s" vars can be used
if the target S3 system supports dns based buckets.
DNS-style bucket+hostname:port template for accessing a bucket [%(bucket)s.s3.amazonaws.com]: %(bucket)s.seaweedfs.int.fivebytestudios.com
```

For everything else, just press enter until you get to this prompt at the end.

```text
Save settings? [y/N] y
```
