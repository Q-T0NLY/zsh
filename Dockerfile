# ============================================================================
# Dockerfile for NEXUS ZSH Platform
# Production-ready containerized environment
# ============================================================================

FROM ubuntu:22.04

LABEL maintainer="NEXUS Platform Team"
LABEL description="NEXUS ZSH Configuration Platform"
LABEL version="4.1.0"

# ============================================================================
# Environment Configuration
# ============================================================================

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm-256color \
    SHELL=/usr/bin/zsh \
    NEXUS_HOME=/opt/nexus \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# ============================================================================
# System Dependencies
# ============================================================================

RUN apt-get update && apt-get install -y \
    # Core utilities
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    # Shell and terminal
    zsh \
    tmux \
    # Build essentials
    build-essential \
    pkg-config \
    # Python
    python3.11 \
    python3-pip \
    python3-dev \
    # Network tools
    net-tools \
    iputils-ping \
    dnsutils \
    # Monitoring
    sysstat \
    # Locale
    locales \
    && locale-gen en_US.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# Python Dependencies
# ============================================================================

COPY requirements-test.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir -r /tmp/requirements.txt || true && \
    rm /tmp/requirements.txt

# ============================================================================
# Application Setup
# ============================================================================

WORKDIR ${NEXUS_HOME}

# Copy application files
COPY . ${NEXUS_HOME}/

# Make scripts executable
RUN chmod +x ${NEXUS_HOME}/*.sh && \
    chmod +x ${NEXUS_HOME}/*.py || true

# ============================================================================
# ZSH Configuration
# ============================================================================

# Set ZSH as default shell
RUN chsh -s /usr/bin/zsh root

# Create necessary directories
RUN mkdir -p \
    ${NEXUS_HOME}/logs \
    ${NEXUS_HOME}/cache \
    ${NEXUS_HOME}/data \
    /root/.config/ultra-zsh

# ============================================================================
# Health Check
# ============================================================================

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# ============================================================================
# Expose Ports
# ============================================================================

EXPOSE 8000 5000 3000

# ============================================================================
# Entry Point
# ============================================================================

ENTRYPOINT ["/usr/bin/zsh"]
CMD ["-l"]
