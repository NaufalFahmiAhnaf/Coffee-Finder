<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CoffeeShopSubmission extends Model
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
        'status',
        'admin_notes',
        'submitted_by',
    ];

    protected $casts = [
        'facilities' => 'array',
        'latitude' => 'double',
        'longitude' => 'double',
        'price' => 'integer',
        'rating' => 'float',
    ];

    public function getMapsUrlAttribute(): string
    {
        return 'https://www.google.com/maps?q=' . $this->latitude . ',' . $this->longitude;
    }
}
