# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

WORKDIR /app
COPY . .

# Fetch packages
RUN flutter pub get

# Build web using the BACKEND_URL argument passed from Railway
ARG BACKEND_URL
RUN flutter build web --release --dart-define=BACKEND_URL=${BACKEND_URL}

# Stage 2: Serve using Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
