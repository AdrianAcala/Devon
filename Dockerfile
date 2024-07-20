# Use Alpine Linux with Node.js and Python
FROM node:18-alpine

# Install system dependencies including build tools, C++ compiler, Git, and OpenSSL
RUN apk add --no-cache python3 py3-pip bash git rust cargo \
    build-base linux-headers openssl-dev

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

# Configure Git to use HTTPS instead of git protocol and increase buffer size
# RUN git config --global url."https://".insteadOf git:// && \
#     git config --global http.postBuffer 1048576000 && \
#     git config --global core.compression 0

# Create and activate virtual environment
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Upgrade pip and install wheel
RUN pip install --upgrade pip wheel setuptools

# Clone and install tree-sitter dependencies manually
RUN git clone --depth 1 https://github.com/tree-sitter/tree-sitter-cpp.git && \
    git clone --depth 1 https://github.com/tree-sitter/tree-sitter-python.git && \
    git clone --depth 1 https://github.com/tree-sitter/tree-sitter-javascript.git && \
    git clone --depth 1 https://github.com/BloopAI/tree-sitter-cobol.git

# Install devon_agent
RUN pip install --no-cache-dir devon_agent

# Copy the rest of your application
COPY . .

# Install Node.js dependencies if package.json exists
RUN if [ -f package.json ]; then npm install; fi

# Install Devon UI globally
RUN npm install -g devon-ui

# Expose port 3000 for the UI
EXPOSE 3000

# Set the entrypoint to devon-ui
ENTRYPOINT ["devon-ui"]