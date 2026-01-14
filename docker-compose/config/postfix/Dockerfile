FROM boky/postfix:latest

# Install DNS utilities for SPF/MX lookups (Debian-based image)
USER root
RUN apt-get update && apt-get install -y --no-install-recommends dnsutils && rm -rf /var/lib/apt/lists/*

# Copy wrapper script
COPY wrapper.sh /wrapper.sh
RUN chmod +x /wrapper.sh

# Use wrapper as entrypoint
ENTRYPOINT ["/wrapper.sh"]
