<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('coffee_shop_submissions', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('address')->nullable();
            $table->integer('price');
            $table->float('rating');
            $table->string('image_url')->nullable();
            $table->double('latitude', 10, 8);
            $table->double('longitude', 11, 8);
            $table->json('facilities')->nullable();
            $table->string('status')->default('pending');
            $table->text('admin_notes')->nullable();
            $table->string('submitted_by')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('coffee_shop_submissions');
    }
};
