# Multi-stage build for smaller image size
FROM python:3.11-slim as builder

WORKDIR /app

# Install dependencies
COPY app/requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Production stage
FROM python:3.11-slim

WORKDIR /app

# Build arguments for versioning
ARG APP_VERSION=1.0.0
ARG BUILD_SHA=local
ARG BUILD_TIME=unknown

# Set environment variables from build args
ENV APP_VERSION=${APP_VERSION}
ENV BUILD_SHA=${BUILD_SHA}
ENV BUILD_TIME=${BUILD_TIME}

# Copy installed packages from builder
COPY --from=builder /root/.local /root/.local

# Make sure scripts in .local are usable
ENV PATH=/root/.local/bin:$PATH

# Copy application code
COPY app/ .

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
