<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CoffeeShopSeeder extends Seeder
{
    public function run(): void
    {
        $coffees = [
            // SURABAYA PUSAT
            [
                'name' => 'Volks Coffee',
                'description' => 'A cozy specialty coffee shop known for its minimalist design and great espresso.',
                'address' => 'Jl. M.H. Thamrin No.34, DR. Soetomo, Tegalsari, Surabaya',
                'price' => 35000,
                'rating' => 4.6,
                'image_url' => 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=500&q=80',
                'latitude' => -7.2755,
                'longitude' => 112.7388,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => true, 'ac' => true, 'sockets' => true, 'smoking_room' => true]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Threelogy Coffee',
                'description' => 'Spacious and aesthetic cafe with amazing pour-over options.',
                'address' => 'Jl. Mojopahit No.46, Keputran, Tegalsari, Surabaya',
                'price' => 45000,
                'rating' => 4.7,
                'image_url' => 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=500&q=80',
                'latitude' => -7.2751,
                'longitude' => 112.7390,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => false, 'ac' => true, 'sockets' => true, 'smoking_room' => false]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Titik Koma Coffee Biliton',
                'description' => 'Popular local chain serving delicious iced coffee milk.',
                'address' => 'Jl. Biliton No.25, Gubeng, Surabaya',
                'price' => 25000,
                'rating' => 4.5,
                'image_url' => 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=500&q=80',
                'latitude' => -7.2748,
                'longitude' => 112.7505,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => true, 'ac' => true, 'sockets' => false, 'smoking_room' => true]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Historica Coffee & Pastry',
                'description' => 'Vintage style cafe with amazing pastry selections.',
                'address' => 'Jl. Sumatera No.40, Gubeng, Surabaya',
                'price' => 50000,
                'rating' => 4.6,
                'image_url' => 'https://images.unsplash.com/photo-1445116572660-236099ceab11?w=500&q=80',
                'latitude' => -7.2688,
                'longitude' => 112.7483,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => false, 'ac' => true, 'sockets' => true, 'smoking_room' => false]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Kopi Kenangan - Tunjungan Plaza',
                'description' => 'Grab-and-go iced coffees inside a popular mall.',
                'address' => 'Tunjungan Plaza 3, Jl. Basuki Rahmat, Surabaya',
                'price' => 22000,
                'rating' => 4.4,
                'image_url' => 'https://images.unsplash.com/photo-1610632380986-cb44ce071fb2?w=500&q=80',
                'latitude' => -7.2625,
                'longitude' => 112.7395,
                'facilities' => json_encode(['wifi' => false, 'outdoor' => false, 'ac' => true, 'sockets' => false, 'smoking_room' => false]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Caturra Espresso',
                'description' => 'Bright space with big windows, serving excellent single origins.',
                'address' => 'Jl. Anjasmoro No.32, Sawahan, Surabaya',
                'price' => 45000,
                'rating' => 4.7,
                'image_url' => 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&q=80',
                'latitude' => -7.2654,
                'longitude' => 112.7230,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => true, 'ac' => true, 'sockets' => true, 'smoking_room' => true]),
                'created_at' => now(), 'updated_at' => now()
            ],

            // SURABAYA BARAT
            [
                'name' => 'Common Grounds Pakuwon Mall',
                'description' => 'Premium coffee shop located inside a mall with excellent breakfast options.',
                'address' => 'Pakuwon Mall, Lantai G, Jl. Puncak Indah Lontar, Wiyung, Surabaya',
                'price' => 60000,
                'rating' => 4.8,
                'image_url' => 'https://images.unsplash.com/photo-1453614512568-c4024d13c247?w=500&q=80',
                'latitude' => -7.2890,
                'longitude' => 112.6755,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => false, 'ac' => true, 'sockets' => true, 'smoking_room' => false]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Kudos Cafe',
                'description' => 'Monochrome themed cafe with a very aesthetic interior, perfect for studying.',
                'address' => 'Pakuwon Square AK 2 No. 3, Jl. Yono Suwoyo, Surabaya',
                'price' => 50000,
                'rating' => 4.6,
                'image_url' => 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=500&q=80',
                'latitude' => -7.2882,
                'longitude' => 112.6766,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => false, 'ac' => true, 'sockets' => true, 'smoking_room' => false]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Monopole Coffee Lab',
                'description' => 'Great ambiance for working and hanging out.',
                'address' => 'Jl. Raya Darmo Permai I No.38, Pradahkalikendal, Surabaya',
                'price' => 45000,
                'rating' => 4.5,
                'image_url' => 'https://images.unsplash.com/photo-1525610553991-2bede1a236e2?w=500&q=80',
                'latitude' => -7.2828,
                'longitude' => 112.6853,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => true, 'ac' => true, 'sockets' => true, 'smoking_room' => true]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Redback Specialty Coffee',
                'description' => 'Overlooking a golf course, known for its croissants.',
                'address' => 'Graha Family, Jl. Raya Golf Graha Famili, Pradahkalikendal, Surabaya',
                'price' => 65000,
                'rating' => 4.7,
                'image_url' => 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=500&q=80',
                'latitude' => -7.2912,
                'longitude' => 112.6761,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => true, 'ac' => true, 'sockets' => false, 'smoking_room' => true]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Kopi Kenangan - Gwalk',
                'description' => 'Affordable and tasty coffee at the busy Gwalk area.',
                'address' => 'G-Walk Citraland, Ruko Taman Gapura, Surabaya',
                'price' => 20000,
                'rating' => 4.3,
                'image_url' => 'https://images.unsplash.com/photo-1610632380986-cb44ce071fb2?w=500&q=80',
                'latitude' => -7.2816,
                'longitude' => 112.6465,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => true, 'ac' => true, 'sockets' => false, 'smoking_room' => true]),
                'created_at' => now(), 'updated_at' => now()
            ],

            // SURABAYA TIMUR
            [
                'name' => 'Caloria',
                'description' => 'Cozy neighborhood cafe with a mix of western and local bites.',
                'address' => 'Jl. Dharmawangsa No.140, Airlangga, Gubeng, Surabaya',
                'price' => 40000,
                'rating' => 4.4,
                'image_url' => 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=500&q=80',
                'latitude' => -7.2711,
                'longitude' => 112.7601,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => true, 'ac' => true, 'sockets' => true, 'smoking_room' => true]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Kopi Kenangan - MERR',
                'description' => 'Quick coffee pickup on the busy MERR street.',
                'address' => 'Jl. Dr. Ir. H. Soekarno No. 400, Surabaya',
                'price' => 22000,
                'rating' => 4.3,
                'image_url' => 'https://images.unsplash.com/photo-1610632380986-cb44ce071fb2?w=500&q=80',
                'latitude' => -7.2954,
                'longitude' => 112.7792,
                'facilities' => json_encode(['wifi' => false, 'outdoor' => false, 'ac' => true, 'sockets' => false, 'smoking_room' => false]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'TBRK Rumah Kopi',
                'description' => 'Local favorite with a very relaxed homey vibe.',
                'address' => 'Jl. Nginden Semolo No.85, Surabaya',
                'price' => 25000,
                'rating' => 4.5,
                'image_url' => 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=500&q=80',
                'latitude' => -7.2995,
                'longitude' => 112.7656,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => true, 'ac' => false, 'sockets' => true, 'smoking_room' => true]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Titik Koma - MERR',
                'description' => 'A great spot for studying or working.',
                'address' => 'Jl. Dr. Ir. H. Soekarno, Rungkut, Surabaya',
                'price' => 28000,
                'rating' => 4.4,
                'image_url' => 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=500&q=80',
                'latitude' => -7.3101,
                'longitude' => 112.7788,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => true, 'ac' => true, 'sockets' => true, 'smoking_room' => true]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Ruang Roastery',
                'description' => 'Specialty coffee roaster with amazing manual brews.',
                'address' => 'Jl. Rungkut Madya No.53, Surabaya',
                'price' => 30000,
                'rating' => 4.6,
                'image_url' => 'https://images.unsplash.com/photo-1445116572660-236099ceab11?w=500&q=80',
                'latitude' => -7.3290,
                'longitude' => 112.7845,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => true, 'ac' => true, 'sockets' => true, 'smoking_room' => true]),
                'created_at' => now(), 'updated_at' => now()
            ],

            // SURABAYA SELATAN
            [
                'name' => 'Kopi Kenangan - Ahmad Yani',
                'description' => 'Easily accessible from the main road of Ahmad Yani.',
                'address' => 'Jl. Ahmad Yani No.260, Siwalankerto, Wonocolo, Surabaya',
                'price' => 22000,
                'rating' => 4.4,
                'image_url' => 'https://images.unsplash.com/photo-1610632380986-cb44ce071fb2?w=500&q=80',
                'latitude' => -7.3331,
                'longitude' => 112.7302,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => true, 'ac' => true, 'sockets' => true, 'smoking_room' => true]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Rolag Kopi Karah',
                'description' => 'Famous hanging out spot by the river with affordable prices.',
                'address' => 'Jl. Karah No.6, Jambangan, Surabaya',
                'price' => 15000,
                'rating' => 4.5,
                'image_url' => 'https://images.unsplash.com/photo-1525610553991-2bede1a236e2?w=500&q=80',
                'latitude' => -7.3168,
                'longitude' => 112.7161,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => true, 'ac' => false, 'sockets' => true, 'smoking_room' => true]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Kopi Janji Jiwa Jemursari',
                'description' => 'Good coffee with toast options.',
                'address' => 'Jl. Raya Jemursari No.152, Surabaya',
                'price' => 20000,
                'rating' => 4.3,
                'image_url' => 'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=500&q=80',
                'latitude' => -7.3182,
                'longitude' => 112.7441,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => true, 'ac' => true, 'sockets' => false, 'smoking_room' => true]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Fore Coffee - Royal Plaza',
                'description' => 'Premium coffee experience in South Surabaya.',
                'address' => 'Royal Plaza, Jl. Ahmad Yani No.16-18, Surabaya',
                'price' => 35000,
                'rating' => 4.5,
                'image_url' => 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=500&q=80',
                'latitude' => -7.3087,
                'longitude' => 112.7345,
                'facilities' => json_encode(['wifi' => false, 'outdoor' => false, 'ac' => true, 'sockets' => false, 'smoking_room' => false]),
                'created_at' => now(), 'updated_at' => now()
            ],

            // SURABAYA UTARA
            [
                'name' => 'Toko Kopi Tuku - SPBU Perak',
                'description' => 'The famous Kopi Susu Tetangga, grab and go.',
                'address' => 'SPBU Perak Barat, Jl. Perak Barat No.27, Surabaya',
                'price' => 20000,
                'rating' => 4.6,
                'image_url' => 'https://images.unsplash.com/photo-1453614512568-c4024d13c247?w=500&q=80',
                'latitude' => -7.2185,
                'longitude' => 112.7275,
                'facilities' => json_encode(['wifi' => false, 'outdoor' => true, 'ac' => false, 'sockets' => false, 'smoking_room' => true]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Kedai Kopi Kulo Kenjeran',
                'description' => 'Refreshing iced coffees near the coast.',
                'address' => 'Jl. Kenjeran No.342, Gading, Tambaksari, Surabaya',
                'price' => 18000,
                'rating' => 4.2,
                'image_url' => 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=500&q=80',
                'latitude' => -7.2451,
                'longitude' => 112.7661,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => true, 'ac' => true, 'sockets' => true, 'smoking_room' => true]),
                'created_at' => now(), 'updated_at' => now()
            ],
            [
                'name' => 'Vanko Coffee',
                'description' => 'Hidden gem in the north with industrial design.',
                'address' => 'Jl. Indrapura No.12, Krembangan, Surabaya',
                'price' => 30000,
                'rating' => 4.4,
                'image_url' => 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&q=80',
                'latitude' => -7.2389,
                'longitude' => 112.7301,
                'facilities' => json_encode(['wifi' => true, 'outdoor' => true, 'ac' => true, 'sockets' => true, 'smoking_room' => true]),
                'created_at' => now(), 'updated_at' => now()
            ]
        ];

        DB::table('coffee_shops')->insert($coffees);
    }
}
