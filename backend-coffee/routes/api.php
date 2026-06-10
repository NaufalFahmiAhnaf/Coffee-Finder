<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\CoffeeShopController;

Route::get('/coffee-shops', [CoffeeShopController::class, 'index']);
