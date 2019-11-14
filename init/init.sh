curl elasticsearch:9200/_cat/health
curl kibana:5601/api/status
curl apmserver:8200

# curl -X POST \
#   http://kibna:5601/api/saved_objects/index-pattern \
#   -H 'Content-Type: application/json' \
#   -H 'kbn-version: 7.4.2' \
#   -d '{"attributes": {"title": "app-service1-*","timeFieldName": "@timestamp","fields": "[]"}}'
# curl -X POST \
#   http://localhost:5601/api/saved_objects/index-pattern \
#   -H 'Content-Type: application/json' \
#   -H 'kbn-version: 7.4.2' \
#   -d '{"attributes": {"title": "app-service2-*","timeFieldName": "@timestamp","fields": "[]"}}'
