# ---------- Base image PHP avec Apache ----------
FROM php:8.2-apache

# ---------- Install system dependencies ----------
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

# ---------- Install PHP extensions ----------
RUN docker-php-ext-install pdo_pgsql mbstring exif pcntl bcmath gd zip

# ---------- Enable Apache mod_rewrite ----------
RUN a2enmod rewrite

# ---------- Set working directory ----------
WORKDIR /var/www/html

# ---------- Set Apache DocumentRoot to Laravel public ----------
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# ---------- Install Composer ----------
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ---------- Copy project files ----------
COPY . .

# ---------- Install PHP dependencies ----------
RUN composer install --no-dev --optimize-autoloader --no-scripts

# ---------- Set permissions for Laravel ----------
RUN chown -R www-data:www-data storage bootstrap/cache

# ---------- Run artisan package discovery ----------
RUN php artisan package:discover

# ---------- Expose port 80 ----------
EXPOSE 80

# ---------- Entrypoint ----------
CMD ["apache2-foreground"]
