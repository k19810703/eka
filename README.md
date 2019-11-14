# 监控报警服务

##  说明
使用elastic search，kibana来构建集中日志管理，apm-server实现应用程序监控，使用elastalert报警。生产环境建议使用cloud vendor的es和kibana服务

##  前提
1.  Docker环境
2.  docker-compose环境
3.  端口3000 3001 5601 8200 9200 9300未被占用
4.  安装好curl

##  启动服务
这里使用docker-compose启动ElasticSearch,kibana,apm-server服务
```Shell
git clone https://github.com/k19810703/eka.git
docker network create ekasample
cd ./eka/monitor-apm-alert
docker-compose up -d
```
kibana启动时间较长，可以通过访问http://localhost:5601 来确认是否启动成功

## 启动sample应用
回到本工程根目录
```Shell
cd ./sampleapp
docker-compose up --build -d
```
发送http请求
```Shell
curl http://localhost:3000/healthcheck
curl http://localhost:3000/apmtest
curl http://localhost:3000/errortest
```

## log服务
1.  打开kibana http://localhost:5601
2.  左边栏=>Management=>Index Patterns=>Create index pattern=>Index pattern: app-service1-* =>Next step=>Time Filter field name: @timestamp=>Create index pattern,同理创建app-service2-*
3.  左边栏=>Discover=>左边下拉框选择app-service1-* 或者 app-service2-* 来查看log
4.  就可以看到samleapp的log了，本例用的node.js的express框架，使用winston作为log组件，其他语言也有类似的log模块直接输出到elastic search
5.  如果log输出到文件，可以参考elastic的filebeat组件

##  apm服务
1.  打开kibana http://localhost:5601
2.  左边栏=>APM
3.  自行探索或参考官网文档

## 监控服务
监控服务有很多中类型的监控，主要是拉取es的数据进行分析。这里的sample是监控sample应用程序是否有响应(心跳检查)
1.  [安装heartbeat](https://www.elastic.co/guide/en/beats/heartbeat/current/heartbeat-installation.html)
2.  配置heartbeat,配置文件参考./heartbeat/heartbeat.yml
3.  [导入heartbeat的dashboard](https://github.com/elastic/uptime-contrib)，导入所需json文件可以在./heartbeat/下找到
4.  [启动heartbeat](https://www.elastic.co/guide/en/beats/heartbeat/current/heartbeat-starting.html)
启动前先确认sample应用程序在线
5.  打开kibana http://localhost:5601
6.  左边栏=>Discover=>左边下拉框选择heartbeat-*

##  数据库监控
1.  启动sample数据库
```SHELL
docker run --network ekasample -p 3306:3306 --name mysql --env MYSQL_RANDOM_ROOT_PASSWORD=yes -d mysql:5.7
```

2.  稍等片刻等待mysql完全启动成功后设置并启动metricbeat
```SHELL
# 获取mysql的密码，设置到环境变量mysqlpass
export mysqlpass=$(docker logs mysql 2>1 | grep PASSWORD | awk '{print $4}')
# 获取mysql的密码
echo ＄mysqlpass
# 设置dashboard
docker run -e MYSQL_PASSWORD=${mysqlpass} \
  --network ekasample \
  --rm \
  --user=root \
  --volume="$(pwd)/monitor-apm-alert/metricbeat.docker.yml:/usr/share/metricbeat/metricbeat.yml:ro" \
  --volume="/var/run/docker.sock:/var/run/docker.sock:ro" \
  --volume="/sys/fs/cgroup:/hostfs/sys/fs/cgroup:ro" \
  --volume="/proc:/hostfs/proc:ro" \
  --volume="/:/hostfs:ro" \
  docker.elastic.co/beats/metricbeat:7.4.2 metricbeat setup --dashboards
# 启动metricbeat
docker run -d -e MYSQL_PASSWORD=${mysqlpass} \
  --network ekasample \
  --name=metricbeat \
  --user=root \
  --volume="$(pwd)/monitor-apm-alert/metricbeat.docker.yml:/usr/share/metricbeat/metricbeat.yml:ro" \
  --volume="/var/run/docker.sock:/var/run/docker.sock:ro" \
  --volume="/sys/fs/cgroup:/hostfs/sys/fs/cgroup:ro" \
  --volume="/proc:/hostfs/proc:ro" \
  --volume="/:/hostfs:ro" \
  docker.elastic.co/beats/metricbeat:7.4.2 metricbeat -e \
  -E output.elasticsearch.hosts=elasticsearch:9200
```

3.  通过数据库管理工具连接上mysql后做一些sql操作
4.  打开kibana http://localhost:5601
5.  左边栏=>Dashboard
6.  搜索mysql
7.  点击[Metricbeat MySQL] Overview ECS


##  报警服务

### 参考
[elasalert](https://elastalert.readthedocs.io/en/latest/running_elastalert.html)

### 启动报警服务
修改配置文件./alert/example_frequency.yaml
1.  48行 改为可用的smtp服务器地址
2.  57行 改为可用的email地址

build报警服务image(由于我本机的python是３.7版本，跟这个工具不兼容，使用docker创建python ３.6.4环境)
```SHELL
cd alert
docker build -t elastalert .
```

配置es的index
```SHELL
docker run -it --rm \
  --network monitor-apm-alert_default \
  --link elasticsearch:elasticsearch \
  --link kibana:kibana\
  --link apmserver:apmserver \
  elastalert-create-index
```

启动报警服务(根目录下执行)
```SHELL
docker run -it --rm \
  --network monitor-apm-alert_default \
  --link elasticsearch:elasticsearch \
  --link kibana:kibana\
  --link apmserver:apmserver \
  -v $(pwd)/alert:/usr/src \
  elastalert python -m elastalert.elastalert --verbose --config config.yaml --rule example_frequency.yaml 
```

测试报警功能， 停掉sample应用程序，过一会你会收到邮件警报，email以外也能配置slack报警

### 答疑解惑
wuhd@cn.ibm.com
