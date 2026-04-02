# Base image - we're building on top of official Nginx
FROM nginx:latest

# Who made this image
LABEL maintainer="bv344"

# Copy our custom HTML into the container's web root
COPY index.html /usr/share/nginx/html/index.html
