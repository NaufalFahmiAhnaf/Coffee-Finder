<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\CoffeeShop;

class CoffeeShopController extends Controller
{
    public function index(Request $request)
    {
        $query = CoffeeShop::query();

        if ($request->has('q')) {
            $query->where('name', 'like', '%' . $request->q . '%')
                  ->orWhere('description', 'like', '%' . $request->q . '%');
        }

        if ($request->has('min_price')) {
            $query->where('price', '>=', $request->min_price);
        }

        if ($request->has('max_price')) {
            $query->where('price', '<=', $request->max_price);
        }

        if ($request->has('facilities')) {
            $facilities = is_array($request->facilities) ? $request->facilities : explode(',', $request->facilities);
            foreach ($facilities as $facility) {
                $query->where('facilities->' . trim($facility), true);
            }
        }

        if ($request->has('sort_by')) {
            if ($request->sort_by == 'rating') {
                $query->orderBy('rating', 'desc');
            } else if ($request->sort_by == 'price_asc') {
                $query->orderBy('price', 'asc');
            } else if ($request->sort_by == 'price_desc') {
                $query->orderBy('price', 'desc');
            }
        } else {
            $query->orderBy('rating', 'desc'); // Default sort by best rating
        }

        return response()->json($query->get());
    }
}