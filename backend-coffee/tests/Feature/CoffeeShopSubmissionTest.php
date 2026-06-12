<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CoffeeShopSubmissionTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_submit_a_new_coffee_shop_request(): void
    {
        $response = $this->postJson('/api/coffee-shop-submissions', [
            'name' => 'Test Cafe',
            'description' => 'Great coffee',
            'address' => 'Jl. Test No.1',
            'price' => 25000,
            'rating' => 4.5,
            'image_url' => 'https://example.com/cafe.jpg',
            'latitude' => -7.2504,
            'longitude' => 112.7688,
            'facilities' => ['wifi' => true, 'outdoor' => true],
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('data.status', 'pending');

        $this->assertDatabaseHas('coffee_shop_submissions', [
            'name' => 'Test Cafe',
            'status' => 'pending',
        ]);
    }

    public function test_admin_can_approve_a_submission_and_copy_it_to_coffee_shops(): void
    {
        $submission = \DB::table('coffee_shop_submissions')->insertGetId([
            'name' => 'Approve Me',
            'description' => 'Needs approval',
            'address' => 'Jl. Admin No.1',
            'price' => 30000,
            'rating' => 4.7,
            'image_url' => 'https://example.com/approve.jpg',
            'latitude' => -7.2600,
            'longitude' => 112.7700,
            'facilities' => json_encode(['wifi' => true]),
            'status' => 'pending',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $response = $this->postJson("/api/admin/coffee-shop-submissions/{$submission}/approve");

        $response->assertStatus(200)
            ->assertJsonPath('data.status', 'approved');

        $this->assertDatabaseHas('coffee_shop_submissions', [
            'id' => $submission,
            'status' => 'approved',
        ]);

        $this->assertDatabaseHas('coffee_shops', [
            'name' => 'Approve Me',
            'address' => 'Jl. Admin No.1',
        ]);
    }
}
