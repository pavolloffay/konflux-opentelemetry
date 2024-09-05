# konflux-opentelemetry

## Build locally

1. Authenticate to brew docker registry
2. Build locally

```bash
podman build -t docker.io/user/otel-operator:$(date +%s) -f Dockerfile.operator 
```