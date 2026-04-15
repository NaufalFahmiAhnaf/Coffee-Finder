<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\CoffeeShop;

class CoffeeShopController extends Controller
{
    public function index()
    {
        return CoffeeShop::all();
    }
}