FROM php:8.2-apache

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Installer les extensions PHP (PDO pour PostgreSQL inclus)
RUN docker-php-ext-install pdo_pgsql mbstring exif pcntl bcmath gd zip

# Activer mod_rewrite Apache
RUN a2enmod rewrite

# Répertoire de travail
WORKDIR /var/www/html

# DocumentRoot Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copier le projet
COPY . .

# Installer les dépendances PHP sans scripts
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Permissions Laravel
RUN chown -R www-data:www-data storage bootstrap/cache

# Package discovery
RUN php artisan package:discover

# Migrations
RUN php artisan migrate --force

# Exposer port 80
EXPOSE 80

# Lancer Apache
CMD ["apache2-foreground"]
