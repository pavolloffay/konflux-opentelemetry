#!/usr/bin/env bash

set -e

# The pullspec should be image index, check if all architectures are there with: skopeo inspect --raw docker://$IMG | jq
export OTEL_COLLECTOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/opentelemetry-collector@sha256:fbeb64f818651474b12ad10c4a50fe69373fca8ea9161913c9cc6a3321045194"
# Separate due to merge conflicts
export OTEL_TARGET_ALLOCATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/opentelemetry-target-allocator@sha256:f54ed350c78da0df0a5970edc65d4b90b3fd2c703f335f4e12ad139ee322d83a"
# Separate due to merge conflicts
export OTEL_OPERATOR_IMAGE_PULLSPEC="quay.io/redhat-user-workloads/rhosdt-tenant/otel/opentelemetry-operator@sha256:680b47ab30aae28e0b3762ca8b47a5522afbe10c8103cf1c849a95b345554332"
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
