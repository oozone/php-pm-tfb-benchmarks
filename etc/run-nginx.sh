#!/bin/bash

ip route show

trapIt () { "$@"& pid="$!"; trap "kill -INT $pid" INT TERM; while kill -0 $pid > /dev/null 2>&1; do wait $pid; ec="$?"; done; exit $ec;};

STATIC=/var/www/
args=" $@ "
if [[ ! $args =~ " --help " ]]; then
  ARG_STATIC=`/ppm/vendor/bin/ppm config --show-option="static-directory" "$@"`
fi

[ ! -z "$ARG_STATIC" ] && STATIC="${STATIC}${ARG_STATIC}"
sed -i "s#STATIC_DIRECTORY#${STATIC}#g" /etc/nginx/sites-enabled/default

nginx

mkdir -p /ppm/run
chmod -R 777 /ppm/run
ARGS='--port=8081 --bootstrap=laravel --socket-path=/ppm/run --pidfile=/ppm/ppm.pid --max-requests=100000 --workers=5 --app-env=prod --debug=0 --logging=1'

# make sure static-directory is not served by php-pm
ARGS="$ARGS --static-directory=''"

trapIt /ppm/vendor/bin/ppm start --ansi $ARGS $@