FROM boky/postfix:latest

# Install DNS utilities for SPF/MX lookups
USER root
RUN apk add --no-cache bind-tools

# Copy wrapper script
COPY wrapper.sh /wrapper.sh
RUN chmod +x /wrapper.sh

# Use wrapper as entrypoint
ENTRYPOINT ["/wrapper.sh"]
