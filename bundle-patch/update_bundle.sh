#!/usr/bin/env bash

set -e

export OTEL_COLLECTOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/collector@sha256:5987f9dbd1e4a20ed261c1878dfb461fd1a486d641ad8327c69e80cd817fa264"
# Separate due to merge conflicts
export OTEL_TARGET_ALLOCATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/otel-target-allocator@sha256:c6eae4867ed1aeef441971c83495e34d9140b4d2b7c01ba22429af8465f4498f"
# Separate due to merge conflicts
export OTEL_OPERATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/operator@sha256:5fe1b915b3784e6df2b49cc1b9a419d88afd03b992d91559dab77005cd76eab7"


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
