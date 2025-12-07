# -------------------------------
# Stage 1: Builder (Composer + dependencies)
# -------------------------------
FROM php:8.2-fpm AS builder

# Installer les dépendances système nécessaires
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Installer les extensions PHP nécessaires
RUN docker-php-ext-install pdo_pgsql pdo_mysql mbstring exif pcntl bcmath gd zip

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Définir le répertoire de travail
WORKDIR /app

# Copier composer.json et composer.lock pour cache Docker
COPY composer.json composer.lock ./

# Installer les dépendances PHP
RUN composer install --no-dev --optimize-autoloader

# Copier le reste du projet
COPY . .

# -------------------------------
# Stage 2: Production (Nginx + PHP-FPM)
# -------------------------------
FROM nginx:alpine

# Installer PHP-FPM et extensions nécessaires
RUN apk add --no-cache php82 php82-fpm php82-pdo_pgsql php82-pdo_mysql php82-mbstring \
    php82-xml php82-bcmath php82-zip php82-gd php82-opcache

# Copier le code + vendor depuis le builder
COPY --from=builder /app /var/www/html

# Configurer les permissions Laravel
RUN chown -R nginx:nginx /var/www/html/storage /var/www/html/bootstrap/cache

# Copier la configuration Nginx
COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Définir le répertoire de travail
WORKDIR /var/www/html

# Artisan optimizations
RUN php artisan config:cache
RUN php artisan route:cache
RUN php artisan view:cache

# Exposer le port
EXPOSE 80

# Démarrer Nginx et PHP-FPM
CMD ["sh", "-c", "php-fpm8 && nginx -g 'daemon off;'"]
