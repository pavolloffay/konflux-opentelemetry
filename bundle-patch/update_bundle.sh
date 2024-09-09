#!/usr/bin/env bash

set -e

export OTEL_COLLECTOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/collector@sha256:e939241e290964a6bf61db7ed02d10b36d6451f0f512acd498aaf5cfd04a4fce"
# Separate due to merge conflicts
export OTEL_TARGET_ALLOCATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/otel-target-allocator@sha256:78e27ceaf50391fb5a81cac51b5a7d24c46a0a135e43e5e469bc4f783c2c95dd"
# Separate due to merge conflicts
export OTEL_OPERATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/operator@sha256:1a98412df0b712bb55daa8a0921ce7f85b6a20a75ac2e059674b2596ebf23141"


export CSV_FILE=/manifests/opentelemetry-operator.clusterserviceversion.yaml

sed -i -e "s|ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator\:.*|\"${OTEL_OPERATOR_IMAGE_PULLSPEC}\"|g" \
	"${CSV_FILE}"

sed -i "s#opentelemetry-collector-container-pullspec#$OTEL_COLLECTOR_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#opentelemetry-target-allocator-container-pullspec#$OTEL_TARGET_ALLOCATOR_IMAGE_PULLSPEC#g" patch_csv.yaml

export AMD64_BUILT=$(skopeo inspect --raw docker://${OTEL_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="amd64")')
export ARM64_BUILT=$(skopeo inspect --raw docker://${OTEL_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="arm64")')
export PPC64LE_BUILT=$(skopeo inspect --raw docker://${OTEL_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="ppc64le")')
export S390X_BUILT=$(skopeo inspect --raw docker://${OTEL_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="s390x")')

export EPOC_TIMESTAMP=$(date +%s)

# time for some direct modifications to the csv
python3 patch_csv.py
python3 patch_annotations.py
