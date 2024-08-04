# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/

# Want to help us make this template better? Share your feedback here: https://forms.gle/ybq9Krt8jtBL3iCk7

ARG NODE_VERSION=20.15.1

FROM node:${NODE_VERSION}-alpine as base

# Création du repertoire de travail docker.
WORKDIR /app

# Expose the port that the application listens on.
EXPOSE 3000

# Run the application as a non-root user.
USER root

# Copie des fichiers de package pour installer les dépendances.
COPY package.json package-lock.json ./

# Use production node environment by default.
#ENV NODE_ENV production

# Configuration pour developpement
FROM base as dev
# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.npm to speed up subsequent builds.
# Leverage a bind mounts to package.json and package-lock.json to avoid having to copy them into
# into this layer.
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm  \
    #Installer les depedances avec dev dépendances
    npm ci --incude=dev

# Copy the rest of the source files into the image.
COPY . .

# Run the application dev.
CMD npm run dev

# Configuration pour prod
FROM base as prod

RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm  \
    #Installer les depedances sans dev dépendances
    npm ci --omit=dev --unsafe-perm=true

# Copy the rest of the source files into the image.
COPY . .

# Run the application.
CMD ["node", "src/index.js"]

