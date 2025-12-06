FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy project files
COPY . .

# Install PHP dependencies (but DO NOT run artisan yet)
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Laravel permissions
RUN chown -R www-data:www-data storage bootstrap/cache

# Now that Composer is installed, we can safely run artisan
RUN php artisan package:discover

# Expose port
EXPOSE 80

CMD ["apache2-foreground"]
