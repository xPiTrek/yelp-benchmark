#!/bin/bash
# ============================================================
# Yelp Benchmark Runner
# Adapted from ronaldbradford/benchmark
# Uses core.lua from the cloned repo
# ============================================================

CORE_LUA="./benchmark/mysql/imdb/core.lua"
RESULTS_DIR="results"
mkdir -p $RESULTS_DIR

CONFIGS=("local-mysql" "local-pgsql" "rds-mysql" "rds-pgsql")
TYPES=("business" "user")
THREAD_COUNTS="1 5 10 20"

echo "============================================================"
echo "YELP DATABASE BENCHMARK - CMPG-658"
echo "Tool: sysbench + core.lua (ronaldbradford/benchmark)"
echo "============================================================"

echo "database,type,threads,tps,qps,latency_avg_ms,latency_95th_ms" > "$RESULTS_DIR/results.csv"

for config in "${CONFIGS[@]}"; do
    for type in "${TYPES[@]}"; do
        for threads in $THREAD_COUNTS; do

            echo ""
            echo "--- $config | type=$type | threads=$threads ---"

            result=$(sysbench $CORE_LUA \
                --config-file=${config}.cnf \
                --type=$type \
                --threads=$threads \
                run 2>&1)

            tps=$(echo "$result" | grep "transactions:" | awk -F'[()]' '{print $2}' | awk '{print $1}')
            qps=$(echo "$result" | grep "queries:" | head -1 | awk -F'[()]' '{print $2}' | awk '{print $1}')
            lat_avg=$(echo "$result" | grep "avg:" | tail -1 | awk '{print $2}')
            lat_95=$(echo "$result" | grep "95th percentile:" | awk '{print $3}')

            echo "  TPS=$tps  QPS=$qps  Lat=${lat_avg}ms  95th=${lat_95}ms"

            echo "$result" > "$RESULTS_DIR/${config}_${type}_t${threads}.txt"
            echo "$config,$type,$threads,$tps,$qps,$lat_avg,$lat_95" >> "$RESULTS_DIR/results.csv"

        done
    done
done

echo ""
echo "============================================================"
echo "COMPLETE - Results: $RESULTS_DIR/results.csv"
echo "============================================================"
cat "$RESULTS_DIR/results.csv" | column -t -s ','
