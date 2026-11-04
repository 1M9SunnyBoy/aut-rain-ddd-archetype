#set( $dollar = '$' )
#set( $hash = '#' )
${hash} description: 封装前端静态产物与 Nginx 代理配置。
${hash} author: zzy
${hash} created: 2026-10-19
FROM nginx:1.28-alpine
COPY docs/dev-ops/environment/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY web/dist/ /usr/share/nginx/html/
