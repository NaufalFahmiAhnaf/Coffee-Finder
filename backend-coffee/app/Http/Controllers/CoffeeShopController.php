<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CoffeeShopController extends Controller
{

    public function index(Request $request)
    {
        $lat = $request->input('lat', -7.2504);
        $lng = $request->input('lng', 112.7688);

        $data = DB::table('coffee_shops')
            ->select('id', 'name', 'address', 'latitude', 'longitude', 'rating', 'price', 'facilities', 'image_url')
            ->get()
            ->map(function ($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->name,
                    'address' => $item->address,
                    'latitude' => (float) $item->latitude,
                    'longitude' => (float) $item->longitude,
                    'rating' => (float) $item->rating,
                    'price' => (int) $item->price,
                    'facilities' => is_array($item->facilities) ? $item->facilities : json_decode($item->facilities ?? '{}', true),
                    'image_url' => $item->image_url,
                ];
            })
            ->values()
            ->all();

        // =========================
        // FILTERING & SORTING
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