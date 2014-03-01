function _send.this () {
  DIST_DIR="/Users/ademir/dist"
  DIST_SRV=basic.ami
  ARCHIVE_NAME=$1
  FROM_DIR=$2
  export COPY_EXTENDED_ATTRIBUTES_DISABLE=true
  export COPYFILE_DISABLE=true
  #COPYFILE_DISABLE=true
  mkdir -p "$DIST_DIR"
  tar -c --exclude-from=$SETUP_ROOT_PATH/.tarignore -vzf "$DIST_DIR"/$ARCHIVE_NAME.tar.gz -C $FROM_DIR .
  scp $DIST_DIR/$ARCHIVE_NAME.tar.gz $DIST_SRV.mapa.io:/mnt/ebs/data/upload/
}

function data.upload () {
  SERVICE_DIR="/Users/ademir/code/mapa/service"
  SRC_DATA_DIR="$SERVICE_DIR/maps/mapserver/data"
  SRC_IMPORT_DIR="$SERVICE_DIR/maps/import"
  SRC_FONT_DIR="$SERVICE_DIR/maps/mapserver/fonts"
  
  DELAY_DEPLOY=true
  _send.this sql.import $SRC_IMPORT_DIR/sql
  if [ $DELAY_DEPLOY != true ]; then
    _send.this raster.data $SRC_DATA_DIR
    _send.this fonts $SRC_FONT_DIR/
    #_send.this shapefiles $SRC_IMPORT_DIR/shp/
  fi

}

function config.data.dir () {
  mkdir -p /mnt/ebs/data/upload
  chown ademir.ademir /mnt/ebs/data/upload
}

function explode.upload () {
  DELAY_INSTALL=true
  # tar -xf archive.tar -C /target/directory
  rm -rf /mnt/ebs/data/mapa/import/sql
  mkdir -p /mnt/ebs/data/mapa/import/sql
  tar xzvf /mnt/ebs/data/upload/sql.import.tar.gz -C /mnt/ebs/data/mapa/import/sql
  if [ $DELAY_INSTALL != true ]; then
    tar xzvf /mnt/ebs/data/upload/raster.data.tar.gz  -C /mnt/ebs/data/mapa/raster
    tar xzvf /mnt/ebs/data/upload/fonts.tar.gz -C /mnt/ebs/data/mapa/fonts
    #tar xzvf /mnt/ebs/data/upload/shapefiles.tar.gz -C /mnt/ebs/data/mapa/shp
  fi
}

function config.mapa.dir () {
  mkdir /mnt/ebs/mapa/sp
  cd /mnt/ebs/sp
  tar xzvf /mnt/ebs/upload/mapa.tar.gz
  cd mapa
  arg sp
}
