<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::create('coffee_shops', function (Blueprint $table) {

            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('address')->nullable();
            $table->integer('price'); // average price
            $table->float('rating');
            $table->string('image_url')->nullable();
            $table->double('latitude', 10, 8);
            $table->double('longitude', 11, 8);
            $table->json('facilities')->nullable(); // json format: {"wifi": true, "outdoor": true, "ac": true, "sockets": true, "smoking_room": true}
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('coffee_shops');
    }
};
