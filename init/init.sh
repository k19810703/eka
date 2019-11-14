curl -X POST \
  http://localhost:5601/api/saved_objects/index-pattern \
  -H 'Content-Type: application/json' \
  -H 'kbn-version: 7.4.2' \
  -d '{"attributes": {"title": "app-service1-*","timeFieldName": "@timestamp","fields": "[]"}}'
curl -X POST \
  http://localhost:5601/api/saved_objects/index-pattern \
  -H 'Content-Type: application/json' \
  -H 'kbn-version: 7.4.2' \
  -d '{"attributes": {"title": "app-service2-*","timeFieldName": "@timestamp","fields": "[]"}}'
