#!/usr/bin/env bash

set -e

# The pullspec should be image index, check if all architectures are there with: skopeo inspect --raw docker://$IMG | jq
export OTEL_COLLECTOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/opentelemetry-collector@sha256:d7293b063ee4c803c1303a9560bb1c585bd0cea248666a65315792c8c2c1be2a"
# Separate due to merge conflicts
export OTEL_TARGET_ALLOCATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/opentelemetry-target-allocator@sha256:d673006824773be6263d16275b692eb481dcd45af5cc966aad0c8937af7aef27"
# Separate due to merge conflicts
export OTEL_OPERATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/opentelemetry-operator@sha256:bc39a32d1489447d7b8c2dd4e0663399b26cd9928302bd8e5b4b5adc1d3f4560"
# Separate due to merge conflicts
# TODO, we used to set the proxy image per OCP version
export OSE_KUBE_RBAC_PROXY_PULLSPEC="registry.redhat.io/openshift4/ose-kube-rbac-proxy@sha256:8204d45506297578c8e41bcc61135da0c7ca244ccbd1b39070684dfeb4c2f26c"

if [[ $REGISTRY == "registry.redhat.io" ||  $REGISTRY == "registry.stage.redhat.io" ]]; then
  OTEL_COLLECTOR_IMAGE_PULLSPEC="$REGISTRY/rhosdt/opentelemetry-collector-rhel8@${OTEL_COLLECTOR_IMAGE_PULLSPEC:(-71)}"
  OTEL_TARGET_ALLOCATOR_IMAGE_PULLSPEC="$REGISTRY/rhosdt/opentelemetry-target-allocator-rhel8@${OTEL_TARGET_ALLOCATOR_IMAGE_PULLSPEC:(-71)}"
  OTEL_OPERATOR_IMAGE_PULLSPEC="$REGISTRY/rhosdt/opentelemetry-rhel8-operator@${OTEL_OPERATOR_IMAGE_PULLSPEC:(-71)}"
fi

export CSV_FILE=/manifests/opentelemetry-operator.clusterserviceversion.yaml

sed -i "s#opentelemetry-collector-container-pullspec#$OTEL_COLLECTOR_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#opentelemetry-target-allocator-container-pullspec#$OTEL_TARGET_ALLOCATOR_IMAGE_PULLSPEC#g" patch_csv.yaml
sed -i "s#ose-kube-rbac-proxy-container-pullspec#$OSE_KUBE_RBAC_PROXY_PULLSPEC#g" patch_csv.yaml
sed -i "s#opentelemetry-operator-container-pullspec#$OTEL_OPERATOR_IMAGE_PULLSPEC#g" patch_csv.yaml

#export AMD64_BUILT=$(skopeo inspect --raw docker://${OTEL_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="amd64")')
#export ARM64_BUILT=$(skopeo inspect --raw docker://${OTEL_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="arm64")')
#export PPC64LE_BUILT=$(skopeo inspect --raw docker://${OTEL_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="ppc64le")')
#export S390X_BUILT=$(skopeo inspect --raw docker://${OTEL_OPERATOR_IMAGE_PULLSPEC} | jq -e '.manifests[] | select(.platform.architecture=="s390x")')
export AMD64_BUILT=true
export ARM64_BUILT=true
export PPC64LE_BUILT=true
export S390X_BUILT=true

export EPOC_TIMESTAMP=$(date +%s)

# https://issues.redhat.com/browse/TRACING-4288
patch manifests/opentelemetry-operator-controller-manager-metrics-service_v1_service.yaml opentelemetry-operator-controller-manager-metrics-service_v1_service.patch
cat manifests/opentelemetry-operator-controller-manager-metrics-service_v1_service.yaml

# time for some direct modifications to the csv
python3 patch_csv.py
python3 patch_annotations.py
