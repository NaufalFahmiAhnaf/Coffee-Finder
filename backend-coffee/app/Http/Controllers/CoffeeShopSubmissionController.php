<?php

namespace App\Http\Controllers;

use App\Models\CoffeeShop;
use App\Models\CoffeeShopSubmission;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CoffeeShopSubmissionController extends Controller
{
    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'address' => ['nullable', 'string', 'max:255'],
            'price' => ['required', 'integer', 'min:0'],
            'rating' => ['required', 'numeric', 'between:0,5'],
            'image_url' => ['nullable', 'url'],
            'latitude' => ['required', 'numeric'],
            'longitude' => ['required', 'numeric'],
            'facilities' => ['nullable', 'array'],
            'submitted_by' => ['nullable', 'string', 'max:255'],
        ]);

        $submission = CoffeeShopSubmission::create([
            ...$data,
            'status' => 'pending',
            'facilities' => $data['facilities'] ?? null,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Coffee shop request submitted successfully.',
            'data' => [
                'id' => $submission->id,
                'name' => $submission->name,
                'status' => $submission->status,
                'maps_url' => $submission->maps_url,
            ],
        ], 201);
    }

    public function indexForAdmin()
    {
        $submissions = CoffeeShopSubmission::query()
            ->orderByDesc('created_at')
            ->get()
            ->map(function (CoffeeShopSubmission $item) {
                return [
                    'id' => $item->id,
                    'name' => $item->name,
                    'description' => $item->description,
                    'address' => $item->address,
                    'price' => $item->price,
                    'rating' => $item->rating,
                    'image_url' => $item->image_url,
                    'latitude' => $item->latitude,
                    'longitude' => $item->longitude,
                    'maps_url' => $item->maps_url,
                    'facilities' => $item->facilities,
                    'status' => $item->status,
                    'submitted_by' => $item->submitted_by,
                    'admin_notes' => $item->admin_notes,
                    'created_at' => $item->created_at,
                    'updated_at' => $item->updated_at,
                ];
            });

        return response()->json([
            'status' => 'success',
            'total' => $submissions->count(),
            'data' => $submissions,
        ]);
    }

    public function approve(CoffeeShopSubmission $submission)
    {
        return DB::transaction(function () use ($submission) {
            CoffeeShop::create([
                'name' => $submission->name,
                'description' => $submission->description,
                'address' => $submission->address,
                'price' => $submission->price,
                'rating' => $submission->rating,
                'image_url' => $submission->image_url,
                'latitude' => $submission->latitude,
                'longitude' => $submission->longitude,
                'facilities' => $submission->facilities,
            ]);

            $submission->update([
                'status' => 'approved',
                'admin_notes' => 'Approved by admin.',
            ]);

            return response()->json([
                'status' => 'success',
                'message' => 'Submission approved and inserted into coffee_shops.',
                'data' => [
                    'id' => $submission->id,
                    'status' => 'approved',
                    'maps_url' => $submission->maps_url,
                ],
            ]);
        });
    }

    public function reject(Request $request, CoffeeShopSubmission $submission)
    {
        $request->validate([
            'admin_notes' => ['nullable', 'string'],
        ]);

        $submission->update([
            'status' => 'rejected',
            'admin_notes' => $request->input('admin_notes', 'Rejected by admin.'),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Submission rejected.',
            'data' => [
                'id' => $submission->id,
                'status' => 'rejected',
                'maps_url' => $submission->maps_url,
            ],
        ]);
    }
}
