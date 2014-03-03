
function install.basic.libs {
  apt-get update && apt-get upgrade -y
  apt-get install build-essential curl git -y
}

function install.more.libs {
  apt-get update && apt-get upgrade -y
  apt-get install autoconf automake cmake nmap xfsprogs unzip  -y
  apt-get install subversion gettext checkinstall chkconfig openssl libssl-dev  -y
  apt-get install python python-pip python-virtualenv -y
  apt-get install proj-bin proj-data proj-ps-doc libproj-dev libgeos-c1 -y
  apt-get install postgresql-9.3-postgis-2.1 postgresql-9.3-plv8 postgresql-contrib-9.3 libpq-dev -y
  apt-get install gdal-bin libgdal-dev libgdal-doc dans-gdal-scripts libgd-tools shapelib -y
  apt-get install mapserver-bin cgi-mapserver mapserver-doc libmapserver1-dev -y
  apt-get install python-mapscript ruby-mapscript libmapscript-perl php5-mapscript -y
  apt-get install libmapcache1 libmapcache1-dev mapcache-cgi mapcache-tools -y
  apt-get install nginx geoip-bin spawn-fcgi libfcgi-dev -y
  # phantomjs, imagemagick
}

# apt-get install build-essential python openssl libssl-dev curl
# apt-get install python g++ make checkinstall