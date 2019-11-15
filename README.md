# 监控报警服务

##  说明
使用elastic search，kibana来构建集中日志管理，apm-server实现应用程序监控，使用elastalert报警。生产环境建议使用cloud vendor的es和kibana服务

##  前提
1.  Docker环境
2.  docker-compose环境
3.  端口3000 3001 3306 5601 8200 9200 9300未被占用
4.  安装好curl

##  启动服务

### 启动方法
打开终端后以此输入以下命令
```Shell
git clone https://github.com/k19810703/eka.git
docker network create ekasample
cd ./eka
# 打包启动
docker-compose up --build -d
# 查看初始化进程log，以下命令退出后说明启动成功
docker logs -f initjob
# 获取mysql的密码，设置到环境变量mysqlpass
export mysqlpass=$(docker logs sampledb 2>1 | grep PASSWORD | awk '{print $4}')
# 获取mysql的密码
echo $mysqlpass
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

服务较多，整体启动需要花个几分钟

### 启动内容说明
1.  启动了elasticsearch，kibana，apm-server服务
2.  启动了sample-service1,sample-service2 2个api服务
3.  启动了mysql服务
4.  启动了heartbeat服务监控sample-service1,sample-service2是否在线
5.  在elasticsearch和kibana上做了heartbeat的初始化
6.  在elasticsearch和kibana上做了metricbeat的初始化

## log服务
1.  打开kibana http://localhost:5601
2.  左边栏=>Discover=>左边下拉框选择app-service1-* 或者 app-service2-* 来查看log
4.  就可以看到samleapp的log了，本例用的node.js的express框架，使用winston作为log组件，其他语言也有类似的log模块直接输出到elastic search
5.  如果log输出到文件，可以参考elastic的filebeat组件

##  apm服务
1.  打开kibana http://localhost:5601
2.  左边栏=>APM
3.  自行探索或参考官网文档

## 监控服务
1.  打开kibana http://localhost:5601
2.  左边栏=>Discover=>左边下拉框选择heartbeat-*
3.  左边栏=>Dashboard=>搜索heartbeat，并打开出现的那条记录

##  数据库监控
1.  通过数据库管理工具连接上mysql后做一些sql操作以生成一些监控数据
2.  打开kibana http://localhost:5601
3.  左边栏=>Dashboard
4.  搜索mysql
5.  点击[Metricbeat MySQL] Overview ECS


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
  --network ekasample \
  --link elasticsearch:elasticsearch \
  --link kibana:kibana\
  --link apmserver:apmserver \
  elastalert-create-index
```

启动报警服务(根目录下执行)
```SHELL
docker run -it --rm \
  --network ekasample \
  --link elasticsearch:elasticsearch \
  --link kibana:kibana\
  --link apmserver:apmserver \
  -v $(pwd)/alert:/usr/src \
  elastalert python -m elastalert.elastalert --verbose --config config.yaml --rule example_frequency.yaml 
```

测试报警功能， 停掉sample应用程序，过一会你会收到邮件警报，email以外也能配置slack报警

##  清理
```SHELL
docker-compose rm -s -f -v
```

### 答疑解惑
wuhd@cn.ibm.com
