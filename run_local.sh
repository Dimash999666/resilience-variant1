#!/bin/sh
# Тот же эксперимент без Kubernetes, на своем компьютере (для отладки).
#   ./run_local.sh off   и   ./run_local.sh on
# Переменные: FAULT (по умолчанию {"down": true}), DUR (по умолчанию 120), TIMEOUT_S, FAILBACK_S
MODE=$1
FAULT=${FAULT:-'{"down": true}'}
OK='{"delay_ms": 0, "error_rate": 0, "down": false}'
DUR=${DUR:-120}
mkdir -p results
PORT=18081 NAME=dep-a python3 dep.py & A=$!
PORT=18082 NAME=dep-b python3 dep.py & B=$!
PORT=18080 PATTERN=$MODE DEP_URL=http://127.0.0.1:18081 DEP_URL_B=http://127.0.0.1:18082 python3 core.py & C=$!
sleep 1
python3 loadgen.py --url http://127.0.0.1:18080/work --duration $DUR > results/$MODE.csv &
L=$!
sleep $((DUR / 4)); curl -s -d "$FAULT" http://127.0.0.1:18081/fault; echo " <- отказ включен"
sleep $((DUR / 4)); curl -s -d "$OK" http://127.0.0.1:18081/fault; echo " <- отказ снят"
wait $L
kill $A $B $C
python3 metrics.py results/$MODE.csv
