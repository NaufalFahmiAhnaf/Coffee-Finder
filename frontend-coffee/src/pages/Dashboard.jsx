import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { MapContainer, TileLayer, Marker, Popup, useMap } from "react-leaflet";
import "leaflet/dist/leaflet.css";
import L from "leaflet";
import { motion, AnimatePresence } from "framer-motion";
import {
  Coffee,
  Search,
  MapPin,
  Plus,
  X,
  Wifi,
  Wind,
  Zap,
  Navigation,
  Star,
  Sparkles,
  SlidersHorizontal,
  Cigarette,
  LogOut,
  Map as MapIcon,
  Grid,
  Loader2,
} from "lucide-react";
import axios from "axios";
import { ToastContainer, toast } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";
import { GoogleGenAI } from "@google/genai";

delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl:
    "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon-2x.png",
  iconUrl:
    "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png",
  shadowUrl:
    "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-shadow.png",
});

const userIcon = new L.Icon({
  iconUrl: "https://cdn-icons-png.flaticon.com/512/149/149071.png",
  iconSize: [35, 35],
  iconAnchor: [17, 35],
  popupAnchor: [0, -35],
});

function MapUpdater({ center }) {
  const map = useMap();
  useEffect(() => {
    if (center) {
      // Multiple attempts to invalidate size to handle animation timing
      const timer1 = setTimeout(() => map.invalidateSize(), 100);
      const timer2 = setTimeout(() => map.invalidateSize(), 500);
      const timer3 = setTimeout(() => map.invalidateSize(), 1000);
      return () => {
        clearTimeout(timer1);
        clearTimeout(timer2);
        clearTimeout(timer3);
      };
    }
  }, [center, map]);
  return null;
}

function BoundsUpdater({ points }) {
  const map = useMap();
  useEffect(() => {
    if (points && points.length > 0) {
      const bounds = L.latLngBounds(
        points.map((p) => [p.latitude, p.longitude]),
      );
      map.fitBounds(bounds, { padding: [50, 50], maxZoom: 15 });
    }
  }, [points, map]);
  return null;
}

