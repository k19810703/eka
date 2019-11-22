elastalert-create-index
if (( "$? != 0" ))
then
  exit 1
fi
python -m elastalert.elastalert --verbose --config config.yaml --rule example_frequency.yaml
