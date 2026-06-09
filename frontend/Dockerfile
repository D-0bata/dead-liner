# ============================================
# Stage 1: Dependencies Installation Stage
# ============================================

# Specify a parent image
FROM node:26.3.0-alpine3.23

# Set working directory
WORKDIR /app

# Copy package.json package-lock.json
COPY ./package*.json ./

# Install project dependencies
RUN npm ci --no-audit --no-fund


# ============================================
# Stage 2: Build Next.js application
# ============================================

# Copy application source code
COPY ./ ./

# Build Next.js application
RUN npm run build

# Install Next.js server
RUN npm install -g next


# ============================================
# Stage 3: Run Next.js application
# ============================================

# Expose port 3000 to allow HTTP traffic
EXPOSE 3000

# Start Next.js server
CMD ["next", "start", "-p", "3000"]
