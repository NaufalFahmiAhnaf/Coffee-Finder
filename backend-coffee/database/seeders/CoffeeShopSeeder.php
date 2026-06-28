<?php

namespace Database\Seeders;

use App\Models\CoffeeShop;
use Illuminate\Database\JsonException;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use RuntimeException;

class CoffeeShopSeeder extends Seeder
{
    public function run(): void
    {
        $path = database_path('cafe_data.json');

        if (! file_exists($path)) {
            throw new RuntimeException("Coffee shop seed file was not found: {$path}");
        }

        try {
            $coffeeShops = json_decode(
                file_get_contents($path),
                true,
                512,
                JSON_THROW_ON_ERROR
            );
        } catch (JsonException $exception) {
            throw new RuntimeException(
                "Coffee shop seed file contains invalid JSON: {$path}",
                previous: $exception
            );
        }

        if (! is_array($coffeeShops) || array_is_list($coffeeShops) === false) {
            throw new RuntimeException('Coffee shop seed file must contain an array of objects.');
        }

        $records = [];
        foreach ($coffeeShops as $index => $coffeeShop) {
            if (! is_array($coffeeShop)) {
                throw new RuntimeException("Coffee shop seed item at index {$index} must be an object.");
            }

            if (isset($coffeeShop['facilities']) && ! is_array($coffeeShop['facilities'])) {
                throw new RuntimeException("Coffee shop facilities at index {$index} must be an array.");
            }

            $records[] = $coffeeShop;
        }

        DB::transaction(function () use ($records): void {
            DB::statement('TRUNCATE TABLE coffee_shops RESTART IDENTITY CASCADE');

            foreach ($records as $record) {
                CoffeeShop::create($record);
            }
        });
    }
}
