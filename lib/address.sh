function release.bad.address () {
  # 54.207.8.226 eipalloc-70151f12
  # ADDRESS	54.207.8.226		vpc	eipalloc-70151f12
  ec2-release-address --region sa-east-1 -a eipalloc-70151f12
}

function disassociate.basic.address () {
  # basic 54.207.32.0 i-e03c34f5 vpc eipalloc-34aba156 eipassoc-1e021a7c eni-7c7f7308 10.0.0.73
  ec2-disassociate-address --region sa-east-1 -a eipassoc-1e021a7c
}

function allocate.address () {
  ec2-allocate-address --region sa-east-1 -d vpc
  # ADDRESS	54.207.66.208		vpc	eipalloc-cb594ca9
}

function associate.address () {
  ec2-associate-address --region sa-east-1 -i instance_id -a allocation_id --allow-reassociation
   ec2-associate-address -a eipalloc-5723d13e -i i-4fd2431a 
}
function describe.address () {
  ec2-describe-addresses --region sa-east-1 
  #ec2-describe-addresses --region sa-east-1 54.207.8.226
  #ec2-describe-addresses --region sa-east-1 eipalloc-70151f12
  #ec2-describe-addresses --region sa-east-1 54.207.66.208
}

function show.adresses () {
  echo "
  mapa 54.207.52.211 i-27363b32 vpc eipalloc-2929234b eipassoc-491b052b eni-d2d1d0a6 10.0.0.168
  ready
  ame 54.232.228.143 i-90cef38c vpc eipalloc-e6f8f78f eipassoc-791b051b eni-06f8f76f 10.0.0.212
  basic 54.207.32.0 i-e03c34f5 vpc eipalloc-34aba156 eipassoc-1e021a7c eni-7c7f7308 10.0.0.73
  sp 54.207.47.96 i-f6bcb1e3 vpc eipalloc-6f262c0d eipassoc-14382676 eni-d04a4aa4 10.0.0.21
  "
}

function pipi () {
  while read data
  do
    echo "[$(date +"%D %T")] $data" # >> $logfile
  done
}

function concat () {
  cat
  echo Orbix
}

function concat2 () {
 read N
 echo "$N" Orbix
}











