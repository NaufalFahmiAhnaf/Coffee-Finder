<?php

namespace App\Http\Controllers;

use App\Models\CoffeeShop;
use Illuminate\Http\Request;

class CoffeeShopController extends Controller
{

    public function index(Request $request)
    {
        $data = CoffeeShop::query()
            ->select('id', 'name', 'address', 'latitude', 'longitude', 'rating', 'price', 'facilities', 'image_url')
            ->get()
            ->map(function (CoffeeShop $item) {
                return [
                    'id' => $item->id,
                    'name' => $item->name,
                    'address' => $item->address,
                    'latitude' => (float) $item->latitude,
                    'longitude' => (float) $item->longitude,
                    'rating' => (float) $item->rating,
                    'price' => (int) $item->price,
                    'facilities' => $item->facilities ?? [],
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
                       str_contains(strtolower($item['address'] ?? ''), $q);
            });
        }

        // Facilities (AND filtering)
        if ($request->has('facilities')) {
            $reqFacilities = is_array($request->facilities)
                ? $request->facilities
                : explode(',', (string) $request->facilities);

            $reqFacilities = array_filter($reqFacilities);

            $filtered = $filtered->filter(function ($item) use ($reqFacilities) {
                foreach ($reqFacilities as $fac) {
                    if (empty(($item['facilities'] ?? [])[$fac])) {
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
