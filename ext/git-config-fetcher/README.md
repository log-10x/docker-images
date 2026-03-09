# Log10x Git Config Fetcher

Init container that clones Log10x configuration and symbol library repositories before the main pod starts.
Works with GitHub, GitLab, Bitbucket, Azure DevOps, and any HTTPS-accessible Git provider.
Used automatically by the Log10x Helm charts for GitOps-based deployments.

## Usage

```bash
docker run --rm \
  -e GIT_TOKEN=<your-token> \
  log10x/git-config-fetcher \
  --config-repo owner/repo
```

The `--config-repo` and `--symbols-repo` arguments accept any of these formats:

| Format | Example |
|--------|---------|
| `owner/repo` | `acme/my-config` (defaults to github.com) |
| `host/owner/repo` | `gitlab.com/acme/my-config` |
| Full URL | `https://gitlab.com/acme/my-config.git` |

## Environment Variables

| Variable | Description |
|----------|-------------|
| `GIT_TOKEN` | Git access token, injected automatically into repository URLs |

## Options

| Flag | Description |
|------|-------------|
| `--config-repo` | Pipeline configuration repository |
| `--config-branch` | Branch to checkout (default: repo default) |
| `--symbols-repo` | Compiled symbols repository |
| `--symbols-branch` | Branch to checkout (default: repo default) |
| `--symbols-path` | Subfolder within the symbols repo to extract |

## Documentation

Full GitOps deployment guide: [doc.log10x.com/engine/gitops](https://doc.log10x.com/engine/gitops/)
