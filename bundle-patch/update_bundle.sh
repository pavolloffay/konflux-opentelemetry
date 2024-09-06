#!/usr/bin/env bash

set -e

export OTEL_COLLECTOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/collector@sha256:7bb4dfa26103f5d71546a80e6628079522c222390830eb81750195faee6d486c"
# Separate due to merge conflicts
export OTEL_TARGET_ALLOCATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/otel-target-allocator@sha256:db814f6e71bb646c9e41bcdbbda9b85ccb34f63624d46d348580c672b259e710"
# Separate due to merge conflicts
export OTEL_OPERATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/operator@sha256:d3087c953dcad87b004a96fd6021821090bccc32f7e068b76cb4cbb8588a6623"


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
