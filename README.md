# gsd_dockerfiles
- Community Service Data 에서 사용할 도커 이미지 관리

## 작업 루트
- 도커 이미지들의 명명 패턴은 다음과 같다.
- /{harbor_project_name}/{module}/{phase}:{tag}

## 명령어 공통 수행 옵션
### --part : 파트
- part
  - common
  - band_feed
  - band_rcmd
  - cafe_rcmd
  - shiva
  - ntalk_rcmd

### -m, --module : 지원 모듈
- /parts/{part}/modules 내 폴더 이름을 참고하여 입력한다.

### -t --tag : 도커 이미지 태그
- 도커 이미지 작업 중 어떤 태그를 사용할지 명시한다.
- 미기재 시 latest 사용 
- -t time 기재 시 현재 기기의 날짜를 얻어( ex. 20201021 ) 사용한다.

### -p, --phase : 사용하는 phase. common part 인 경우에는 생략
- dev
  - 개발 환경
- stg
  - 스테이지 환경
- real
  - 리얼 환경

### --jdk : jdk 계열 build 시 버전 기재
- 8, 11, 15, 17, 21

### --python : python 계열 build 시 버전 기재
- 3_7, 3_8, 3_9, 3_10, 3_11, 3_12

## 사용 가능 명령어
### login
- harbor 에 docker login 한다.
- 각 part 별 read/write가 가능한 계정으로 로그인한다.
- read 만 가능한 계정으로 로그인 필요 시 parts/{part}/conf/env.sh 내 HARBOR_RO_USER 값을 참고한다. 
- 이후 다른 명령들을 수행하려면 로그인된 상태여야 하기 때문에 미리 로그인을 수행해 두어야 한다.
- 필요 argument: part
```shell
./login.sh band_rcmd
```

### build
- 로컬 dockerfile 기반으로 image build를 진행한다.
- build 시 latest 태그 이미지도 같이 build한다.
- 각 part, module에 대한 추가 설정은 before_build.sh, after_build.sh 참고
- 필요 argument: --part, -m, -p(common part 제외)
- 선택 argument: -t, --jdk, --python
```shell
./build.sh --part band_rcmd -p stg -m band_rcmd_jenkins -t 20201021
```

### pull
- docker pull
- 필요 argument: --part, -m, -p(common part 제외)
- 선택 argument: -t
```shell
./pull.sh --part band_rcmd -p stg -m band_rcmd_jenkins
```

### push
- docker push
- push 시 latest 태그 이미지도 같이 push한다.
- 필요 argument: --part, -m, -p(common part 제외)
- 선택 argument: -t

```shell
./push.sh --part band_rcmd -p stg -m band_rcmd_jenkins -t 20201021
```

### run
- local image 기반 docker run
- 각 part, module에 대한 추가 설정은 before_run.sh, after_run.sh 참고
- **대부분** 컨테이너가 /home1/irteam/deploy에 mount하므로, local에서 run 진행 시 
빌드 결과물을 /home1/irteam/deploy/doc_base 내부로 옮겨야 한다.
- 예시: band_rcmd_async 모듈 빌드 결과물인 feed-recommender/deploy/band_rcmd_async를 /home1/irteam/deploy/doc_base/band_rcmd_async로 이동
- 필요 argument: --part, -m, -p(common part 제외)
- 선택 argument: -t
```shell
./run.sh --part band_rcmd -p stg -m band_rcmd_async -t 20201021
```

### manage_application.sh
- 현재 실행 중인 컨테이너 내의 응용 서버 관리 스크립트를 통해 응용 서버를 실행 혹은 종료한다.
- 필요 argument: container name, command(start, stop)
```shell
./manage_application.sh band_rcmd_async start
```

