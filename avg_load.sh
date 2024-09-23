#!/bin/bash
# 시스템 부하 정보 수집 스크립트

echo "시스템 부하 정보"
echo "================"

# 1. uptime 정보
echo "1. 시스템 가동 시간 및 평균 부하"
echo "--------------------------------"
uptime_output=$(uptime)
echo "$uptime_output"
echo

# Load average 값 추출 및 변수에 저장
load_averages=$(echo "$uptime_output" | awk -F'load average:' '{print $2}' | tr -d ' ')
IFS=',' read -r load1 load5 load15 <<< "$load_averages"

echo "Load averages:"
echo "1분 평균: $load1"
echo "5분 평균: $load5"
echo "15분 평균: $load15"
echo

echo "------------------------------"
# 부하 상태 확인
echo -n "Process Work Load Status: "
if (( $(echo "$load1 > 4" | bc -l) )); then
    echo "Work Load High"
else
    echo "Normal"
fi
echo

# I/O Wait 상태 확인
iowait=$(mpstat 1 1 | awk '$3 == "all" {print $7}' | tail -n 1)
echo -n "I/O Wait Status: "
if (( $(echo "$iowait > 70" | bc -l) )); then
    echo "High (${iowait}% I/O wait)"
else
    echo "Normal (${iowait}% I/O wait)"
fi
echo

# CPU 사용률 상태 확인
cpu_stats=$(mpstat 1 1 | awk '$3 == "all" {print $4, $6}' | tail -n 1)
read usr sys <<< "$cpu_stats"
total_usage=$(echo "$usr + $sys" | bc)
echo -n "CPU Usage Status: "
if (( $(echo "$total_usage > 70" | bc -l) )); then
    echo "High (Total: ${total_usage}%)"
else
    echo "Normal (Total: ${total_usage}%)"
fi
echo

echo "------------------------------"
echo



# 2. CPU 사용률 정보 (mpstat)
echo "2. CPU 사용률"
echo "-------------"
mpstat_output=$(mpstat -P ALL 1 1)
echo "$mpstat_output" | awk '
    /^[0-9]/ && NF == 13 {
        if ($3 == "all" || $3 ~ /^[0-9]+$/) {
            printf "CPU: %-3s  %%usr: %-6s  %%sys: %-6s  %%iowait: %-6s  %%idle: %-6s\n", $3, $4, $6, $7, $13
        }
    }'
echo

# 3. 프로세스별 CPU 사용률 (pidstat)
echo "3. 프로세스별 CPU 사용률 (상위 10개)"
echo "------------------------------------"
pidstat_output=$(pidstat -u 1 1)
echo "$pidstat_output" | awk '
    NR > 3 {
        printf "PID: %-6s  %%CPU: %-6s  명령어: %s\n", $3, $8, $NF
    }
' | sort -k3 -rn | head -10
