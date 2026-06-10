import { useState } from "react";
import { useNavigate } from "react-router-dom";

export default function Login() {
  const [name, setName] = useState("");
  const navigate = useNavigate();

  const handleLogin = () => {
    localStorage.setItem("username", name);
    navigate("/dashboard");
  };

  return (
    <div className="h-screen flex items-center justify-center bg-gradient-to-r from-amber-500 to-orange-600">
      <div className="bg-white p-8 rounded-2xl shadow-lg text-center w-80">
        <h1 className="text-2xl font-bold mb-2">☕ Coffee Finder</h1>
        <p className="text-sm mb-4">Masuk dulu bro ☕</p>

        <input
          type="text"
          placeholder="Masukkan nama kamu..."
          className="w-full p-3 border rounded-lg mb-4"
          onChange={(e) => setName(e.target.value)}
        />

        <button
          onClick={handleLogin}
          className="w-full bg-amber-600 text-white py-3 rounded-lg"
        >
          Masuk 🚀
        </button>
      </div>
    </div>
  );
}