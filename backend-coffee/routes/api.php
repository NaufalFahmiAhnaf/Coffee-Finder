<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\CoffeeShopController;
use App\Http\Controllers\CoffeeShopSubmissionController;

Route::get('/coffee-shops', [CoffeeShopController::class, 'index']);
Route::post('/coffee-shop-submissions', [CoffeeShopSubmissionController::class, 'store']);

Route::get('/admin/coffee-shop-submissions', [CoffeeShopSubmissionController::class, 'indexForAdmin']);
Route::post('/admin/coffee-shop-submissions/{submission}/approve', [CoffeeShopSubmissionController::class, 'approve']);
Route::post('/admin/coffee-shop-submissions/{submission}/reject', [CoffeeShopSubmissionController::class, 'reject']);
