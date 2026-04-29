FROM debian:bullseye-slim
# Project By Surya..!!!
# Install dependencies 
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    tmux \
    procps \
    nano \
    ca-certificates \
    tar \
    apache2-utils \
    && rm -rf /var/lib/apt/lists/*

# Add Tailscale's official APT repository and install via package manager
RUN curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null && \
    curl -fsSL https://pkgs.tailscale.com/stable/debian/bullseye.tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list && \
    apt-get update && apt-get install -y --no-install-recommends tailscale && \
    rm -rf /var/lib/apt/lists/*

# Download and install AdGuard Home
RUN curl -L -o /tmp/AdGuardHome.tar.gz https://github.com/AdguardTeam/AdGuardHome/releases/latest/download/AdGuardHome_linux_amd64.tar.gz && \
    tar -xvf /tmp/AdGuardHome.tar.gz -C /opt && \
    rm /tmp/AdGuardHome.tar.gz

# Copy custom configuration files
#COPY adlists.txt /adlists.txt
COPY start.sh /custom-start.sh

RUN chmod +x /custom-start.sh

# Expose port 80 so Render can route the web admin dashboard
EXPOSE 80

# Start script
ENTRYPOINT ["/custom-start.sh"]
