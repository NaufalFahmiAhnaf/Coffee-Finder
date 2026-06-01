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

### Mobile

#### How to run emulator

```bash

[1] emulator -avd test_device
[2] adb devices
[3] flutter run

```
#### Any Additional

```bash

press `r` if want to refresh any UI adjustment
press `R` if want to restart all of the project

```