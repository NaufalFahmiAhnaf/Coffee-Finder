# Coffee Finder

### Our Feature

- **Opsi user bisa menambahkan lokasi coffeshop (Lokasi)**
  User merasa coffeeshop yang di datangi recommend untuk dikunjungi, maka user bisa menambah lokasi coffeeshop tersebut berdasarkan koordinat yang dia sekarang (long, lat)

- **Notifikasi**
  Case: Ketika user berada di suatu lokasi, dan ternyata terdapat coffeeshop terdekat, maka user akan mendapatkan notifikasi jika disekitarnya terdapat coffeshop

## Step by Step Run This Project

**Copy .env path**

```bash
[1] cp backend-coffee/.env.example backend-coffee/.env
[2] cp frontend-coffee/.env.example frontend-coffee/.env
```

**Build Docker**

```bash
[1] docker compose up -d --build
[2] docker compose exec backend php artisan key:generate
[3] docker compose exec backend php artisan migrate:fresh --seed
```

**Services:**

- Frontend: http://localhost:5173
- Backend API: http://localhost:8000/api/coffee-shops
- PostgreSQL from host: `localhost:5433`
- PostgreSQL from containers: `postgres:5432`
- pgAdmin: http://localhost:5050 after running `docker compose --profile dev up -d pgadmin`

**Shutdown Docker**

```bash
docker compose down
```

**Useful commands:**

```bash
docker compose exec backend composer install
docker compose exec frontend npm install
docker compose exec backend php artisan migrate:fresh --seed
docker compose logs -f backend
```

Seed data lives in `backend-coffee/database/cafe_data.json` and is loaded by the Laravel `CoffeeShopSeeder`

### Mobile

**How to run emulator**

```bash
cd /mobile_coffee
[1] emulator -avd test_device
[2] adb devices       # To check device availability
[3] flutter run
```

**How to clean flutter project and download dependencies**

```bash
flutter clean
flutter pub get
```

**How to run on a real device**

When using a USB cable, map the phone's localhost back to your laptop with `adb reverse`:

```bash
cd /backend-coffee
php artisan serve --host=127.0.0.1 --port=8000

cd /mobile_coffee
adb reverse tcp:8000 tcp:8000
flutter run -d <DEVICE-CODE> # Ex : flutter run -d RRCW104P6EV
```

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
