# Install CSD validator
```
cd /tmp
git clone https://github.com/cloudera/cm_ext
cd cm_ext/validator
mvn install
```

# Download Elastic Search
```
cd /tmp
mkdir elasticsearch
cd elasticsearch

go to https://www.elastic.co/downloads/elasticsearch
copy link to binary you want to download (with tar.gz extemsion) 
in my case it is: https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.0.0.tar.gz
wget -O elasticsearch-bin.tar.gz "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.0.0.tar.gz"
```
# Dowload build scripts for parcel and CSD
Depending on your OS version please set OS_VER variable acconringly
- RHEL 6
OS_VER=el6
- RHEL 7
OS_VER=el7
- Ubuntu
OS_VER=trusty
```
cd /tmp
git clone http://github.com/prateek/nifi-parcel
cd elasticsearch-parcel
POINT_VERSION=5 VALIDATOR_DIR=/tmp/cm_ext OS_VER=el7 PARCEL_NAME=ElasticSearch ./build-parcel.sh /tmp/elasticsearch/elasticsearch-bin.tar.gz
VALIDATOR_DIR=/tmp/cm_ext CSD_NAME=ElasticSearch ./build-csd.sh
```

# Serve Parcel using Python
```
cd build-parcel
python -m SimpleHTTPServer 14642
# navigate to Cloudera Manager -> Parcels -> Edit Settings
# Add fqdn:14641 to list of urls
# install the ELASTICSEARCH parcel
```

# Move CSD to Cloudera Manager's CSD Repo
```
cd ../
cp build-csd/ELASTICSEARCH-1.0.jar /opt/cloudera/csd
service cloudera-scm-server restart
# Wait a min, go to Cloudera Manager -> Add a Service -> Elastic Search
```
