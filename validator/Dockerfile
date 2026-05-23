FROM ghcr.io/puppeteer/puppeteer:24.3.1

# The base image runs as the unprivileged `pptruser` and ships Chromium with
# the sandbox enabled. Do not override USER below.

WORKDIR /home/pptruser/app

# Use the bundled Chromium that's already installed in the image.
ENV PUPPETEER_SKIP_DOWNLOAD=true

COPY --chown=pptruser:pptruser package.json package-lock.json* ./
RUN npm install --omit=dev

COPY --chown=pptruser:pptruser server.js ./

EXPOSE 3000

CMD ["node", "server.js"]
