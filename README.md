# Multi-socat in Cloudflare WARP on Docker

Creates multiple socat pipes based on env-var names that start with 'CLOUDFLAREWARP_SOCAT'
within a Cloudflare WARP connected session.

## Usage

Better docs someday...

Env-vars with prefix `CLOUDFLAREWARP_SOCAT` are sorted and used as `socat` command line inputs.

```yaml
services:
  my-cfwarp-socat:
    image: "threatpatrols/cfwarp-socat"
    environment:
      CLOUDFLAREWARP_SOCAT_02: "TCP4-LISTEN:2222,reuseaddr,fork TCP4:127.0.0.1:22"
      CLOUDFLAREWARP_SOCAT_01: "UNIX-LISTEN:/run/docker.sock,reuseaddr,fork TCP4:127.0.0.1:80"
```

## Source / Repo
* source: https://github.com/threatpatrols/docker-cfwarp-socat
* repo: https://hub.docker.com/r/threatpatrols/cfwarp-socat
