#set( $dollar = '$' )
#set( $hash = '#' )
FROM nginx:1.28-alpine
COPY docs/dev-ops/environment/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY web/dist/ /usr/share/nginx/html/
