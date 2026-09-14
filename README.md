# DeepSeek Harness + OpenCode Go (Docker)

Run the published DeepSeek Harness with OpenCode Go through a local Docker
deployment. This repository does **not** contain DeepSeek Harness source code.

## Start

Install Docker, then provide an OpenCode Go API key.

```sh
git clone https://github.com/tomohiro-owada/deepseek-harness-opencode.git
cd deepseek-harness-opencode
cp .env.example .env
# Set OPENCODE_API_KEY in .env.
docker compose up --build -d
```

Open the URL shown by:

```sh
docker compose logs harness
```

The UI listens only on `127.0.0.1`. The container can reach only
`opencode.ai`, and the OpenCode Go session header is derived from each Harness
conversation.

## Documentation

This repository owns only the Docker wrapper. For DeepSeek Harness usage,
configuration, safety information, and upstream support, see the
[official DeepSeek Harness repository](https://github.com/deepseek-ai/deepseek-harness).

For OpenCode Go account, model, and availability details, see the
[official OpenCode Go documentation](https://opencode.ai/docs/go/).
