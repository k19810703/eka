waitReady(){
  retry=1
  echo "wait url($1) ready"
  curl $1 2>/dev/null
  while (( "$? != 0" ))
  do
    if [ "$retry" -gt 30 ]
    then
      echo "retry more than 30 times , terminated"
      exit 1;
    fi
    sleep 5s
    echo "sleep 5s and retry $1 for count:$retry"
    let "retry++"
    curl $1
  done
}
waitReady elasticsearch:9200/_cat/health
waitReady apmserver:8200
node app.js
