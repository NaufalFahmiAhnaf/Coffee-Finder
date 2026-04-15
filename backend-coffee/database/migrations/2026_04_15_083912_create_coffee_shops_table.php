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
        $table->string('address');
        $table->integer('price');
        $table->float('rating');
        $table->integer('capacity');
        $table->double('latitude');
        $table->double('longitude');
        $table->text('facilities')->nullable();
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
