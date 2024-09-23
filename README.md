# Average-Load-Linux

---

<h2 style="font-size: 25px;"> 개발팀원👨‍👨‍👧‍👦<br>
<br>

|<img src="https://avatars.githubusercontent.com/u/127727927?v=4" width="150" height="150"/>|<img src="https://avatars.githubusercontent.com/u/90971532?v=4" width="150" height="150"/>|<img src="https://avatars.githubusercontent.com/u/98442485?v=4" width="150" height="150"/>|<img src="https://avatars.githubusercontent.com/u/66353700?v=4" width="150" height="150"/>|
|:-:|:-:|:-:|:-:|
|[@부준혁](https://github.com/BooJunhyuk)|[@이승언](https://github.com/seungunleeee)|[@신혜원](https://github.com/haewoni)|[@이연희](https://github.com/LeeYeonhee-00)|

---

<br>

## Average Load 개념:mag_right:
### uptime 명령어
```
$ uptime
02:34:03             // 현재 시간
up 2 days, 20:14     // 시스템 가동시간
1 user               // 로그인한 사용자 수
load average: 0.63, 0.83, 0.88  // 지난 1분, 5분, 15분 동안의 평균 부하
```
### Average load ?
Average load와 CPU 사용률은 쉽게 혼동되지만 다른 개념 <br>
Average load는 일정 시간 동안 실행 중이거나 대기 중인 프로세스의 수를 의미합니다. 여기에는 CPU를 사용 중인 프로세스뿐만 아니라 CPU 대기 중이거나 I/O 작업을 기다리는 프로세스도 포함됩니다. <br>
CPU 사용률은 CPU가 실제로 얼마나 바쁜지를 나타내는 통계입니다. <br>
예를 들어, CPU를 많이 사용하는 프로세스는 평균 부하와 CPU 사용률을 모두 증가시키지만, I/O 대기 프로세스는 평균 부하를 높이면서도 CPU 사용률은 낮을 수 있습니다. <br>

- Runnable 프로세스 <br>
: CPU를 사용 중이거나 CPU time이 할당되기를 기다르는 프로세스
ps 명령어를 통해 확인할 수 있습니다.
Running(실행 중): 현재 CPU를 사용 중인 상태.
Runnable(실행 가능한): CPU 사용이 가능하지만, 다른 프로세스가 CPU를 사용 중이어서 차례를 기다리는 상태.<br>
- Uninterruptible 프로세스 <br>
: 중요한 커널 프로세스를 실행 중이기 때문에 외부 신호나 인터럽트로 중단될 수 없는 상태입니다.
주로 D(Disk Sleep or Uninterruptible Sleep) 상태로 표시
주로 하드웨어 장치로부터 I/O 응답을 기다리는 중
예를 들어, 디스크에서 데이터를 읽거나 쓰는 작업을 수행할 때, 해당 작업이 완료될 때까지 프로세스는 "D" 상태로 전환

### 조회 명령어
```watch -d uptime``` : 평균 부하 변화를 모니터링<br>
```mpstat``` : 다중 CPU 성능을 분석하고, 각 CPU와 전체 CPU의 실시간 성능을 분석<br>
```pidstat``` : 개별 프로세스의 CPU, 메모리, I/O 성능을 실시간으로 분석<br>

<br>

## 실습 과정💻
: 관련 정보 결과를 한 번에 확인할 수 있는 스크립트 작성 <br>
### 정보 수집 script
```
#!/bin/bash

# 시스템 부하 정보 수집 스크립트

echo "시스템 부하 정보"
echo "================"

# 1. uptime 정보
echo "1. 시스템 가동 시간 및 평균 부하"
echo "--------------------------------"
uptime | awk '{print "가동 시간:", $3, $4, "\t평균 부하:", $(NF-2), $(NF-1), $NF}'
echo

# 2. CPU 사용률 정보 (mpstat)
echo "2. CPU 사용률"
echo "-------------"
mpstat -P ALL 1 1 | awk '
    /^[0-9]/ && NF == 13 {
        if ($3 == "all" || $3 ~ /^[0-9]+$/) {
            printf "CPU: %-3s  %%usr: %-6s  %%sys: %-6s  %%iowait: %-6s  %%idle: %-6s\n", $3, $4, $6, $7, $13
        }
    }'
echo

# 3. 프로세스별 CPU 사용률 (pidstat)
echo "3. 프로세스별 CPU 사용률 (상위 10개)"
echo "------------------------------------"
pidstat -u 1 1 | awk '
    NR > 3 {
        printf "PID: %-6s  %%CPU: %-6s  명령어: %s\n", $3, $8, $NF
    }
' | sort -k3 -rn | head -10
```
### script 실행 명령어 (5초마다 정보 수집)
```
watch -n 5 ./avg_load.sh
```
### 정보 수집 결과
![image](https://github.com/user-attachments/assets/99247669-7a79-4d44-baf8-f9e09d7b7126)




