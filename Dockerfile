FROM ubuntu:22.04

# Install Harbour and dependencies
RUN apt-get update && apt-get install -y \
    harbour \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy source files
COPY bike_rental.prg /app/
COPY bike_rental.hbp /app/

# Compile
RUN hbmk2 bike_rental.hbp

# Keep container running for inspection
CMD ["bash"]
