# 监控报警服务

##  说明
使用elastic search，kibana来构建集中日志管理，apm-server实现应用程序监控，使用elastalert报警

##  前提
1.  Docker环境
2.  docker-compose
3.  node.js环境(sample程序)
##  启动服务
```Shell
git clone https://github.com/k19810703/eka.git
cd ./eka/monitor-apm-alert
docker-compose up -d
```

## 启动sample应用
回到本工程根目录
```Shell
npm install
node ./sampleapp/app.js
```
发一个请求请求
```Shell
curl http://localhost:3000/test
```

## log服务
1.  打开kibana http://localhost:5601
2.  左边栏=>Management=>Index Patterns=>Create index pattern=>Index pattern: testapp-* =>Next step=>Time Filter field name: @timestamp=>Create index pattern
3.  左边栏=>Discover=>左边下拉框选择testapp-*
4.  就可以看到samleapp的log了，本例用的node.js的express框架，使用winston作为log组件，其他语言也有类似的log模块直接输出到elastic search
5.  如果log输出到文件，可以参考elastic的filebeat组件

##  apm服务
1.  打开kibana http://localhost:5601
2.  左边栏=>APM
3.  自行探索或参考官网文档

## 监控服务
1.  [安装heartbeat](https://www.elastic.co/guide/en/beats/heartbeat/current/heartbeat-installation.html)
2.  配置heartbeat,配置文件参考./heartbeat/heartbeat.yml
3.  [导入heartbeat的dashboard](https://github.com/elastic/uptime-contrib)
4.  [启动heartbeat](https://www.elastic.co/guide/en/beats/heartbeat/current/heartbeat-starting.html)
启动前先确认sample应用程序在线

##  报警服务

### 参考
[getstart](https://elastalert.readthedocs.io/en/latest/running_elastalert.html)

### 启动报警服务
修改配置文件./alert/example_frequency.yaml
1.  48行 改为可用的smtp服务器地址
2.  改为可用的email地址

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
