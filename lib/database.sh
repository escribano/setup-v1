
function populate.db.x {
  createdb -p 5433 -U postgres -E UTF8 -l pt_BR.UTF-8 -T template0 -e gis
  CREATE DATABASE gis ENCODING 'UTF8' TEMPLATE template0 LC_COLLATE 'pt_BR.UTF-8' LC_CTYPE 'pt_BR.UTF-8';

  psql -p 5433 -U postgres -d gis -c "show SERVER_ENCODING;"
  psql -p 5433 -U postgres -d gis -c "show LC_COLLATE;"
  psql -p 5433 -U postgres -d gis -c "show LC_CTYPE;"
  psql -p 5433 -U postgres -d gis -c "CREATE EXTENSION postgis;"
  psql -p 5433 -U postgres -d gis -c "SELECT PostGIS_Version();"
  psql -p 5433 -U postgres -d gis -c "\d"

  psql -p 5433 -U postgres -d gis -f /mnt/ebs/sp/mapa/service/maps/import/sql/metropol_boundary.sql

  psql -p 5433 -U postgres -d gis -f /mnt/ebs/sp/mapa/service/maps/import/sql/island.sql
  psql -p 5433 -U postgres -d gis -f /mnt/ebs/sp/mapa/service/maps/import/sql/wellspring.sql
  psql -p 5433 -U postgres -d gis -f /mnt/ebs/sp/mapa/service/maps/import/sql/tiete_hydrography.sql
  psql -p 5433 -U postgres -d gis -f /mnt/ebs/sp/mapa/service/maps/import/sql/rail_tunnel.sql
  psql -p 5433 -U postgres -d gis -f /mnt/ebs/sp/mapa/service/maps/import/sql/main_highways.sql
  psql -p 5433 -U postgres -d gis -f /mnt/ebs/sp/mapa/service/maps/import/sql/municipal_seats.sql
  psql -p 5433 -U postgres -d gis -f /mnt/ebs/sp/mapa/service/maps/import/sql/main_hydrography.sql	
  psql -p 5433 -U postgres -d gis -f /mnt/ebs/sp/mapa/service/maps/import/sql/simple_hydrography.sql	
  psql -p 5433 -U postgres -d gis -f /mnt/ebs/sp/mapa/service/maps/import/sql/main_contour.sql	
  psql -p 5433 -U postgres -d gis -f /mnt/ebs/sp/mapa/service/maps/import/sql/land_use.sql

  createuser -p 5433 -U postgres -D -R -S -e gis

  psql -p 5433 -U gis
}

