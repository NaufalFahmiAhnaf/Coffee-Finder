<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;

class CoffeeShopController extends Controller
{

    public function index(Request $request){
        
        $lat = $request->input('lat', -7.2504);
        $lng = $request->input('lng', 112.7688);
        $radius = 5000;

        $cacheKey = "coffee_shops_" . round($lat, 3) . "_" . round($lng, 3);

        $data = Cache::remember($cacheKey, 3600, function () use ($lat, $lng, $radius) {

            $response = Http::withHeaders([
                'Authorization' => config('services.foursquare.key'),
                'accept' => 'application/json',
            ])->get('https://api.foursquare.com/v3/places/search', [
                'll' => "$lat,$lng",
                'radius' => $radius,
                'categories' => '13032',
                'limit' => 50
            ]);

            if ($response->failed()) {
                \Log::error("Foursquare API Error: " . $response->body());
                return [];
            }

            $results = $response->json()['results'] ?? [];

            return array_map(function ($place) {
                return [
                    'id' => $place['fsq_id'] ?? uniqid(),
                    'name' => $place['name'] ?? null,
                    'address' => $place['location']['formatted_address'] ?? null,
                    'latitude' => $place['geocodes']['main']['latitude'] ?? null,
                    'longitude' => $place['geocodes']['main']['longitude'] ?? null,
                    'rating' => $place['rating'] ?? 4.0,
                    'price' => $place['price'] ?? 25000,
                    'facilities' => [
                        'wifi' => (bool) (rand(0, 1)),
                        'outdoor' => (bool) (rand(0, 1)),
                        'ac' => (bool) (rand(0, 1)),
                        'sockets' => (bool) (rand(0, 1)),
                        'smoking_room' => (bool) (rand(0, 1)),
                    ]
                ];
            }, $results);
        });

        if (empty($data)) {
            // Fallback mock data for testing if API fails
            $data = [
                ['id'=>'m1','name'=>'Tunjungan Coffee Bar','address'=>'Jl. Tunjungan No. 12','latitude'=>-7.2575,'longitude'=>112.7421,'rating'=>4.8,'price'=>35000,'facilities'=>['wifi'=>true,'outdoor'=>true,'ac'=>true,'sockets'=>true,'smoking_room'=>false]],
                ['id'=>'m2','name'=>'Gubeng Station Brew','address'=>'Jl. Gubeng Masjid No. 5','latitude'=>-7.2654,'longitude'=>112.7532,'rating'=>4.5,'price'=>25000,'facilities'=>['wifi'=>true,'outdoor'=>false,'ac'=>true,'sockets'=>true,'smoking_room'=>true]],
                ['id'=>'m3','name'=>'Darmahusada Hub','address'=>'Jl. Darmahusada No. 45','latitude'=>-7.2688,'longitude'=>112.7788,'rating'=>4.7,'price'=>30000,'facilities'=>['wifi'=>true,'outdoor'=>true,'ac'=>true,'sockets'=>true,'smoking_room'=>false]],
                ['id'=>'m4','name'=>'Basuki Rahmat Roasters','address'=>'Jl. Basuki Rahmat No. 10','latitude'=>-7.2633,'longitude'=>112.7399,'rating'=>4.9,'price'=>45000,'facilities'=>['wifi'=>true,'outdoor'=>true,'ac'=>true,'sockets'=>true,'smoking_room'=>false]],
                ['id'=>'m5','name'=>'Mulyorejo Chill Spot','address'=>'Jl. Mulyorejo No. 88','latitude'=>-7.2611,'longitude'=>112.7911,'rating'=>4.3,'price'=>20000,'facilities'=>['wifi'=>true,'outdoor'=>true,'ac'=>false,'sockets'=>false,'smoking_room'=>true]],
                ['id'=>'m6','name'=>'Pakuwon Vibe','address'=>'Pakuwon Mall L3','latitude'=>-7.2888,'longitude'=>112.6788,'rating'=>4.6,'price'=>55000,'facilities'=>['wifi'=>true,'outdoor'=>false,'ac'=>true,'sockets'=>true,'smoking_room'=>false]],
                ['id'=>'m7','name'=>'Mayjen Sungkono Beans','address'=>'Jl. Mayjen Sungkono No. 20','latitude'=>-7.2911,'longitude'=>112.7111,'rating'=>4.4,'price'=>32000,'facilities'=>['wifi'=>false,'outdoor'=>true,'ac'=>true,'sockets'=>true,'smoking_room'=>true]],
                ['id'=>'m8','name'=>'Ngagel Espresso','address'=>'Jl. Ngagel Jaya No. 15','latitude'=>-7.2955,'longitude'=>112.7488,'rating'=>4.2,'price'=>18000,'facilities'=>['wifi'=>true,'outdoor'=>true,'ac'=>false,'sockets'=>true,'smoking_room'=>true]],
                ['id'=>'m9','name'=>'Manyar Kertoarjo Social','address'=>'Jl. Manyar Kertoarjo No. 3','latitude'=>-7.2833,'longitude'=>112.7699,'rating'=>4.7,'price'=>40000,'facilities'=>['wifi'=>true,'outdoor'=>true,'ac'=>true,'sockets'=>true,'smoking_room'=>false]],
                ['id'=>'m10','name'=>'Ahmad Yani Coffee','address'=>'Jl. Ahmad Yani No. 150','latitude'=>-7.3211,'longitude'=>112.7322,'rating'=>4.5,'price'=>28000,'facilities'=>['wifi'=>true,'outdoor'=>false,'ac'=>true,'sockets'=>true,'smoking_room'=>false]],
                ['id'=>'m11','name'=>'Citraland Lake Cafe','address'=>'G-Walk Citraland','latitude'=>-7.2811,'longitude'=>112.6522,'rating'=>4.8,'price'=>50000,'facilities'=>['wifi'=>true,'outdoor'=>true,'ac'=>true,'sockets'=>false,'smoking_room'=>false]],
                ['id'=>'m12','name'=>'Wonokromo Morning','address'=>'Jl. Wonokromo No. 1','latitude'=>-7.3011,'longitude'=>112.7355,'rating'=>4.1,'price'=>15000,'facilities'=>['wifi'=>false,'outdoor'=>true,'ac'=>false,'sockets'=>false,'smoking_room'=>true]],
                ['id'=>'m13','name'=>'Fore Coffee - Ruko Bukit Palma','address'=>'Ruko Palma Galeria RB 05-20','latitude'=>-7.261716331131363,'longitude'=> 112.6346913804825,'rating'=>4.7,'price'=>25000,'facilities'=>['wifi'=>true,'outdoor'=>false,'ac'=>true,'sockets'=>true,'smoking_room'=>false]],
            ];
        }

        // =========================
        // FILTERING (manual karena bukan DB)
        // =========================
        $filtered = collect($data);

        // Search
        if ($request->has('q') && !empty($request->q)) {
            $q = strtolower($request->q);
            $filtered = $filtered->filter(function ($item) use ($q) {
                return str_contains(strtolower($item['name']), $q) ||
                       str_contains(strtolower($item['address']), $q);
            });
        }

        // Facilities (AND filtering)
        if ($request->has('facilities')) {
            $reqFacilities = (array) $request->facilities;
            $filtered = $filtered->filter(function ($item) use ($reqFacilities) {
                foreach ($reqFacilities as $fac) {
                    if (empty($item['facilities'][$fac])) {
                        return false;
                    }
                }
                return true;
            });
        }

        // Price range
        if ($request->has('max_price') && !empty($request->max_price)) {
            $filtered = $filtered->where('price', '<=', (int) $request->max_price);
        }

        // Sorting
        if ($request->has('sort_by')) {
            if ($request->sort_by == 'rating') {
                $filtered = $filtered->sortByDesc('rating');
            } elseif ($request->sort_by == 'price_asc') {
                $filtered = $filtered->sortBy('price');
            } elseif ($request->sort_by == 'price_desc') {
                $filtered = $filtered->sortByDesc('price');
            }
        } else {
            $filtered = $filtered->sortByDesc('rating');
        }

        return response()->json([
            'status' => 'success',
            'total' => $filtered->count(),
            'data' => $filtered->values()
        ]);
    }
}