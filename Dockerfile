# Use Node.js Alpine image as base
FROM node:18-alpine

# Install system dependencies
RUN apk add --no-cache python3 py3-pip bash git rust cargo \
    build-base linux-headers openssl-dev \
    libstdc++ libgcc libx11-dev libxkbfile-dev libxrandr-dev libxi-dev \
    libxrender-dev libxcb-dev libxext-dev libxtst-dev \
    dbus-dev libuuid gtk+3.0-dev pango-dev cairo-dev glib-dev

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true
ENV ELECTRON_SKIP_BINARY_DOWNLOAD=1

# Configure Git
RUN git config --global url."https://".insteadOf git:// && \
    git config --global http.postBuffer 1048576000 && \
    git config --global core.compression 0

# Create and activate virtual environment
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Upgrade pip and install wheel
RUN pip install --upgrade pip wheel setuptools

# Clone problematic dependencies manually
RUN git clone --depth 1 https://github.com/bloopai/hyperpolyglot.git /tmp/hyperpolyglot && \
    cd /tmp/hyperpolyglot && \
    cargo build --release

# Install devon_agent
RUN pip install --no-cache-dir devon_agent

# Install Node.js dependencies
COPY package*.json ./
RUN npm install

RUN git clone --depth 1 https://github.com/bloopai/hyperpolyglot.git /tmp/hyperpolyglot && \
    cd /tmp/hyperpolyglot && \
    cargo build --release

# Install Devon UI globally
RUN npm install -g devon-ui electron@latest

# Copy the rest of your application
COPY . .

# Expose port 3000 for the UI
EXPOSE 3000

# Set the entrypoint to devon-ui
ENTRYPOINT ["devon-ui", "--no-sandbox"]