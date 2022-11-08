PROJECT="fastapi_nginx_hw_kion_app"
scale_factor=5
app_name=app
echo Start deploy!


reload_nginx() {
  docker exec nginx nginx -s reload
}

zero_downtime_deploy() {

  old_containers_id=$(docker ps -f name=$PROJECT -q | tail -n$scale_factor)
  echo $old_containers_id
  # TODo: add checks for count

  # bring a new container online, running new code
  # (nginx continues routing to the old container only)
  docker-compose up -d --no-deps --scale $app_name=$scale_factor --no-recreate $app_name

  # wait for new container to be available
  new_containers_id=$(docker ps -f name=$app_name -q | head -n$scale_factor)
#  echo $new_containers_id
  sleep 30

  for new_cont in $new_containers_id
  do
    new_container_ip=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $new_cont)
    echo Connecting to container $new_cont with IPAddress $new_container_ip
#    curl --silent --include --retry-connrefused --retry 10 --retry-delay 1 --fail http://$new_container_ip:8000/ || exit 1
  done


  # start routing requests to the new container (as well as the old)
  echo reloading nginx...
  reload_nginx

  echo stopping and removing old containers...
  IFS=$'\n' read -rd '' -a old_container_id_l <<<"$old_containers_id"
  for i in $old_container_id_l
  do
    echo stopping $i
    docker stop $i
    echo stopped container $i
    docker rm $i
    echo removed container $i
  done


#  docker-compose up -d --no-deps --scale $service_name=1 --no-recreate $service_name

#   stop routing requests to the old container
  reload_nginx
}


#imageID=$(docker images --format {{.ID}} --filter=reference=$PROJECT)

function build() {
   docker image build ./app/ -t $PROJECT\:latest
}

zero_downtime_deploy