waitReady(){
  retry=1
  echo "wait url($1) ready"
  curl $1 2>/dev/null
  while (( "$? != 0" ))
  do
    if [ "$retry" -gt 15 ]
    then
      echo "retry more than 10 times , terminated"
      exit 1;
    fi
    sleep 5s
    echo "sleep 5s and retry $1 for count:$retry"
    let "retry++"
    curl $1
  done
}

waitKibanaReady(){
  retry=1
  echo "wait url($1) ready"
  expectState=green
  goon=1
  curl $1 2>/dev/null > ~/result.json
  curlrc=$?
  while (("$goon != 0"))
  do
    if [ "$retry" -gt 15 ]
    then
      echo "retry more than 10 times , terminated"
      exit 1;
    fi
    if [ "$curlrc" -eq 0 ]
    then
      echo "curl ok"
      kibanastate=$(cat ~/result.json | jq .status.overall.state)
      echo "kibanastate $kibanastate"
      kibanastate=${kibanastate//\"}
      echo "kibanastate $kibanastate"
      if [ $kibanastate = $expectState ];
      then
        echo "kibana ready"
        goon=1
        return 0
      fi
    fi
    sleep 5s
    echo "sleep 5s and retry $1 for count:$retry"
    let "retry++"
    curl $1 2>/dev/null > ~/result.json
    curlrc=$?
  done
  echo "kibana ready"
}

waitKibanaReady kibana:5601/api/status
waitReady elasticsearch:9200/_cat/health
waitReady apmserver:8200

curl -X POST \
  http://kibana:5601/api/saved_objects/index-pattern \
  -H 'Content-Type: application/json' \
  -H 'kbn-xsrf: true' \
  -d '{"attributes": {"title": "app-service1-*","timeFieldName": "@timestamp","fields": "[]"}}'
curl -X POST \
  http://kibana:5601/api/saved_objects/index-pattern \
  -H 'Content-Type: application/json' \
  -H 'kbn-xsrf: true' \
  -d '{"attributes": {"title": "app-service2-*","timeFieldName": "@timestamp","fields": "[]"}}'
curl -X POST "kibana:5601/api/saved_objects/_import" -H "kbn-xsrf: true" --form file=@export.ndjson
waitReady service1:3000/healthcheck
waitReady service2:3000/healthcheck
curl http://service1:3000/healthcheck
curl http://service1:3000/apmtest
curl http://service1:3000/errortest
