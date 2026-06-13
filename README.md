# Coffee-Finder

### Next Update (Soon)

- Notifikasi (Notifikasi)
  Case: Ketika user berada di suatu lokasi, dan ternyata terdapat coffeeshop terdekat, maka user akan mendapatkan notifikasi jika disekitarnya terdapat coffeshop
  (Pake perhitungan region koordinat terdekat, apabila terdapat koordinat terdekat dari user dalam range tertentu, maka akan diberi notifikasi)

### Our Feature

- **Opsi user bisa menambahkan lokasi coffeshop (Lokasi)**

  User merasa coffeeshop yang di datangi recommend untuk dikunjungi, maka user bisa menambah lokasi coffeeshop tersebut berdasarkan koordinat yang dia sekarang (long, lat)

### Backend

```bash
cd .../backend-coffee
cp .env.example .env
composer install
php -r "file_exists('database/database.sqlite') || touch('database/database.sqlite');"
php artisan key:generate
php artisan migrate
php artisan db:seed --class=CoffeeShopSeeder
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
cd .../mobile_coffee
[1] emulator -avd test_device
[2] adb devices
[3] flutter run   or   flutter run -d <DEVICE-CODE> (flutter run -d RRCW104P6EV)

```

#### How to run on a real device

When using a USB cable, map the phone's localhost back to your laptop with `adb reverse`:

```bash
cd .../backend-coffee
php artisan serve --host=127.0.0.1 --port=8000

cd .../mobile_coffee
adb reverse tcp:8000 tcp:8000
flutter run -d <DEVICE-CODE>
```

Example: `flutter run -d RRCW104P6EV`.

For Wi-Fi debugging instead of USB, run Laravel with `--host=0.0.0.0` and pass your laptop LAN IP with `--dart-define=API_BASE_URL=http://<YOUR-LAPTOP-LAN-IP>:8000`.

#### Any Additional

```bash

press `r` if want to refresh any UI adjustment
press `R` if want to restart all of the project

```

### Endpoint

```bash
localhost:5173/dashboard    # Endpoint only for coffeeFinder user
localhost:5173/admin/submissions    # Endpoint only for admin
```
