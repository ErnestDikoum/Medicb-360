# Stage 1: Builder (Composer + dependencies)
FROM php:8.2-cli AS builder

# Installer les dépendances système nécessaires pour Laravel
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

# Copier uniquement le fichier composer.json et composer.lock pour le cache
COPY composer.json composer.lock ./

# Installer les dépendances PHP
RUN composer install --no-dev --optimize-autoloader

# Copier le reste du projet
COPY . .

# Stage 2: Production image
FROM php:8.2-apache

# Installer les extensions nécessaires (peut être réduit selon besoin)
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install pdo_pgsql pdo_mysql mbstring exif pcntl bcmath gd zip \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Définir le DocumentRoot sur le dossier public de Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# Copier uniquement le code + vendor depuis le builder
COPY --from=builder /app /var/www/html

# Permissions Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Artisan optimizations
RUN php /var/www/html/artisan config:cache
RUN php /var/www/html/artisan route:cache
RUN php /var/www/html/artisan view:cache

# Exposer le port
EXPOSE 80

# Lancer Apache
CMD ["apache2-foreground"]
