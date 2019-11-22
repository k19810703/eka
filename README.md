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
```SHELL
git clone https://github.com/k19810703/eka.git
# 创建网络 仅需一次
docker network create ekasample
#修改配置文件./alert/example_frequency.yaml
#1.  48行 改为可用的smtp服务器地址
#2.  57行 改为可用的email地址
cd ./eka
# 打包启动
docker-compose up --build -d
# 查看初始化进程log，以下命令退出后说明启动成功
docker logs -f initjob
```

服务较多，整体启动需要花个几分钟

### 启动内容说明
  1.  启动了elasticsearch，kibana，apm-server服务
  2.  启动了sample-service1,sample-service2 2个api服务
  3.  启动了mysql服务
  4.  启动了heartbeat服务监控sample-service1,sample-service2是否在线
  5.  启动了metricbeat服务监控mysql
  6.  在elasticsearch和kibana上做了heartbeat的初始化
  7.  在elasticsearch和kibana上做了metricbeat的初始化
  8.  在elasticsearch上做了elastalert的初始化,并启动监控

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
  由于各个服务启动有先后顺序，所以elasticsearch应该已经会有服务不在线的记录并被监控程序捕获并发出邮件通知
  注：监控程序需要python3.6环境，3.7+并不能正常运行

##  清理
  ```SHELL
  docker-compose rm -s -f -v
  ```

## 答疑解惑
wuhd@cn.ibm.com
