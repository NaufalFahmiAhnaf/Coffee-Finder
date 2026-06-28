<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CoffeeShop extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'address',
        'price',
        'rating',
        'image_url',
        'latitude',
        'longitude',
        'facilities',
    ];

    protected $casts = [
        'latitude' => 'double',
        'longitude' => 'double',
        'price' => 'integer',
        'rating' => 'float',
        'facilities' => 'array',
    ];
}
