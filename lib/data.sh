
function data.upload () {
  SRC_DATA_DIR="/Users/ademir/code/mapa/service/maps/mapserver/data"
  SRC_IMPORT_DIR="/Users/ademir/code/mapa/service/maps/import"
  SRC_FONT_DIR="/Users/ademir/code/mapa/service/maps/mapserver/fonts"
  DIST_DIR="/Users/ademir/dist"
  DIST_SRV=basic.ami
  
  #echo "$SRC_DATA_DIR"
	#rm -f $(DIST_DIR)/data/import.tar.gz
	mkdir -p "$DIST_DIR"
  
  COPYFILE_DISABLE=true 
  tar -c --exclude-from=$SETUP_ROOT_PATH/.tarignore -vzf "$DIST_DIR"/barueri-image.tar.gz -C "$SRC_DATA_DIR" .
  
  #tar --exclude='.DS_Store' --exclude='.git' -czvf "$DIST_DIR"/barueri-image.tar.gz -C "$SRC_DATA_DIR" .
  scp $DIST_DIR/barueri-image.tar.gz $DIST_SRV:/mnt/ebs/data/upload/
  return
  tar cvzf $(DIST_DIR)/barueri-image.tar.gz $(SRC_DATA_DIR)/
  tar cvzf $(DIST_DIR)/dem.tar.gz $(SRC_DATA_DIR)/dem/spd.tif
  tar cvzf $(DIST_DIR)/import-shp.tar.gz $(SRC_IMPORT_DIR)/shp/
  tar cvzf $(DIST_DIR)/import-sql.tar.gz $(SRC_IMPORT_DIR)/sql/
  tar cvzf $(DIST_DIR)/fonts.tar.gz $(SRC_FONT_DIR)/
  
  scp $(DIST_DIR)/dem.tar.gz $(DIST_SRV):/mnt/ebs/upload/
  scp $(DIST_DIR)/barueri-image.tar.gz $(DIST_SRV):/mnt/ebs/upload/
  tar cvzf $(DIST_DIR)/shape-sql.tar.gz $(IMPORT_DIR)/
  scp $(DIST_DIR)/import.tar.gz $(DIST_SRV):/mnt/ebs/upload/
  scp $(DIST_DIR)/fonts.tar.gz $(DIST_SRV):/mnt/ebs/upload/
}

function config.data.dir () {
  mkdir -p /mnt/ebs/data/upload
  chown ademir.ademir /mnt/ebs/data/upload
}

function explode.upload () {
  tar xzvf /mnt/ebs/upload/prod.tar.gz
  tar xzvf /mnt/ebs/upload/barueri-image.tar.gz
  tar xzvf /mnt/ebs/upload/import.tar.gz
  tar xzvf /mnt/ebs/upload/dem.tar.gz
}

function config.mapa.dir () {
  mkdir /mnt/ebs/mapa/sp
  cd /mnt/ebs/sp
  tar xzvf /mnt/ebs/upload/mapa.tar.gz
  cd mapa
  arg sp
}