# Troubleshooting
* 이미지 빌드 시 `yum install`이 실패하는 경우
  * `/etc/docker/daemon.json`에 `{"mtu": 1400}` 추가 (참고 링크: https://oss.navercorp.com/c3/users/issues/3606)

# Example
## common-navix
### navix
```shell
./build.sh --part common -m navix -t 8.10-20240812
./push.sh --part common -m navix -t 8.10-20240812
./pull.sh --part common -m navix -t 8.10-20240812
./run.sh --part common -m navix -t 8.10-20240812
```

### navix-nginx
```shell
./build.sh --part common -m navix-nginx -t 1.26.1-20240812
./push.sh --part common -m navix-nginx -t 1.26.1-20240812
./pull.sh --part common -m navix-nginx -t 1.26.1-20240812
./run.sh --part common -m navix-nginx -t 1.26.1-20240812
```

### navix-jdk
```shell
./build.sh --part common -m navix-jdk -t 8.0_275-20240812 --jdk 8  
./push.sh --part common -m navix-jdk -t 8.0_275-20240812
./pull.sh --part common -m navix-jdk -t 8.0_275-20240812
./build.sh --part common -m navix-jdk -t 11.0_24-20240812 --jdk 11  
./push.sh --part common -m navix-jdk -t 11.0_24-20240812
./pull.sh --part common -m navix-jdk -t 11.0_24-20240812
./build.sh --part common -m navix-jdk -t 15.0.2_7-20240812 --jdk 15  
./push.sh --part common -m navix-jdk -t 15.0.2_7-20240812
./pull.sh --part common -m navix-jdk -t 15.0.2_7-20240812
./build.sh --part common -m navix-jdk -t 17.0.12-20240812 --jdk 17  
./push.sh --part common -m navix-jdk -t 17.0.12-20240812 
./pull.sh --part common -m navix-jdk -t 17.0.12-20240812 
./build.sh --part common -m navix-jdk -t 21.0.2-20240812 --jdk 21  
./push.sh --part common -m navix-jdk -t 21.0.2-20240812 
./pull.sh --part common -m navix-jdk -t 21.0.2-20240812 

./run.sh --part common -m navix-jdk -t 8.0_275-20240812
./run.sh --part common -m navix-jdk -t 11.0_24-20240812
./run.sh --part common -m navix-jdk -t 15.0.2_7-20240812
./run.sh --part common -m navix-jdk -t 17.0.12-20240812 
./run.sh --part common -m navix-jdk -t 21.0.2-20240812 
```

### navix-python3
```shell
./build.sh --part common -m navix-python3 -t 3.7.17-20240812 --python 3_7
./push.sh --part common -m navix-python3 -t 3.7.17-20240812
./pull.sh --part common -m navix-python3 -t 3.7.17-20240812
./build.sh --part common -m navix-python3 -t 3.8.19-20240812 --python 3_8
./push.sh --part common -m navix-python3 -t 3.8.19-20240812
./pull.sh --part common -m navix-python3 -t 3.8.19-20240812
./build.sh --part common -m navix-python3 -t 3.9.19-20240812 --python 3_9
./push.sh --part common -m navix-python3 -t 3.9.19-20240812
./pull.sh --part common -m navix-python3 -t 3.9.19-20240812
./build.sh --part common -m navix-python3 -t 3.10.14-20240812 --python 3_10
./push.sh --part common -m navix-python3 -t 3.10.14-20240812
./pull.sh --part common -m navix-python3 -t 3.10.14-20240812
./build.sh --part common -m navix-python3 -t 3.11.9-20240812 --python 3_11
./push.sh --part common -m navix-python3 -t 3.11.9-20240812
./pull.sh --part common -m navix-python3 -t 3.11.9-20240812
./build.sh --part common -m navix-python3 -t 3.12.5-20240812 --python 3_12
./push.sh --part common -m navix-python3 -t 3.12.5-20240812
./pull.sh --part common -m navix-python3 -t 3.12.5-20240812

./run.sh --part common -m navix-python3 -t 3.7.17-20240812
./run.sh --part common -m navix-python3 -t 3.8.19-20240812
./run.sh --part common -m navix-python3 -t 3.9.19-20240812
./run.sh --part common -m navix-python3 -t 3.10.14-20240812
./run.sh --part common -m navix-python3 -t 3.11.9-20240812
./run.sh --part common -m navix-python3 -t 3.12.5-20240812
```

### navix-jenkins
```shell
./build.sh --part common -m navix-jenkins -t 2.462.1-20240812
./push.sh --part common -m navix-jenkins -t 2.462.1-20240812
./pull.sh --part common -m navix-jenkins -t 2.462.1-20240812
./run.sh --part common -m navix-jenkins -t 2.462.1-20240812
```

### navix-jenkins-example
```shell
./build.sh --part common -m navix-jenkins-example -t 2.462.1-20240812
./push.sh --part common -m navix-jenkins-example -t 2.462.1-20240812
./pull.sh --part common -m navix-jenkins-example -t 2.462.1-20240812
./run.sh --part common -m navix-jenkins-example -t 2.462.1-20240812
```

### navix-sd-build
- http://10.174.76.238/
  - ndeploy 연동용 api token : 112dee9a42126c5985c11cf5d5a116a54a
```shell
./build.sh --part common -m navix-sd-build -t 2.462.1-20240813
./push.sh --part common -m navix-sd-build -t 2.462.1-20240813
./pull.sh --part common -m navix-sd-build -t 2.462.1-20240813
./run.sh --part common -m navix-sd-build -t 2.462.1-20240813
```

### navix-sd-slack-bot
```shell
./build.sh --part common -m navix-sd-slack-bot -t 20240813
./push.sh --part common -m navix-sd-slack-bot -t 20240813
./pull.sh --part common -m navix-sd-slack-bot -t 20240813
./run.sh --part common -m navix-sd-slack-bot -t 20240813
```

### navix-devcontainer
```shell
./build.sh --part common -m navix-devcontainer -t 20240813
./push.sh --part common -m navix-devcontainer -t 20240813
./pull.sh --part common -m navix-devcontainer -t 20240813
./run.sh --part common -m navix-devcontainer -t 20240813
```

## common-c3s
### c3s-small
- c3s 는 spark executor 용으로 사용하는 도커 이미지의 경우 사이즈를 작게 유지하도록 가이드 하고 있다.
  - 기반이 되는 c3s 제공 이미지 : reg.c3s.navercorp.com/c3/base-c3s-env
  - c3s-small 은 base-c3s-env 를 기반으로 필요한 부분만 최소한으로 유지하려고 노력해야 한다.
  - c3s 쪽 네이밍 컨벤션을 무시하고 c3s-small/c3s-big 이라고 붙인 이유는 기존 컨벤션이 너무나도 헷깔려서 구분이 쉽지 않았기 때문이다...
```shell
./build.sh --part common -m c3s-small -t 20240129
./push.sh --part common -m c3s-small -t 20240129
./pull.sh --part common -m c3s-small -t 20240129
./run.sh --part common -m c3s-small -t 20240129
```

### c3s-big
- c3s 를 사용하기 위해 제공되는 기본 도커 이미지
  - 기반이 되는 c3s 제공 이미지 : reg.c3s.navercorp.com/c3/c3s-env
  - base-c3s-env 에 비해 추가적인 패키지가 많이 설치되어 있기 때문에 훨씬 덩치가 크다.
  - Service Data 팀 입장에서도 c3s-big 이미지에는 부담없이 이것저것 잔뜩(c3s-small 에 비해) 설치해도 된다.
  - cuve 문제
    - c3s 구형 이미지 + python 3.10 + openssl 직접 설치 조합인 경우 cuve 다운로드 시 문제가 있다.
    - https://oss.navercorp.com/sd/blog-rcmd/issues/233#issuecomment-12083447
      - certifi 를 설치하고 일부 옵션 활용해서 우회함
```shell
./build.sh --part common -m c3s-big -t 20240223
./push.sh --part common -m c3s-big -t 20240223
./pull.sh --part common -m c3s-big -t 20240223
./run.sh --part common -m c3s-big -t 20240223
```

## blog-rcmd
### jenkins
```shell
./build.sh --part blog_rcmd -m blog_rcmd_jenkins -p dev -t 2.426.1-20231212
./push.sh --part blog_rcmd -m blog_rcmd_jenkins -p dev -t 2.426.1-20231212
./pull.sh --part blog_rcmd -m blog_rcmd_jenkins -p dev -t 2.426.1-20231212
./build.sh --part blog_rcmd -m blog_rcmd_jenkins -p stg -t 2.426.1-20231212
./push.sh --part blog_rcmd -m blog_rcmd_jenkins -p stg -t 2.426.1-20231212
./pull.sh --part blog_rcmd -m blog_rcmd_jenkins -p stg -t 2.426.1-20231212
./build.sh --part blog_rcmd -m blog_rcmd_jenkins -p real -t 2.426.1-20231212
./push.sh --part blog_rcmd -m blog_rcmd_jenkins -p real -t 2.426.1-20231212
./pull.sh --part blog_rcmd -m blog_rcmd_jenkins -p real -t 2.426.1-20231212

./run.sh --part blog_rcmd -m blog_rcmd_jenkins -p dev -t 2.426.1-20231212
```

## ntalk-rcmd
### jenkins
```shell
./build.sh --part ntalk_rcmd -m ntalk_rcmd_jenkins -p dev -t 2.426.1-20231213
./push.sh --part ntalk_rcmd -m ntalk_rcmd_jenkins -p dev -t 2.426.1-20231213
./pull.sh --part ntalk_rcmd -m ntalk_rcmd_jenkins -p dev -t 2.426.1-20231213
./build.sh --part ntalk_rcmd -m ntalk_rcmd_jenkins -p real -t 2.426.1-20231213
./push.sh --part ntalk_rcmd -m ntalk_rcmd_jenkins -p real -t 2.426.1-20231213
./pull.sh --part ntalk_rcmd -m ntalk_rcmd_jenkins -p real -t 2.426.1-20231213
./run.sh --part ntalk_rcmd -m ntalk_rcmd_jenkins -p dev -t 2.426.1-20231213
```

## cafe-rcmd
### jenkins
```shell
./build.sh --part cafe_rcmd -m cafe_rcmd_jenkins -p dev -t 2.426.1-20231214
./push.sh --part cafe_rcmd -m cafe_rcmd_jenkins -p dev -t 2.426.1-20231214
./pull.sh --part cafe_rcmd -m cafe_rcmd_jenkins -p dev -t 2.426.1-20231214
./build.sh --part cafe_rcmd -m cafe_rcmd_jenkins -p stg -t 2.426.1-20231214
./push.sh --part cafe_rcmd -m cafe_rcmd_jenkins -p stg -t 2.426.1-20231214
./pull.sh --part cafe_rcmd -m cafe_rcmd_jenkins -p stg -t 2.426.1-20231214
./build.sh --part cafe_rcmd -m cafe_rcmd_jenkins -p real -t 2.426.1-20231214
./push.sh --part cafe_rcmd -m cafe_rcmd_jenkins -p real -t 2.426.1-20231214
./pull.sh --part cafe_rcmd -m cafe_rcmd_jenkins -p real -t 2.426.1-20231214

./run.sh --part cafe_rcmd -m cafe_rcmd_jenkins -p dev -t 2.426.1-20231214
```

### cafe-dd-jupyter
```shell
./build.sh --part common -m cafe-dd-jupyter -t 20240207
./push.sh --part common -m cafe-dd-jupyter -t 20240207
./pull.sh --part common -m cafe-dd-jupyter -t 20240207
./run.sh --part common -m cafe-dd-jupyter -t 20240207
```

### cafe-dd-spark-executor
```shell
./build.sh --part common -m cafe-dd-spark-executor -t 20240129
./push.sh --part common -m cafe-dd-spark-executor -t 20240129
./pull.sh --part common -m cafe-dd-spark-executor -t 20240129
./run.sh --part common -m cafe-dd-spark-executor -t 20240129
```

## band-rcmd
### jenkins
```shell
./build.sh --part band_rcmd -m band_rcmd_jenkins -p dev -t 2.426.1-20240305
./push.sh --part band_rcmd -m band_rcmd_jenkins -p dev -t 2.426.1-20240305
./pull.sh --part band_rcmd -m band_rcmd_jenkins -p dev -t 2.426.1-20240305
./build.sh --part band_rcmd -m band_rcmd_jenkins -p stg -t 2.426.1-20240305
./push.sh --part band_rcmd -m band_rcmd_jenkins -p stg -t 2.426.1-20240305
./pull.sh --part band_rcmd -m band_rcmd_jenkins -p stg -t 2.426.1-20240305
./build.sh --part band_rcmd -m band_rcmd_jenkins -p real -t 2.426.1-20240305
./push.sh --part band_rcmd -m band_rcmd_jenkins -p real -t 2.426.1-20240305
./pull.sh --part band_rcmd -m band_rcmd_jenkins -p real -t 2.426.1-20240305

./run.sh --part band_rcmd -m band_rcmd_jenkins -p dev -t 2.426.1-20240305
```

## shiva
### jenkins

## [Deprecated] common-rhel
### rhel
```shell
./build.sh --part common -m rhel -t 8.8-20240111  
./push.sh --part common -m rhel -t 8.8-20240111
./pull.sh --part common -m rhel -t 8.8-20240111
./run.sh --part common -m rhel -t 8.8-20240111
```

### rhel-nginx
```shell
./build.sh --part common -m rhel-nginx -t 1.25.3-20231206
./push.sh --part common -m rhel-nginx -t 1.25.3-20231206
./pull.sh --part common -m rhel-nginx -t 1.25.3-20231206
```

### rhel-jdk
```shell
./build.sh --part common -m rhel-jdk -t 8.0_275-20231206 --jdk 8  
./push.sh --part common -m rhel-jdk -t 8.0_275-20231206
./pull.sh --part common -m rhel-jdk -t 8.0_275-20231206
./build.sh --part common -m rhel-jdk -t 11.0_11-20231206 --jdk 11  
./push.sh --part common -m rhel-jdk -t 11.0_11-20231206
./pull.sh --part common -m rhel-jdk -t 11.0_11-20231206
./build.sh --part common -m rhel-jdk -t 15.0.1_9-20231206 --jdk 15  
./push.sh --part common -m rhel-jdk -t 15.0.1_9-20231206
./pull.sh --part common -m rhel-jdk -t 15.0.1_9-20231206
./build.sh --part common -m rhel-jdk -t 17.0.4-20231206 --jdk 17  
./push.sh --part common -m rhel-jdk -t 17.0.4-20231206 
./pull.sh --part common -m rhel-jdk -t 17.0.4-20231206 
```

### rhel-python3
```shell
./build.sh --part common -m rhel-python3 -t 3.7.17-20240111 --python 3_7
./push.sh --part common -m rhel-python3 -t 3.7.17-20240111
./pull.sh --part common -m rhel-python3 -t 3.7.17-20240111
./build.sh --part common -m rhel-python3 -t 3.8.18-20240111 --python 3_8
./push.sh --part common -m rhel-python3 -t 3.8.18-20240111
./pull.sh --part common -m rhel-python3 -t 3.8.18-20240111
./build.sh --part common -m rhel-python3 -t 3.9.18-20240111 --python 3_9
./push.sh --part common -m rhel-python3 -t 3.9.18-20240111
./pull.sh --part common -m rhel-python3 -t 3.9.18-20240111
./build.sh --part common -m rhel-python3 -t 3.10.13-20240111 --python 3_10
./push.sh --part common -m rhel-python3 -t 3.10.13-20240111
./pull.sh --part common -m rhel-python3 -t 3.10.13-20240111
./build.sh --part common -m rhel-python3 -t 3.11.7-20240111 --python 3_11
./push.sh --part common -m rhel-python3 -t 3.11.7-20240111
./pull.sh --part common -m rhel-python3 -t 3.11.7-20240111
./build.sh --part common -m rhel-python3 -t 3.12.1-20240111 --python 3_12
./push.sh --part common -m rhel-python3 -t 3.12.1-20240111
./pull.sh --part common -m rhel-python3 -t 3.12.1-20240111

./run.sh --part common -m rhel-python3 -t 3.7.17-20240111
```

### rhel-jenkins
```shell
./build.sh --part common -m rhel-jenkins -t 2.426.1-20231212
./push.sh --part common -m rhel-jenkins -t 2.426.1-20231212
./pull.sh --part common -m rhel-jenkins -t 2.426.1-20231212
./run.sh --part common -m rhel-jenkins -t 2.426.1-20231212
```

### rhel-jenkins-example
```shell
./build.sh --part common -m rhel-jenkins-example -t 2.426.1-20231212
./push.sh --part common -m rhel-jenkins-example -t 2.426.1-20231212
./pull.sh --part common -m rhel-jenkins-example -t 2.426.1-20231212
./run.sh --part common -m rhel-jenkins-example -t 2.426.1-20231212
```

### rhel-sd-build
- http://10.174.76.238/
  - ndeploy 연동용 api token : 112dee9a42126c5985c11cf5d5a116a54a
```shell
./build.sh --part common -m rhel-sd-build -t 2.426.1-20240513
./push.sh --part common -m rhel-sd-build -t 2.426.1-20240513
./pull.sh --part common -m rhel-sd-build -t 2.426.1-20240513
./run.sh --part common -m rhel-sd-build -t 2.426.1-20240513
```

