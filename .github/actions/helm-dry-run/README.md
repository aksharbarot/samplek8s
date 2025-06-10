# Helm Dry‑Run Composite Action

A reusable GitHub Actions **composite** that renders a Helm chart with `--dry-run --debug` against an Amazon EKS cluster using short‑lived OIDC credentials. No resources are created on the cluster—only the full manifest is rendered, logged, and uploaded as an artifact.

---

## Why another action?

* **Shift‑left validation** — catch template or API‑version errors before the deploy job.
* **Security first** — assumes *read‑only* IAM roles via GitHub OIDC (no long‑lived keys).
* **Plug & play** — call it locally (`uses: ./.github/actions/helm-dry-run`) or from any other repo (`uses: your‑org/helm-dry-run@v1`).
* **Artifacts** — stores `manifest.yaml` so reviewers and automated tools can lint or diff the output.

---

## Repository layout

```text
.
├─ .github
│  ├─ actions
│  │   └─ helm-dry-run      # ← the composite (action.yaml)
│  └─ workflows
│      └─ helm-dry-run.yaml       # sample CI lane that calls it
└─ (optional) .github/shared-library/…/clusters-arn.json
```

*`clusters-arn.json`* maps `<cluster>-readonly` → IAM role ARN and is only required when you **don’t** pass an explicit `cluster-read-role` input.

---

## Prerequisites

| Requirement                             | Notes                                                                                                               |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **GitHub OIDC** trust on your IAM roles | Same setup you use for deploy roles (`sts:AssumeRoleWithWebIdentity`).                                              |
| Read‑only IAM policy                    | `eks:Describe*` and `eks:List*` are enough. Add `ecr:GetAuthorizationToken` if pulling OCI charts from private ECR. |
| Helm ≥ 3.13 on runner                   | The action installs it via `azure/setup-helm@v3`.                                                                   |
| (Optional) `clusters-arn.json`          | Only needed for *implicit* role lookup.                                                                             |

---

## Inputs

| Name                | Required | Default   | Description                                                                                                        |
| ------------------- | -------- | --------- | ------------------------------------------------------------------------------------------------------------------ |
| `cluster-name`      | **yes**  | –         | EKS cluster name (as shown in AWS console)                                                                         |
| `region`            | **yes**  | –         | AWS region of that cluster                                                                                         |
| `release-name`      | **yes**  | –         | Helm release to *pretend* to upgrade                                                                               |
| `chart-path`        | **yes**  | –         | Folder or OCI reference of the chart                                                                               |
| `namespace`         | no       | `default` | K8s namespace to render into                                                                                       |
| `ecr-registry`      | no       | ""        | Private ECR registry (`111111111111.dkr.ecr.eu-west-1.amazonaws.com`)                                              |
| `registry-role`     | no       | ""        | Read‑only role that can pull that registry                                                                         |
| `cluster-read-role` | no       | ""        | Read‑only role for the cluster. If omitted, the action looks for `<cluster-name>-readonly` in `clusters-arn.json`. |

## Outputs

| Name       | Description                                   |
| ---------- | --------------------------------------------- |
| `manifest` | The rendered YAML manifest (multi‑doc stream) |

---

## Usage

### 1. Same repository (zero extra config)

```yaml
# .github/workflows/dry-run.yml
on:
  pull_request:
    paths: [ 'k8s/bundles/**' ]

jobs:
  preview:
    runs-on: ubuntu-latest
    permissions:
      id-token: write   # OIDC
      contents: read
    steps:
      - uses: ./.github/actions/helm-dry-run
        with:
          cluster-name: dev-eu-1
          region:       eu-west-1
          release-name: portal-bff
          chart-path:   k8s/bundles/portal-bff
          namespace:    portal-bff
```

*Requires* `clusters-arn.json` containing a `dev-eu-1-readonly` entry.

### 2. Remote repository

```yaml
jobs:
  preview:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: your-org/helm-dry-run@v1
        with:
          cluster-name: dev-eu-1
          region:       eu-west-1
          release-name: my‑svc
          chart-path:   charts/my‑svc
          cluster-read-role: arn:aws:iam::123456789012:role/github-readonly-dev-eu-1
```

### 3. Private OCI chart example

```yaml
with:
  …
  ecr-registry: 111111111111.dkr.ecr.eu-west-1.amazonaws.com
  registry-role: arn:aws:iam::111111111111:role/github-ecr-readonly
```

---

## Artifact

The workflow uploads **`manifest.yaml`** as `helm-manifest-<commit>.zip` (7‑day retention). Download it from the “Artifacts” section on the run page.

---

## Common questions

| Question                            | Answer                                                                                                      |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| *Will this ever mutate my cluster?* | No. The IAM role lacks write verbs, and Helm is executed with `--dry-run --debug`.                          |
| *Why YAML instead of JSON?*         | Most Kubernetes tooling and reviewers expect YAML. Convert to JSON on the fly with `yq -o=json`.            |

