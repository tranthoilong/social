FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY goivondautu.delitech.vn /etc/nginx/conf.d/goivondautu.delitech.vn.conf
COPY rewrites.inc /etc/nginx/conf.d/rewrites.inc

# Create log directory
RUN mkdir -p /var/log/nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