const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLon = ((lon2 - lon1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
    Math.cos((lat2 * Math.PI) / 180) *
    Math.sin(dLon / 2) *
    Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};

export default function Dashboard() {
  const navigate = useNavigate();
  const [username, setUsername] = useState("");
  const [userCoords, setUserCoords] = useState({
    lat: -7.250445,
    lng: 112.768845,
  });
  const [coffeeShops, setCoffeeShops] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showMap, setShowMap] = useState(true);

  const [filters, setFilters] = useState({
    q: "",
    max_price: "",
    facilities: [],
    sort_by: "rating",
  });

  const [aiQuery, setAiQuery] = useState("");
  const [isAiProcessing, setIsAiProcessing] = useState(false);
  const [showAddCafe, setShowAddCafe] = useState(false);
  const [submittingCafe, setSubmittingCafe] = useState(false);
  const [searchingAddress, setSearchingAddress] = useState(false);
  const [cafeForm, setCafeForm] = useState({
    name: "",
    description: "",
    address: "",
    price: 25000,
    rating: 4.5,
    image_url: "",
    latitude: -7.250445,
    longitude: 112.768845,
    facilities: {
      wifi: false,
      outdoor: false,
      ac: false,
      sockets: false,
      smoking_room: false,
    },
    submitted_by: "",
  });

  useEffect(() => {
    const storedUser = localStorage.getItem("coffee_user");
    const storedCoords = localStorage.getItem("coffee_coords");
    if (!storedUser) {
      navigate("/");
      return;
    }
    setUsername(storedUser);
    setCafeForm((prev) => ({
      ...prev,
      submitted_by: storedUser,
      latitude: storedCoords ? JSON.parse(storedCoords).lat : -7.250445,
      longitude: storedCoords ? JSON.parse(storedCoords).lng : 112.768845,
    }));
    if (storedCoords) {
      setUserCoords(JSON.parse(storedCoords));
    }
    fetchCoffeeShops(filters);
  }, [navigate]);

  const fetchCoffeeShops = async (currentFilters) => {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      if (userCoords?.lat) params.append("lat", userCoords.lat);
      if (userCoords?.lng) params.append("lng", userCoords.lng);

      if (currentFilters.q) params.append("q", currentFilters.q);
      if (currentFilters.max_price && currentFilters.max_price > 0)
        params.append("max_price", currentFilters.max_price);

      if (currentFilters.sort_by && currentFilters.sort_by !== "nearest") {
        params.append("sort_by", currentFilters.sort_by);
      }
      if (currentFilters.facilities.length > 0) {
        currentFilters.facilities.forEach((f) =>
          params.append("facilities[]", f),
        );
      }

      const res = await axios.get(`/api/coffee-shops?${params.toString()}`);
      // Accessing res.data.data because the backend returns { status, total, data }
      let data = res.data.data;

      if (!Array.isArray(data)) {
        console.error("Invalid data received from API:", res.data);
        setCoffeeShops([]);
        return;
      }

      // Add distance to each shop
      data = data.map((shop) => ({
        ...shop,
        distance: calculateDistance(
          userCoords?.lat || -7.250445,
          userCoords?.lng || 112.768845,
          shop.latitude,
          shop.longitude,
        ),
      }));

      // Sort nearest if selected
      if (currentFilters.sort_by === "nearest") {
        data.sort((a, b) => a.distance - b.distance);
      }

      setCoffeeShops(data);
    } catch (error) {
      console.error("Failed to fetch coffee shops:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleFilterChange = (key, value) => {
    const newFilters = { ...filters, [key]: value };
    setFilters(newFilters);
    fetchCoffeeShops(newFilters);
  };

  const toggleFacility = (facility) => {
    const isSelected = filters.facilities.includes(facility);
    const newFacilities = isSelected
      ? filters.facilities.filter((f) => f !== facility)
      : [...filters.facilities, facility];
    handleFilterChange("facilities", newFacilities);
  };

  // ==========================
  // AI Smart Search Handler
  // ==========================

  const handleAiSearch = async () => {
    if (!aiQuery) return;
    setIsAiProcessing(true);

    try {
      const apiKey = import.meta.env.VITE_GEMINI_API_KEY;
      let detectedFilters = { q: "", facilities: [], max_price: "" };

      if (apiKey) {
        const ai = new GoogleGenAI({ apiKey });
        const prompt = `
          Extract coffee shop preferences from this text: "${aiQuery}".
          Return a strict JSON object with these keys:
          - q: (string, if they mention a specific name or keyword, else empty)
          - facilities: (array of strings, choose only from: ["wifi", "outdoor", "ac", "sockets", "smoking_room"])
          - max_price: (number, if they mention a max price like 'under 50k' -> 50000, else empty string)
          Only return the JSON, no markdown.
        `;
        const response = await ai.models.generateContent({
          model: "gemini-1.5-flash",
          contents: prompt,
        });
        const text = response
          .text()
          .replace(/```json/g, "")
          .replace(/```/g, "")
          .trim();
        detectedFilters = JSON.parse(text);
      } else {
        const lowerQ = aiQuery.toLowerCase();
        if (lowerQ.includes("wifi")) detectedFilters.facilities.push("wifi");
        if (lowerQ.includes("outdoor") || lowerQ.includes("luar"))
          detectedFilters.facilities.push("outdoor");
        if (
          lowerQ.includes("ac") ||
          lowerQ.includes("dingin") ||
          lowerQ.includes("indoor")
        )
          detectedFilters.facilities.push("ac");
        if (lowerQ.includes("colokan") || lowerQ.includes("ngecas"))
          detectedFilters.facilities.push("sockets");
        if (lowerQ.includes("rokok") || lowerQ.includes("smoking"))
          detectedFilters.facilities.push("smoking_room");

        const priceMatch = lowerQ.match(/(\d+)\s*(rb|ribu|k)/);
        if (priceMatch) {
          detectedFilters.max_price = parseInt(priceMatch[1]) * 1000;
        }
      }

      const newFilters = {
        ...filters,
        facilities: detectedFilters.facilities,
        max_price: detectedFilters.max_price,
        q: detectedFilters.q,
      };
      setFilters(newFilters);
      fetchCoffeeShops(newFilters);
      setAiQuery("");
    } catch (err) {
      console.error("AI Error:", err);
      alert("AI Processing Failed. Please try manual filters.");
    } finally {
      setIsAiProcessing(false);
    }
  };

  const openGoogleMaps = (latitude, longitude) => {
    const query = encodeURIComponent(`${latitude},${longitude}`);
    const url = `https://www.google.com/maps/search/?api=1&query=${query}`;
    window.open(url, "_blank");
  };

  const handleCafeFormChange = (field, value) => {
    setCafeForm((prev) => ({
      ...prev,
      [field]: value,
    }));
  };

  const toggleCafeFacility = (facility) => {
    setCafeForm((prev) => ({
      ...prev,
      facilities: {
        ...prev.facilities,
        [facility]: !prev.facilities[facility],
      },
    }));
  };

  const handleGetCurrentLocation = () => {
    if (!navigator.geolocation) {
      alert("Geolocation tidak didukung oleh browser Anda.");
      return;
    }
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords;
        setCafeForm((prev) => ({
          ...prev,
          latitude: Number(latitude.toFixed(6)),
          longitude: Number(longitude.toFixed(6)),
        }));
      },
      (error) => {
        console.error("Error getting location:", error);
        alert("Gagal mendapatkan lokasi Anda. Pastikan izin lokasi telah diaktifkan.");
      }
    );
  };

  const handleSearchCoordsFromAddress = async () => {
    if (!cafeForm.address) {
      alert("Silakan isi alamat terlebih dahulu.");
      return;
    }
    setSearchingAddress(true);
    try {
      const response = await axios.get(
        "https://nominatim.openstreetmap.org/search",
        {
          params: {
            q: cafeForm.address,
            format: "json",
            limit: 1,
          },
        }
      );
      if (response.data && response.data.length > 0) {
        const result = response.data[0];
        setCafeForm((prev) => ({
          ...prev,
          latitude: Number(parseFloat(result.lat).toFixed(6)),
          longitude: Number(parseFloat(result.lon).toFixed(6)),
        }));
      } else {
        alert("Koordinat tidak ditemukan untuk alamat tersebut. Silakan periksa kembali detail alamat Anda.");
      }
    } catch (error) {
      console.error("Geocoding error:", error);
      alert("Gagal mencari koordinat. Silakan coba lagi atau isi koordinat secara manual.");
    } finally {
      setSearchingAddress(false);
    }
  };

  const submitCafeRequest = async (e) => {
    e.preventDefault();
    setSubmittingCafe(true);

    try {
      await axios.post("/api/coffee-shop-submissions", {
        ...cafeForm,
        price: Number(cafeForm.price),
        rating: Number(cafeForm.rating),
        latitude: Number(cafeForm.latitude),
        longitude: Number(cafeForm.longitude),
        facilities: Object.fromEntries(
          Object.entries(cafeForm.facilities).filter(([, enabled]) => enabled),
        ),
      });

      toast.success(
        "Cafe request sent successfully. It will be reviewed by the admin.",
      );
      setShowAddCafe(false);
      setCafeForm((prev) => ({
        ...prev,
        name: "",
        description: "",
        address: "",
        price: 25000,
        rating: 4.5,
        image_url: "",
        facilities: {
          wifi: false,
          outdoor: false,
          ac: false,
          sockets: false,
          smoking_room: false,
        },
      }));
    } catch (error) {
      console.error("Failed to submit cafe request:", error);
      const serverMsg = error.response?.data?.message || "Unable to submit cafe request right now. Please try again.";
        toast.error(serverMsg);
    } finally {
      setSubmittingCafe(false);
    }
  };

  const facilityIcons = {
    wifi: <Wifi className="w-4 h-4" />,
    outdoor: <Wind className="w-4 h-4" />,
    ac: <Wind className="w-4 h-4" />,
    sockets: <Zap className="w-4 h-4" />,
    smoking_room: <Cigarette className="w-4 h-4" />,
  };

  return (
    <div className="min-h-screen bg-background font-sans flex flex-col">
        <ToastContainer position="top-center" autoClose={3000} />
      {/* TOP NAVIGATION BAR */}
      <header className="bg-surface border-b border-gray-200 sticky top-0 z-50 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-20">
            {/* Logo */}
            <div className="flex items-center gap-3">
              <div className="bg-primary/10 p-2.5 rounded-xl border border-primary/20">
                <Coffee className="text-primary w-7 h-7" />
              </div>
              <span className="text-2xl font-black text-textMain tracking-tight">
                Coffe<span className="text-primary">Track</span>
              </span>
            </div>

            {/* AI Search Bar */}
            <div className="hidden md:flex flex-1 max-w-xl mx-8">
              <div className="w-full flex items-center bg-gray-50 border border-gray-200 rounded-2xl p-1.5 focus-within:border-primary focus-within:ring-2 focus-within:ring-primary/20 transition-all shadow-sm">
                <div className="pl-4 pr-2">
                  <Sparkles className="w-5 h-5 text-primary" />
                </div>
                <input
                  type="text"
                  placeholder="AI Smart Search: 'Cafe nyaman ada colokan under 30k'"
                  className="flex-1 bg-transparent border-none focus:outline-none text-textMain placeholder:text-textMuted text-sm py-2"
                  value={aiQuery}
                  onChange={(e) => setAiQuery(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && handleAiSearch()}
                />
                <button
                  onClick={handleAiSearch}
                  disabled={isAiProcessing}
                  className="bg-primary hover:bg-primary-hover text-white px-6 py-2.5 rounded-xl font-bold text-sm transition-all shadow-md hover:shadow-lg disabled:opacity-70"
                >
                  {isAiProcessing ? "Wait..." : "Find"}
                </button>
              </div>
            </div>

            {/* User Profile */}
            <div className="flex items-center gap-4">
              <div className="hidden lg:block text-right">
                <p className="text-sm font-bold text-textMain leading-tight">
                  {username}
                </p>
                <p className="text-xs text-textMuted font-medium">
                  Coffee Explorer
                </p>
              </div>
              <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-primary to-amber-500 flex items-center justify-center text-white font-bold text-lg shadow-md">
                {username.charAt(0).toUpperCase()}
              </div>
              <button
                onClick={() => setShowAddCafe(true)}
                className="inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2 text-sm font-semibold text-white shadow-md transition hover:bg-primary-hover"
              >
                <Plus className="w-4 h-4" />
                Add Cafe
              </button>
              <button
                onClick={() => {
                  localStorage.clear();
                  navigate("/");
                }}
                className="p-2 text-textMuted hover:text-red-500 transition-colors bg-gray-50 rounded-full hover:bg-red-50"
                title="Logout"
              >
                <LogOut className="w-5 h-5" />
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* MOBILE AI SEARCH */}
      <div className="md:hidden p-4 bg-surface border-b border-gray-200">
        <div className="w-full flex items-center bg-gray-50 border border-gray-200 rounded-xl p-1 focus-within:border-primary transition-all">
          <input
            type="text"
            placeholder="AI Search..."
            className="flex-1 bg-transparent border-none focus:outline-none px-4 text-sm"
            value={aiQuery}
            onChange={(e) => setAiQuery(e.target.value)}
          />
          <button
            onClick={handleAiSearch}
            className="bg-primary text-white p-2 rounded-lg"
          >
            <Search className="w-4 h-4" />
          </button>
        </div>
      </div>

      <main className="flex-1 w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 flex flex-col gap-8">
        {showAddCafe && (
          <section className="rounded-3xl border border-gray-100 bg-surface p-6 shadow-sm">
            <div className="flex items-center justify-between gap-3">
              <div>
                <p className="text-sm font-semibold uppercase tracking-[0.25em] text-primary">
                  User Submission
                </p>
                <h2 className="mt-1 text-2xl font-black text-textMain">
                  Add a new cafe request
                </h2>
                <p className="text-sm text-textMuted">
                  This sends your suggestion to the backend review flow.
                </p>
              </div>
              <button
                onClick={() => setShowAddCafe(false)}
                className="rounded-2xl border border-gray-200 bg-background p-2 text-textMuted transition hover:border-primary hover:text-primary"
                aria-label="Close add cafe form"
              >
                <X className="h-4 w-4" />
              </button>
            </div>

            <form
              onSubmit={submitCafeRequest}
              className="mt-6 grid gap-6 lg:grid-cols-2"
            >
              <label className="grid gap-2 text-sm font-semibold text-textMain">
                Cafe name
                <input
                  required
                  value={cafeForm.name}
                  onChange={(e) => handleCafeFormChange("name", e.target.value)}
                  className="rounded-2xl border border-gray-200 bg-background px-4 py-3 text-sm text-textMain outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/20"
                  placeholder="e.g. Morning Bean"
                />
              </label>
              <label className="grid gap-2 text-sm font-semibold text-textMain">
                Address
                <input
                  required
                  value={cafeForm.address}
                  onChange={(e) =>
                    handleCafeFormChange("address", e.target.value)
                  }
                  className="rounded-2xl border border-gray-200 bg-background px-4 py-3 text-sm text-textMain outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/20"
                  placeholder="Jl. Example No. 1"
                />
              </label>
              <label className="grid gap-2 text-sm font-semibold text-textMain">
                Description
                <textarea
                  value={cafeForm.description}
                  onChange={(e) =>
                    handleCafeFormChange("description", e.target.value)
                  }
                  className="rounded-2xl border border-gray-200 bg-background px-4 py-3 text-sm text-textMain outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/20"
                  rows="3"
                  placeholder="Tell us what makes this cafe special"
                />
              </label>
              <label className="grid gap-2 text-sm font-semibold text-textMain">
                Image URL
                <input
                  value={cafeForm.image_url}
                  onChange={(e) =>
                    handleCafeFormChange("image_url", e.target.value)
                  }
                  className="rounded-2xl border border-gray-200 bg-background px-4 py-3 text-sm text-textMain outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/20"
                  placeholder="https://example.com/cafe.jpg"
                />
              </label>
              <label className="grid gap-2 text-sm font-semibold text-textMain">
                Price (Rp)
                <input
                  type="number"
                  min="0"
                  required
                  value={cafeForm.price}
                  onChange={(e) =>
                    handleCafeFormChange("price", e.target.value)
                  }
                  className="rounded-2xl border border-gray-200 bg-background px-4 py-3 text-sm text-textMain outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/20"
                />
              </label>
              <label className="grid gap-2 text-sm font-semibold text-textMain">
                Rating (0-5)
                <input
                  type="number"
                  min="0"
                  max="5"
                  step="0.1"
                  required
                  value={cafeForm.rating}
                  onChange={(e) =>
                    handleCafeFormChange("rating", e.target.value)
                  }
                  className="rounded-2xl border border-gray-200 bg-background px-4 py-3 text-sm text-textMain outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/20"
                />
              </label>
              <div className="lg:col-span-2 flex flex-wrap gap-3 mt-2">
                <button
                  type="button"
                  onClick={handleGetCurrentLocation}
                  className="inline-flex items-center gap-2 rounded-xl border border-gray-200 bg-surface px-4 py-2.5 text-xs font-semibold text-textMain transition hover:border-primary hover:text-primary hover:bg-orange-50/50 shadow-sm"
                >
                  <MapPin className="w-4 h-4 text-primary" />
                  Gunakan Lokasi Saat Ini
                </button>
                <button
                  type="button"
                  onClick={handleSearchCoordsFromAddress}
                  disabled={searchingAddress}
                  className="inline-flex items-center gap-2 rounded-xl border border-gray-200 bg-surface px-4 py-2.5 text-xs font-semibold text-textMain transition hover:border-primary hover:text-primary hover:bg-orange-50/50 disabled:opacity-50 shadow-sm"
                >
                  {searchingAddress ? (
                    <Loader2 className="w-4 h-4 animate-spin text-primary" />
                  ) : (
                    <Search className="w-4 h-4 text-primary" />
                  )}
                  {searchingAddress ? "Mencari Koordinat..." : "Cari Koordinat dari Alamat"}
                </button>
              </div>

              <label className="grid gap-2 text-sm font-semibold text-textMain">
                Latitude
                <input
                  type="number"
                  step="0.0001"
                  required
                  value={cafeForm.latitude}
                  onChange={(e) =>
                    handleCafeFormChange("latitude", e.target.value)
                  }
                  className="rounded-2xl border border-gray-200 bg-background px-4 py-3 text-sm text-textMain outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/20"
                />
              </label>
              <label className="grid gap-2 text-sm font-semibold text-textMain">
                Longitude
                <input
                  type="number"
                  step="0.0001"
                  required
                  value={cafeForm.longitude}
                  onChange={(e) =>
                    handleCafeFormChange("longitude", e.target.value)
                  }
                  className="rounded-2xl border border-gray-200 bg-background px-4 py-3 text-sm text-textMain outline-none transition focus:border-primary focus:ring-2 focus:ring-primary/20"
                />
              </label>

              <div className="lg:col-span-2">
                <p className="mb-3 text-sm font-semibold text-textMain">
                  Facilities
                </p>
                <div className="flex flex-wrap gap-2">
                  {Object.keys(cafeForm.facilities).map((facility) => (
                    <button
                      key={facility}
                      type="button"
                      onClick={() => toggleCafeFacility(facility)}
                      className={`rounded-xl border px-3 py-2 text-xs font-semibold capitalize transition ${cafeForm.facilities[facility] ? "border-primary bg-primary text-white" : "border-gray-200 bg-background text-textMuted hover:border-primary/50 hover:bg-orange-50"}`}
                    >
                      {facility.replace("_", " ")}
                    </button>
                  ))}
                </div>
              </div>

              <div className="lg:col-span-2 flex items-center justify-end gap-3">
                <button
                  type="button"
                  onClick={() => setShowAddCafe(false)}
                  className="rounded-2xl border border-gray-200 bg-background px-4 py-2 text-sm font-semibold text-textMain transition hover:border-primary hover:text-primary"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={submittingCafe}
                  className="inline-flex items-center gap-2 rounded-2xl bg-primary px-4 py-2 text-sm font-semibold text-white transition hover:bg-primary-hover disabled:cursor-not-allowed disabled:opacity-70"
                >
                  {submittingCafe ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    <Plus className="h-4 w-4" />
                  )}
                  {submittingCafe ? "Submitting..." : "Send request"}
                </button>
              </div>
            </form>
          </section>
        )}
        {/* FILTERS & CONTROLS */}
        <section className="bg-surface p-6 rounded-3xl border border-gray-100 shadow-sm flex flex-col lg:flex-row gap-6 items-start lg:items-center justify-between">
          <div className="flex flex-wrap gap-4 items-center flex-1">
            <div className="flex items-center gap-2 mr-4">
              <SlidersHorizontal className="w-5 h-5 text-primary" />
              <span className="font-bold text-textMain">Filters:</span>
            </div>

            {/* Manual Price Input */}
            <div className="flex items-center gap-2 bg-gray-50 rounded-xl px-3 py-2 border border-gray-200 focus-within:border-primary transition-colors">
              <span className="text-sm font-semibold text-textMuted">
                Max Rp
              </span>
              <input
                type="number"
                placeholder="e.g. 50000"
                value={filters.max_price}
                onChange={(e) =>
                  handleFilterChange("max_price", e.target.value)
                }
                className="bg-transparent border-none w-24 text-sm font-bold text-textMain focus:outline-none"
              />
            </div>

            {/* Sort Dropdown */}
            <div className="flex items-center gap-2">
              <select
                value={filters.sort_by}
                onChange={(e) => handleFilterChange("sort_by", e.target.value)}
                className="bg-gray-50 border border-gray-200 rounded-xl text-sm font-semibold text-textMain px-4 py-2 focus:border-primary focus:outline-none cursor-pointer"
              >
                <option value="nearest">📍 Terdekat dari Saya</option>
                <option value="rating">⭐ Rating Tertinggi</option>
                <option value="price_asc">💵 Harga Termurah</option>
                <option value="price_desc">💎 Harga Termahal</option>
              </select>
            </div>

            {/* Facilities Toggle */}
            <div className="flex flex-wrap gap-2 lg:ml-4">
              {["wifi", "outdoor", "ac", "sockets", "smoking_room"].map(
                (fac) => (
                  <button
                    key={fac}
                    onClick={() => toggleFacility(fac)}
                    className={`text-xs px-3 py-2 rounded-xl border transition-all flex items-center gap-1.5 font-semibold ${filters.facilities.includes(fac)
                        ? "bg-primary border-primary text-white shadow-md shadow-primary/20"
                        : "bg-surface border-gray-200 text-textMuted hover:border-primary/50 hover:bg-orange-50"
                      }`}
                  >
                    {facilityIcons[fac]}
                    <span className="capitalize hidden sm:block">
                      {fac.replace("_", " ")}
                    </span>
                  </button>
                ),
              )}
            </div>
          </div>

          <div className="flex items-center gap-3">
            <button
              onClick={() => setShowMap(!showMap)}
              className={`px-4 py-2.5 rounded-xl font-bold text-sm flex items-center gap-2 transition-all border ${showMap
                  ? "bg-textMain text-white border-textMain"
                  : "bg-surface text-textMain border-gray-200 hover:bg-gray-50"
                }`}
            >
              {showMap ? (
                <Grid className="w-4 h-4" />
              ) : (
                <MapIcon className="w-4 h-4" />
              )}
              {showMap ? "Hide Map" : "Show Map"}
            </button>
          </div>
        </section>

        {/* MAPS SECTION (TOGGLEABLE) */}
        <AnimatePresence>
          {showMap && (
            <motion.section
              initial={{ height: 0, opacity: 0 }}
              animate={{ height: 400, opacity: 1 }}
              exit={{ height: 0, opacity: 0 }}
              className="w-full rounded-3xl overflow-hidden shadow-lg border border-gray-200 z-0 relative"
            >
              <MapContainer
                center={[userCoords?.lat || -7.25, userCoords?.lng || 112.76]}
                zoom={12}
                style={{ height: "400px", width: "100%", zIndex: 1 }}
              >
                <TileLayer
                  url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                  attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OSM</a>'
                />
                <MapUpdater
                  center={[userCoords?.lat || -7.25, userCoords?.lng || 112.76]}
                />
                <BoundsUpdater
                  points={coffeeShops.filter((s) => s.latitude && s.longitude)}
                />

                <Marker
                  position={[
                    userCoords?.lat || -7.25,
                    userCoords?.lng || 112.76,
                  ]}
                  icon={userIcon}
                >
                  <Popup>
                    <div className="font-bold text-primary text-center">
                      Lokasi Anda
                    </div>
                  </Popup>
                </Marker>

                {coffeeShops
                  .filter((s) => s.latitude && s.longitude)
                  .map((shop) => (
                    <Marker
                      key={shop.id}
                      position={[shop.latitude, shop.longitude]}
                    >
                      <Popup>
                        <div className="font-sans">
                          <h4 className="font-bold text-textMain m-0 text-base">
                            {shop.name}
                          </h4>
                          <p className="text-primary font-bold m-0 mt-1 flex items-center gap-1 text-sm">
                            <Star className="w-3 h-3 fill-primary" />{" "}
                            {shop.rating}
                          </p>
                          <button
                            onClick={(e) => {
                              e.preventDefault();
                              openGoogleMaps(shop.latitude, shop.longitude);
                            }}
                            className="mt-3 w-full bg-primary hover:bg-primary-hover text-white rounded-lg p-2 text-xs font-bold border-none cursor-pointer transition-colors"
                          >
                            Direction
                          </button>
                        </div>
                      </Popup>
                    </Marker>
                  ))}
              </MapContainer>
            </motion.section>
          )}
        </AnimatePresence>

        {/* RESULTS GRID */}
        <section>
          <div className="flex items-center justify-between mb-6 px-2">
            <h2 className="text-2xl font-black text-textMain">
              Rekomendasi Kafe
            </h2>
            <span className="bg-primary/10 text-primary px-3 py-1 rounded-full text-sm font-bold border border-primary/20">
              {coffeeShops.length} Places
            </span>
          </div>

          {loading ? (
            <div className="flex items-center justify-center py-20 text-primary font-bold">
              <Loader2 className="w-8 h-8 animate-spin mr-3" /> Fetching best
              spots...
            </div>
          ) : coffeeShops.length === 0 ? (
            <div className="text-center py-20 bg-surface rounded-3xl border border-gray-100">
              <Coffee className="w-16 h-16 text-gray-300 mx-auto mb-4" />
              <h3 className="text-xl font-bold text-textMain mb-2">
                Tidak ada yang cocok
              </h3>
              <p className="text-textMuted">
                Coba ganti filter atau naikkan rentang harga Anda.
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 pb-20">
              {coffeeShops.map((shop, idx) => (
                <motion.div
                  initial={{ opacity: 0, scale: 0.95 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ delay: idx * 0.05 }}
                  key={shop.id}
                  className="bg-surface rounded-3xl overflow-hidden border border-gray-100 shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all group flex flex-col"
                >
                  <div className="h-48 overflow-hidden relative">
                    <img
                      src={
                        shop.image_url ||
                        "https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=500&q=80"
                      }
                      alt={shop.name}
                      className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                    />
                    <div className="absolute top-3 right-3 bg-white/90 backdrop-blur-sm px-2.5 py-1 rounded-xl flex items-center gap-1 shadow-sm">
                      <Star className="w-4 h-4 fill-amber-400 text-amber-400" />
                      <span className="font-bold text-sm text-textMain">
                        {shop.rating}
                      </span>
                    </div>
                  </div>

                  <div className="p-5 flex-1 flex flex-col">
                    <h4 className="text-xl font-black text-textMain mb-1 line-clamp-1">
                      {shop.name}
                    </h4>
                    <p className="text-xs font-medium text-textMuted line-clamp-1 mb-4">
                      {shop.address}
                    </p>

                    <div className="flex items-center gap-3 mb-4 mt-auto">
                      <span className="bg-orange-50 text-primary px-3 py-1.5 rounded-lg text-sm font-bold border border-orange-100">
                        Rp {(shop.price / 1000).toFixed(0)}k
                      </span>
                      <span className="flex items-center gap-1 text-sm font-bold text-textMuted bg-gray-50 px-3 py-1.5 rounded-lg border border-gray-100">
                        <Navigation className="w-4 h-4 text-primary" />
                        {shop.distance.toFixed(1)} km
                      </span>
                    </div>

                    <div className="flex gap-2 mb-5">
                      {shop.facilities &&
                        Object.entries(shop.facilities).map(([key, value]) => {
                          if (value && facilityIcons[key]) {
                            return (
                              <div
                                key={key}
                                className="text-textMuted p-1.5 bg-gray-50 rounded-lg border border-gray-100"
                                title={key}
                              >
                                {facilityIcons[key]}
                              </div>
                            );
                          }
                          return null;
                        })}
                    </div>

                    <button
                      onClick={() => openGoogleMaps(shop.latitude, shop.longitude)}
                      className="w-full bg-textMain hover:bg-black text-white rounded-xl py-3 text-sm font-bold flex items-center justify-center gap-2 transition-colors mt-auto shadow-md"
                    >
                      <MapPin className="w-4 h-4 text-primary" />
                      Open in Google Maps
                    </button>
                  </div>
                </motion.div>
              ))}
            </div>
          )}
        </section>
      </main>
    </div>
  );
}
