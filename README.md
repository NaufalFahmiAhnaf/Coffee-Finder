# Coffee-Finder


### Backend
```bash
cd .../backend-coffee
cp .env.example .env
composer install
php -r "file_exists('database/database.sqlite') || touch('database/database.sqlite');"
php artisan key:generate
php artisan migrate
php artisan serve --host=127.0.0.1 --port=8000
```

### Frontend

```bash
cd .../frontend-coffee
npm install
npm run dev -- --host 127.0.0.1 --port 5173
```