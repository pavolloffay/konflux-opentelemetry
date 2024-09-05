#!/usr/bin/env bash

export OTEL_COLLECTOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/collector@sha256:e4d235deca01261b6b6f259655a64160abffefc524d71ebac4678171a9b44138"
export OTEL_TARGET_ALLOCATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/otel-target-allocator@sha256:c6eae4867ed1aeef441971c83495e34d9140b4d2b7c01ba22429af8465f4498f"
export OTEL_OPERATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/operator@sha256:d85433fa0a2ac7689772ddcd2680cae73c89b317346ee4b3124f8725d9820ba0"

export CSV_FILE=/manifests/opentelemetry-operator.clusterserviceversion.yaml

sed -i -e "s|ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator\:.*|\"${OTEL_OPERATOR_IMAGE_PULLSPEC}\"|g" \
	"${CSV_FILE}"

export AMD64_BUILT=$(skopeo inspect --raw docker://${OTEL_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="amd64")')
export ARM64_BUILT=$(skopeo inspect --raw docker://${OTEL_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="arm64")')
export PPC64LE_BUILT=$(skopeo inspect --raw docker://${OTEL_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="ppc64le")')
export S390X_BUILT=$(skopeo inspect --raw docker://${OTEL_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="s390x")')

export EPOC_TIMESTAMP=$(date +%s)

# time for some direct modifications to the csv
python3 patch_csv.py
python3 patch_annotations.py
