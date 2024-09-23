# Average-Load-Linux

---

<h2 style="font-size: 25px;"> 개발팀원👨‍👨‍👧‍👦💻<br>
<br>

|<img src="https://avatars.githubusercontent.com/u/66353700?v=4" width="150" height="150"/>|<img src="https://avatars.githubusercontent.com/u/98442485?v=4" width="150" height="150"/>|
|:-:|:-:|:-:|:-:|
|[@부준혁](https://github.com/BooJunhyuk)||[@이승언](https://github.com/haewoni)||[@신혜원](https://github.com/haewoni)|[@이연희](https://github.com/LeeYeonhee-00)|

---

<br>

## 실습 개요 :star:


<br>

## 실습 과정 :mag_right:
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




