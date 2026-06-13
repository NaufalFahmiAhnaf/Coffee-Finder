<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\CoffeeShopController;
use App\Http\Controllers\CoffeeShopSubmissionController;
use App\Http\Controllers\MobileNearbyController;

// Web / Dashboard Routes
Route::get('/coffee-shops', [CoffeeShopController::class, 'index']);
Route::post('/coffee-shop-submissions', [CoffeeShopSubmissionController::class, 'store']);

// Admin Routes 
Route::get('/admin/coffee-shop-submissions', [CoffeeShopSubmissionController::class, 'indexForAdmin']);
Route::post('/admin/coffee-shop-submissions/{submission}/approve', [CoffeeShopSubmissionController::class, 'approve']);
Route::post('/admin/coffee-shop-submissions/{submission}/reject',  [CoffeeShopSubmissionController::class, 'reject']);

// Mobile Routes
Route::prefix('mobile')->group(function () {
    // Submit a new cafe request 
    Route::post('/coffee-shop-submissions', [CoffeeShopSubmissionController::class, 'store']);

    // Nearest cafes within a configurable radius 
    Route::get('/nearest-coffee-shops', [MobileNearbyController::class, 'nearest']);
});
