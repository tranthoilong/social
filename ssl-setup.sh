#!/bin/bash

# Script để cấp SSL certificate cho domain goivondautu.delitech.vn
# Sử dụng Let's Encrypt với certbot

DOMAIN="goivondautu.delitech.vn"
EMAIL="admin@delitech.vn"  # Thay đổi email này
NGINX_CONF="docker/nginx/goivondautu.delitech.vn"
SSL_DIR="docker/nginx/ssl/live/$DOMAIN"

# Tạo thư mục cho SSL certificates
mkdir -p docker/nginx/ssl
mkdir -p docker/nginx/certbot

# Kiểm tra xem nginx container có đang chạy không
if ! docker ps | grep -q wowonder-nginx; then
    echo "Nginx container chưa chạy. Đang khởi động..."
    docker compose up -d nginx 2>/dev/null || docker-compose up -d nginx
    sleep 5
fi

# Kiểm tra xem certificate đã tồn tại chưa
if [ -f "$SSL_DIR/fullchain.pem" ] && [ -f "$SSL_DIR/privkey.pem" ]; then
    echo "SSL certificate đã tồn tại."
    enable_https=true
else
    echo "Đang cấp SSL certificate cho domain: $DOMAIN"
    echo "Đảm bảo domain đã trỏ về IP server và port 80 đã mở!"
    
    # Cấp SSL certificate lần đầu
    docker run -it --rm \
        -v "$(pwd)/docker/nginx/certbot:/var/www/certbot" \
        -v "$(pwd)/docker/nginx/ssl:/etc/letsencrypt" \
        certbot/certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email "$EMAIL" \
        --agree-tos \
        --no-eff-email \
        -d "$DOMAIN"
    
    # Kiểm tra kết quả
    if [ $? -ne 0 ]; then
        echo "Có lỗi xảy ra khi cấp SSL certificate."
        echo "Vui lòng kiểm tra:"
        echo "1. Domain đã trỏ về IP server chưa?"
        echo "2. Port 80 đã mở chưa?"
        echo "3. Nginx container đang chạy chưa?"
        exit 1
    fi
    
    enable_https=true
fi

# Enable HTTPS nếu certificate đã có
if [ "$enable_https" = true ] && [ -f "$SSL_DIR/fullchain.pem" ]; then
    echo "Đang enable HTTPS configuration..."
    
    # Kiểm tra xem HTTPS config đã được include chưa
    if ! grep -q "include.*goivondautu.delitech.vn.https" "$NGINX_CONF"; then
        # Thêm redirect HTTP -> HTTPS (thay thế location / hiện tại)
        # Tìm và thay thế location / block
        sed -i '/^    location \/ {/,/^    }$/ {
            /^    location \/ {/ {
                a\
    # Redirect all other traffic to HTTPS
                a\
    location / {
                a\
        return 301 https://$server_name$request_uri;
                a\
    }
                d
            }
            /^    }$/ {
                /location \/ /!d
            }
        }' "$NGINX_CONF"
        
        # Thêm include HTTPS config ở cuối file
        if ! grep -q "include.*goivondautu.delitech.vn.https" "$NGINX_CONF"; then
            echo "" >> "$NGINX_CONF"
            echo "# Include HTTPS configuration" >> "$NGINX_CONF"
            echo "include /etc/nginx/conf.d/goivondautu.delitech.vn.https;" >> "$NGINX_CONF"
        fi
    fi
    
    echo "Đang khởi động lại nginx container..."
    docker compose restart nginx 2>/dev/null || docker-compose restart nginx
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "=========================================="
        echo "Hoàn tất! Website đã được bảo mật với HTTPS."
        echo "Kiểm tra: https://$DOMAIN"
        echo "=========================================="
    else
        echo "Có lỗi khi khởi động lại nginx. Vui lòng kiểm tra lại."
        exit 1
    fi
fi
