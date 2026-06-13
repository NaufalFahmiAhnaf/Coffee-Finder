<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MobileNearbyController extends Controller
{
    // =========================================================================
    // CONFIGURABLE PARAMETERS
    // =========================================================================


    // Default search radius in kilometres when the client does not supply one.
    const DEFAULT_RADIUS_KM = 3;

    // Hard upper cap on the radius a client may request (prevents abuse).
    const MAX_RADIUS_KM = 20;


    // Minimum number of minutes the user must stay in roughly the same spot
    const MIN_DWELL_MINUTES = 10;

    // Minimum number of minutes that must pass after the last notification
    const NOTIFICATION_COOLDOWN_MINUTES = 10;

    // Earth's mean radius in kilometres, used by the Haversine formula.
    const EARTH_RADIUS_KM = 6371;

    // =========================================================================

    /**
     * GET /api/mobile/nearest-coffee-shops
     *
     * Query parameters:
     *   lat    (float, required) — user's current latitude
     *   lng    (float, required) — user's current longitude
     *   radius (float, optional) — search radius in km (default: DEFAULT_RADIUS_KM)
     *
     * Response includes `notification_config` so the mobile client can apply
     * dwell-time and cooldown logic without a rebuild whenever you change the
     * constants above.
     */
    public function nearest(Request $request)
    {
        $request->validate([
            'lat'    => ['required', 'numeric'],
            'lng'    => ['required', 'numeric'],
            'radius' => ['nullable', 'numeric', 'min:0.1', 'max:' . self::MAX_RADIUS_KM],
        ]);

        $userLat  = (float) $request->input('lat');
        $userLng  = (float) $request->input('lng');
        $radiusKm = (float) ($request->input('radius') ?? self::DEFAULT_RADIUS_KM);

        // Clamp radius to the allowed maximum
        $radiusKm = min($radiusKm, self::MAX_RADIUS_KM);

        // Fetch all shops and compute distance using the Haversine formula in PHP.
        // (SQLite does not have native trigonometric functions by default, so we
        //  calculate in-memory. For large datasets consider switching to MySQL/PostGIS.)
        $shops = DB::table('coffee_shops')
            ->select('id', 'name', 'address', 'latitude', 'longitude', 'rating', 'price', 'facilities', 'image_url')
            ->get();

        $nearby = [];

        foreach ($shops as $shop) {
            $shopLat = (float) $shop->latitude;
            $shopLng = (float) $shop->longitude;

            $distanceKm = $this->haversineKm($userLat, $userLng, $shopLat, $shopLng);

            if ($distanceKm <= $radiusKm) {
                $nearby[] = [
                    'id'          => $shop->id,
                    'name'        => $shop->name,
                    'address'     => $shop->address,
                    'distance_km' => round($distanceKm, 2),
                    'rating'      => (float) $shop->rating,
                    'price'       => (int) $shop->price,
                    'facilities'  => is_array($shop->facilities)
                        ? $shop->facilities
                        : json_decode($shop->facilities ?? '{}', true),
                    'image_url'   => $shop->image_url,
                    'maps_url'    => 'https://www.google.com/maps?q=' . $shopLat . ',' . $shopLng,
                ];
            }
        }

        // Sort by distance ascending so the closest cafe comes first
        usort($nearby, fn($a, $b) => $a['distance_km'] <=> $b['distance_km']);

        return response()->json([
            'status' => 'success',

            // ── Notification config ──────────────────────────────────────────
            // The mobile app should read these values at runtime so you can
            // tune them here without rebuilding the app.
            'notification_config' => [
                // Minutes the user must dwell in one spot before notifying
                'min_dwell_minutes'       => self::MIN_DWELL_MINUTES,
                // Minutes that must pass between consecutive notifications
                'cooldown_minutes'        => self::NOTIFICATION_COOLDOWN_MINUTES,
            ],

            'radius_km' => $radiusKm,
            'total'     => count($nearby),
            'data'      => $nearby,
        ]);
    }

    // =========================================================================
    // Haversine formula — returns distance in kilometres between two lat/lng points
    // =========================================================================

    private function haversineKm(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);

        $a = sin($dLat / 2) ** 2
            + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLng / 2) ** 2;

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return self::EARTH_RADIUS_KM * $c;
    }
}
