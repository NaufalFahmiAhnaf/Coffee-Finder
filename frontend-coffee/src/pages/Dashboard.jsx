import { useEffect, useState } from "react";
import axios from "axios";
import { MapContainer, TileLayer, Marker, Popup } from "react-leaflet";
import L from "leaflet";
import markerIcon from "leaflet/dist/images/marker-icon.png";
import markerShadow from "leaflet/dist/images/marker-shadow.png";
import Navbar from "../components/Navbar";
import { motion } from "framer-motion";

let DefaultIcon = L.icon({
  iconUrl: markerIcon,
  shadowUrl: markerShadow,
});

L.Marker.prototype.options.icon = DefaultIcon;

function Dashboard() {
  const [data, setData] = useState([]);
  const [filtered, setFiltered] = useState([]);
  const [userLocation, setUserLocation] = useState(null);

  const [maxPrice, setMaxPrice] = useState("");
  const [minCapacity, setMinCapacity] = useState("");

  const [favorites, setFavorites] = useState([]);
  const [loading, setLoading] = useState(true);

  // ⭐ TAMBAHAN: AI WEIGHT
  const [weights, setWeights] = useState({
    distance: 0.4,
    price: 0.2,
    rating: 0.3,
    capacity: 0.1,
  });

  useEffect(() => {
    axios.get("http://127.0.0.1:8000/api/coffee-shops").then((res) => {
      setData(res.data);
      setFiltered(res.data);
      setLoading(false);
    });
  }, []);

  useEffect(() => {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        setUserLocation({
          lat: position.coords.latitude,
          lng: position.coords.longitude,
        });
      },
      (error) => {
        console.log("Gagal ambil lokasi", error);
      }
    );
  }, []);

  const toggleFavorite = (id) => {
    if (favorites.includes(id)) {
      setFavorites(favorites.filter((f) => f !== id));
    } else {
      setFavorites([...favorites, id]);
    }
  };

  const handleFilter = () => {
    let result = data;

    if (maxPrice) {
      result = result.filter((item) => item.price <= maxPrice);
    }

    if (minCapacity) {
      result = result.filter((item) => item.capacity >= minCapacity);
    }

    setFiltered(result);
  };

  function getDistance(lat1, lon1, lat2, lon2) {
    const R = 6371;
    const dLat = ((lat2 - lat1) * Math.PI) / 180;
    const dLon = ((lon2 - lon1) * Math.PI) / 180;

    const a =
      Math.sin(dLat / 2) ** 2 +
      Math.cos((lat1 * Math.PI) / 180) *
        Math.cos((lat2 * Math.PI) / 180) *
        Math.sin(dLon / 2) ** 2;

    return 2 * R * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  }

  // ⭐ TAMBAHAN: NORMALISASI
  const normalize = (value, min, max) => {
    if (max === min) return 0;
    return (value - min) / (max - min);
  };

  // ⭐ UPGRADE AI SCORING
  const getScore = (shop) => {
    if (!userLocation) return 999;

    const distances = filtered.map((s) =>
      getDistance(
        userLocation.lat,
        userLocation.lng,
        s.latitude,
        s.longitude
      )
    );

    const prices = filtered.map((s) => s.price);
    const ratings = filtered.map((s) => s.rating);
    const capacities = filtered.map((s) => s.capacity);

    const minD = Math.min(...distances);
    const maxD = Math.max(...distances);

    const minP = Math.min(...prices);
    const maxP = Math.max(...prices);

    const minR = Math.min(...ratings);
    const maxR = Math.max(...ratings);

    const minC = Math.min(...capacities);
    const maxC = Math.max(...capacities);

    const d = getDistance(
      userLocation.lat,
      userLocation.lng,
      shop.latitude,
      shop.longitude
    );

    const normDistance = normalize(d, minD, maxD);
    const normPrice = normalize(shop.price, minP, maxP);
    const normRating = normalize(shop.rating, minR, maxR);
    const normCapacity = normalize(shop.capacity, minC, maxC);

    return (
      weights.distance * normDistance +
      weights.price * normPrice +
      weights.rating * (1 - normRating) +
      weights.capacity * (1 - normCapacity)
    );
  };

  const getDistanceText = (shop) => {
    if (!userLocation) return "-";

    const d = getDistance(
      userLocation.lat,
      userLocation.lng,
      shop.latitude,
      shop.longitude
    );

    return d.toFixed(2) + " km";
  };

  const sortedShops = [...filtered].sort(
    (a, b) => getScore(a) - getScore(b)
  );

  if (loading) {
    return (
      <div className="text-center mt-20 text-lg font-semibold">
        ⏳ Loading data coffee shop...
      </div>
    );
  }

  return (
    <div className="bg-gray-100 min-h-screen">
      <Navbar />

      <div className="pt-20">
        <h2 className="text-xl font-bold p-4">
          👋 Hai {localStorage.getItem("username")}, siap ngopi hari ini?
        </h2>

        <div className="bg-gradient-to-r from-amber-600 to-amber-800 text-white p-5 shadow-lg">
          <h1 className="text-2xl font-bold text-center">☕ Coffee Finder</h1>
          <p className="text-center text-sm opacity-80">
            Temukan coffee shop terbaik berdasarkan preferensi kamu
          </p>
        </div>

        {/* FILTER */}
        <div className="p-6 bg-white shadow-md rounded-xl mx-4 mt-4 flex flex-wrap gap-4 justify-center">
          <input
            type="number"
            placeholder="💰 Harga maksimal"
            className="p-3 rounded-lg border"
            value={maxPrice}
            onChange={(e) => setMaxPrice(e.target.value)}
          />

          <input
            type="number"
            placeholder="👥 Kapasitas minimal"
            className="p-3 rounded-lg border"
            value={minCapacity}
            onChange={(e) => setMinCapacity(e.target.value)}
          />

          <button
            onClick={handleFilter}
            className="bg-amber-600 text-white px-6 py-3 rounded-lg hover:bg-amber-700 transition"
          >
            🔍 Cari Sekarang
          </button>
        </div>

        {/* ⭐ TAMBAHAN: AI CONTROL */}
        <div className="p-4 bg-white mx-4 mt-4 rounded-xl shadow">
          <h2 className="font-bold mb-2">⚙️ Prioritas AI</h2>

          <label>Jarak</label>
          <input type="range" min="0" max="1" step="0.1"
            value={weights.distance}
            onChange={(e) =>
              setWeights({ ...weights, distance: parseFloat(e.target.value) })
            }
          />

          <label>Harga</label>
          <input type="range" min="0" max="1" step="0.1"
            value={weights.price}
            onChange={(e) =>
              setWeights({ ...weights, price: parseFloat(e.target.value) })
            }
          />

          <label>Rating</label>
          <input type="range" min="0" max="1" step="0.1"
            value={weights.rating}
            onChange={(e) =>
              setWeights({ ...weights, rating: parseFloat(e.target.value) })
            }
          />

          <label>Kapasitas</label>
          <input type="range" min="0" max="1" step="0.1"
            value={weights.capacity}
            onChange={(e) =>
              setWeights({ ...weights, capacity: parseFloat(e.target.value) })
            }
          />
        </div>

        {/* SISANYA TETAP (TIDAK DIUBAH) */}

        {/* REKOMENDASI */}
        <div className="p-6">
          <h2 className="text-lg font-bold mb-2">
            🔥 Rekomendasi Terbaik
          </h2>

          {sortedShops.slice(0, 3).map((item, index) => (
            <motion.div
              key={item.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.4 }}
              className="bg-white p-4 rounded-xl shadow-lg mb-4"
            >
              <div className="flex justify-between items-center">
                <h3 className="font-bold text-lg">
                  #{index + 1} {item.name}
                </h3>

                <button onClick={() => toggleFavorite(item.id)}>
                  {favorites.includes(item.id) ? "❤️" : "🤍"}
                </button>
              </div>

              <p>⭐ Rating: {item.rating}</p>
              <p>💰 Harga: {item.price}</p>
              <p>📍 Jarak: {getDistanceText(item)}</p>

              <a
                href={`https://www.google.com/maps?q=${item.latitude},${item.longitude}`}
                target="_blank"
                className="text-blue-500 text-sm underline"
              >
                Buka di Google Maps →
              </a>
            </motion.div>
          ))}
        </div>

        {/* LIST */}
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4 p-4">
          {filtered.map((item) => (
            <div
              key={item.id}
              className="bg-white p-5 rounded-2xl shadow-md hover:shadow-xl transition"
            >
              <div className="flex justify-between">
                <h2 className="text-lg font-bold">{item.name}</h2>

                <button onClick={() => toggleFavorite(item.id)}>
                  {favorites.includes(item.id) ? "❤️" : "🤍"}
                </button>
              </div>

              <p className="text-sm text-gray-500">{item.address}</p>

              <div className="mt-3 space-y-1">
                <p>💰 Harga: {item.price}</p>
                <p>⭐ Rating: {item.rating}</p>
                <p>👥 Kapasitas: {item.capacity}</p>
                <p>📍 Jarak: {getDistanceText(item)}</p>
              </div>
            </div>
          ))}
        </div>

        {/* MAP */}
        <div className="p-4">
          <h2 className="text-lg font-bold mb-2">
            🗺️ Lihat di Map
          </h2>

          <MapContainer
            center={[-7.250445, 112.768845]}
            zoom={13}
            style={{ height: "400px", width: "100%" }}
          >
            <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />

            {filtered.map((item) => (
              <Marker
                key={item.id}
                position={[item.latitude, item.longitude]}
              >
                <Popup>
                  <b>{item.name}</b>
                </Popup>
              </Marker>
            ))}

            {userLocation && (
              <Marker position={[userLocation.lat, userLocation.lng]}>
                <Popup>Lokasi Kamu</Popup>
              </Marker>
            )}
          </MapContainer>
        </div>
      </div>
    </div>
  );
}

export default Dashboard;