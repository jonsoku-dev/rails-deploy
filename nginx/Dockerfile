#FROM nginx
#COPY default.conf /etc/nginx/conf.d/default.conf

FROM nginx:alpine

# インクルード用のディレクトリ内を削除
RUN rm -f /etc/nginx/conf.d/*

# Nginxの設定ファイルをコンテナにコピー
ADD default.conf /etc/nginx/conf.d/myapp.conf

# ビルド完了後にNginxを起動
CMD /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf