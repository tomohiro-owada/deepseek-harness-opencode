# Docker deployment with minimal network access

This setup serves the Harness UI only on `http://127.0.0.1:3080`; it is not reachable from the LAN.

The Harness container lives on an internal-only Docker network, has no direct route to the Internet, and can use only the bundled proxy. A separate, non-privileged TCP relay exposes the local UI; it has no filesystem mounts and no application credentials. A second relay inside the Harness network preserves the application's loopback-only listener.

The proxy allows HTTPS traffic solely to `opencode.ai`, the OpenCode Go API endpoint.

OpenCode Go requires an `x-opencode-session` header for every conversation.
The image maps the Harness session ID to that header only for the `opencode-go`
provider, so each Harness conversation keeps its own OpenCode Go route. This
does not add a network service or retain prompts outside the Harness data
volume.

Telemetry, DeepSeek session-log contribution, and development HMR are disabled, and new sessions use the built-in minimal preset without Web search or Web fetch. Runtime configuration reload is disabled; update the policy deliberately and restart the stack if it changes.

## Start

Copy the example environment file, set your OpenCode Go API key, then launch the stack.

```sh
cp .env.example .env
# Edit .env and set OPENCODE_API_KEY.
docker compose up --build -d
```

Run `docker compose logs harness` and open the `dsh web:` URL it prints. The URL carries a fresh local browser-session token; opening the bare port URL is intentionally rejected.

The named `harness-data` volume keeps settings, credentials entered in the UI, and session history. The network policy is initialized into that volume when it is first created; do not remove `cordis.patch.yml` from it.

Files mounted at `./workspace` are the agent workspace. The directory picker also creates folders there when it refers to `/home/node/<name>` in the container. Do not put secrets there unless you intend the agent to read them.

## Verify the network boundary

The following command must fail because the Harness container has no direct Internet route:

```sh
docker compose exec harness node -e "fetch('https://example.com').then(() => process.exit(1)).catch(() => process.exit(0))"
```

Calls to `https://opencode.ai/zen/go/v1` are allowed through the proxy when a valid API key is configured.

The default model is `muse-spark-1.3-contributor`. Its availability is decided
by OpenCode Go for the current account and region; a region or provider error
is not an API-key error. Select another OpenCode Go model in the Harness UI if
that model is unavailable.

## Stop and remove

```sh
docker compose down
```

`down` preserves the named data volume.  Use `docker compose down --volumes` only when you intentionally want to delete saved Harness data and credentials.
