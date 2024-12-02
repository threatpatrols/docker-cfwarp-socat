# Multi-socat in Cloudflare WARP on Docker

Creates multiple socat pipes based on env-var names that start with 'SOCAT_ARGS_'
within a Cloudflare WARP connected session.

## Usage

Better docs someday...

Env-vars with prefix `SOCAT_ARGS_` are sorted and used as `socat` command line inputs.

```yaml
services:
  my-cfwarp-socat:
    
    image: "threatpatrols/cfwarp-socat"
    environment:
      SOCAT_ARGS_02: "TCP4-LISTEN:2222,reuseaddr,fork TCP4:127.0.0.1:22"
      SOCAT_ARGS_01: "UNIX-LISTEN:/run/docker.sock,reuseaddr,fork TCP4:127.0.0.1:80"
      
    # required for Cloudflare WARP
    privileged: true

    volumes:
      - cloudflarewarp_varlib:/var/lib/cloudflare-warp

```

### Notes
- Recent cloudflare warp versions (2024.11.309.0) apper to require use of the `--privileged` flag to open the `tun` interface, would prefer an explicit approach.

## Source / Repo
* source: https://github.com/threatpatrols/docker-cfwarp-socat
* repo: https://hub.docker.com/r/threatpatrols/cfwarp-socat
