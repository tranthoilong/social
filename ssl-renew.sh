#!/bin/bash

# Script để gia hạn SSL certificate tự động
# Nên chạy script này qua cron job mỗi tháng một lần

DOMAIN="goivondautu.delitech.vn"

echo "Đang kiểm tra và gia hạn SSL certificate cho domain: $DOMAIN"

# Gia hạn certificate
docker run -it --rm \
    -v "$(pwd)/docker/nginx/certbot:/var/www/certbot" \
    -v "$(pwd)/docker/nginx/ssl:/etc/letsencrypt" \
    certbot/certbot renew

# Kiểm tra kết quả
if [ $? -eq 0 ]; then
    echo "Đang khởi động lại nginx container để áp dụng certificate mới..."
    docker-compose restart nginx
    echo "Gia hạn SSL certificate thành công!"
else
    echo "Có lỗi xảy ra khi gia hạn SSL certificate."
    exit 1
fi

