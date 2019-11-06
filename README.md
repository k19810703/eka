# 监控报警服务

##  说明
使用elastic search，kibana来构建集中日志管理，apm-server实现应用程序监控，使用elastalert报警

##  前提
1 Docker环境
2 docker-compose
3 node.js环境(sample程序)
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
1 打开kibana http://localhost:5601
2 左边栏=>Management=>Index Patterns=>Create index pattern=>Index pattern: testapp-* =>Next step=>Time Filter field name: @timestamp=>Create index pattern
3 左边栏=>Discover=>左边下拉框选择testapp-*
4 就可以看到samleapp的log了，本例用的node.js的express框架，使用winston作为log组件，其他语言也有类似的log模块直接输出到elastic search
5 如果log输出到文件，可以参考elastic的filebeat组件

##  apm服务
1 打开kibana http://localhost:5601
2 左边栏=>APM
3 自行探索或参考官网文档

## 监控服务


