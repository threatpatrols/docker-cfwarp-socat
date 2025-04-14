# Multi-socat in Cloudflare WARP on Docker

Creates multiple socat pipes based on env-var names that start with 'SOCAT_ARGS_'
within a Cloudflare WARP connected session.

## Usage

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

## Configuration

You can configure the container through the following environment variables:
  
- `WARP_START_DELAY`: The time to wait for the WARP daemon to start, in seconds. The default is 2 seconds. If the time is too short, it may cause the WARP daemon to not start before using the proxy, resulting in the proxy not working properly. If the time is too long, it may cause the container to take too long to start.

- `WARP_LICENSE_KEY`: The license key of the WARP client, which is optional. If you have subscribed to WARP+ service, you can fill in the key in this environment variable. If you have not subscribed to WARP+ service, you can ignore this environment variable.


It is possible to enroll the WARP client as a device in Cloudflare Zero Trust, by setting the following: 

- `WARP_ORGANIZATION`: Your organization identifier, can be found in Zero Trust under "Settings > Custom Pages" the string >before< ".cloudflareaccess.com"

- `WARP_CLIENT_ID`: From a Service Auth Token; make sure you allow your service-token to enroll devices under "Settings > WARP Client"

- `WARP_CLIENT_SECRET`: From a Service Auth Token

- `WARP_CONNECTOR_TOKEN`: The long connection string associated with the WARP tunnel configuration.  


### Notes
- Recent cloudflare warp versions (2024.11.309.0) apper to require use of the `--privileged` flag to open the `tun` interface, would prefer an explicit approach.

## Source / Repo
* source: https://github.com/threatpatrols/docker-cfwarp-socat
* repo: https://hub.docker.com/r/threatpatrols/cfwarp-socat
