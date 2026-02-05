#!/bin/bash

echo "=== 1. Consumer/Lag 관련 메트릭 존재 여부 ==="
curl -s http://localhost:9090/api/v1/label/__name__/values | jq -r '.data[]' | grep -E "(consumer|lag|offset)" | sort

echo -e "\n=== 2. test-topic의 현재 상태 ==="
curl -s 'http://localhost:9090/api/v1/query?query=kafka_topic_partition_current_offset{topic="test-topic"}' | jq '.data.result[] | "Partition \(.metric.partition): \(.value[1])"'

echo -e "\n=== 3. ReplicaFetcher Lag (브로커 복제 지연) ==="
curl -s 'http://localhost:9090/api/v1/query?query=kafka_server_fetcherlagmetrics_consumerlag{topic="test-topic"}' | jq '.data.result[] | "Partition \(.metric.partition): \(.value[1])"'

echo -e "\n=== 4. 컨슈머 그룹 메트릭 존재 여부 ==="
curl -s http://localhost:9090/api/v1/label/__name__/values | jq -r '.data[]' | grep consumergroup
if [ $? -ne 0 ]; then
    echo "❌ 컨슈머 그룹 메트릭 없음 - Kafka Exporter 필요"
fi
