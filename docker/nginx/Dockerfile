FROM nginx:1.17.3

RUN mkdir -p /usr/share/nginx/public

COPY ./docker/nginx/nginx.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]