FROM nginx:1.27-alpine

# Replace the default config with ours
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the website
COPY site/ /usr/share/nginx/html/

EXPOSE 80

# Mark the container unhealthy if the web server stops responding
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/health || exit 1
