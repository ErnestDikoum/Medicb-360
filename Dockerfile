FROM php:8.2-apache

# Dépendances système
RUN apt-get update && apt-get install -y \
    libpng-dev libonig-dev libxml2-dev libzip-dev unzip git curl \
    && rm -rf /var/lib/apt/lists/*

# Extensions PHP
RUN docker-php-ext-install pdo_pgsql mbstring exif pcntl bcmath gd zip

# Apache mod_rewrite
RUN a2enmod rewrite

# DocumentRoot vers Laravel public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# Travail dans le dossier Laravel
WORKDIR /var/www/html

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copier les fichiers projet
COPY . .

# Installer dépendances PHP
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Permissions
RUN chown -R www-data:www-data storage bootstrap/cache

# Optimisations Laravel
RUN php artisan config:cache
RUN php artisan route:cache
RUN php artisan view:cache

# Exposer le port Render
ENV PORT 10000
EXPOSE $PORT

# Commande de démarrage
CMD ["apache2-foreground"]
