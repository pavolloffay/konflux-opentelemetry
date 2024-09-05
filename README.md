# konflux-opentelemetry

## Build locally

1. Authenticate to brew docker registry
2. Build locally

```bash
podman build -t docker.io/user/otel-operator:$(date +%s) -f Dockerfile.operator 
```

## Release

Update [patch_csv.yaml](./bundle-patch/patch_csv.yaml):
1. `spec.name` with the current verion e.g. `opentelemetry-operator.v0.108.0`
1. `spec.replaces` with the previous shipped version of CSV e.g. `opentelemetry-operator.v0.107.0-4`
1. `metadata.extra_annotations.olm.skipRange` with the version being productized e.g. `'>=0.33.0 <0.108.0'`


## Test locally

Images can be found at https://quay.io/organization/redhat-user-workloads