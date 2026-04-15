<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CoffeeShop extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'address',
        'price',
        'rating',
        'capacity',
        'latitude',
        'longitude',
        'facilities'
    ];
}