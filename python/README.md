For simplicity, checkout the python client into this directory:
```
cd python
git clone https://gitlab.unimelb.edu.au/resplat-mediaflux/python-mfclient.git
mv python-mfclient mfclient
```

And then the example should run if appropriate envvars are provided:
```
MF_HOST=... MF_DOMAIN=... MF_USERNAME=... MF_PASSWORD=... \
PYTHONPATH=python-mfclient/src/:$PYTHONPATH \
./example.py
```
