FROM node:18-alpine

WORKDIR /app

# Copy package files for dependency installation
COPY package*.json ./

# Install dependencies during build (as fallback)
# Volume mount will overwrite /app, but this ensures dependencies are available
RUN npm install --production --no-audit --no-fund || true

# Expose port for Socket.IO
EXPOSE 3000

# Start script: check and install dependencies if needed, then run app
# Volume mount overwrites /app, so we check if node_modules exists
CMD sh -c "if [ ! -d 'node_modules' ] || [ ! -f 'node_modules/moment/package.json' ]; then echo 'Installing dependencies...' && npm install --production --no-audit --no-fund; fi && echo 'Starting Node.js application...' && node main.js"

