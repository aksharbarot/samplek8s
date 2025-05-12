# 🚀 Kube Linter Composite Action

A composite GitHub Action to lint Kubernetes YAML manifests using [`kube-linter`](https://github.com/stackrox/kube-linter).  
It helps you enforce production-readiness and security best practices in your Kubernetes configurations.

---

## ✅ Features

- Scans Kubernetes YAML files for missing probes, security settings, and resource limits
- Detects and warns about files missing `apiVersion:` or `kind:`
- Automatically skips non-Kubernetes YAMLs like `values.yaml` or `exm.yaml`
- Uploads scan results as artifacts (automatically handled by GitHub Actions)
- Fully compatible with GitHub-hosted runners and supports local testing via `act`

---

## 📥 Inputs

| Input                | Description                                          | Default     |
|----------------------|------------------------------------------------------|-------------|
| `directory`          | Directory containing Kubernetes manifests            | `./k8s`     |
| `output-file-format` | Output format (used for file naming only)            | `txt`       |

---

## 🚀 Usage (GitHub Actions)

To use this action:

1. **Create the composite action** inside your repository at:
   ```
   .github/actions/kube-linter-comp/action.yaml
   ```

2. **Add the README** at:
   ```
   .github/actions/kube-linter-comp/README.md
   ```

3. **Create a workflow file** to call the action:
   Place the following in:
   ```
   .github/workflows/kube-lint.yaml
   ```

```yaml
name: Kube Linter Scan

on:
  push:
    paths:
      - 'k8s/**'
  pull_request:
    paths:
      - 'k8s/**'

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - name: Run kube-linter composite action
        uses: your-org/your-repo/.github/actions/kube-linter-comp@main
        with:
          directory: './k8s/bundles'
          output-file-format: 'txt'
```

> 🔁 Replace `ORG/REPO` and `BRANCH` with your actual GitHub organization, repository, and branch name.

---

## 📦 Using This Action from Another Repository

You can use this composite action across repositories.

### Step-by-step:

1. In **Repository-1**, place this action at:
   ```
   .github/actions/kube-linter-comp/action.yaml
   ```

2. In **Repository-2**, create a workflow like this:

```yaml
name: Kube Linter Scan

on:
  push:
    paths:
      - 'k8s/**'
  pull_request:
    paths:
      - 'k8s/**'

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - name: Run kube-linter composite action from external repo
        uses: ORG/REPONAME/.github/actions/kube-linter-comp@main
        with:
          directory: './k8s/bundles'
          output-file-format: 'txt'
```

- This will scan all YAML files under `./k8s/bundles` in **Repository-2**
- Replace `ORG/repository-1` and `main` with your actual organization and branch/tag name

> Note: The linter will run in the context of the repository where the workflow is triggered (e.g., `repository-2`)

---

## 🧪 Local Testing with `act` (Optional)

For local testing before pushing to GitHub, you can use [`act`](https://github.com/nektos/act):

```bash
ACT=true act push -W .github/workflows/kube-lint.yaml -r your-org/your-repo=.
```

This will simulate a GitHub Actions run locally, using Docker.

---

## ⚠️ Notes

- Only YAML files that contain both `apiVersion:` and `kind:` will be linted
- This action does **not render Helm charts** — it only works on full Kubernetes manifests
- Non-Kubernetes config files (e.g., `values.yaml`, `exm.yaml`) are skipped automatically

