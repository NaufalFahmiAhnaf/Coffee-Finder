import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { MapPin, ArrowRight, Loader2 } from 'lucide-react';

export default function Landing() {
  const [username, setUsername] = useState('');
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const navigate = useNavigate();

  const handleEnter = (e) => {
    e.preventDefault();
    if (!username) {
        setErrorMsg('Please enter your username');
        return;
    }
    
    setLoading(true);
    setErrorMsg('');

    if ("geolocation" in navigator) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setLoading(false);
          const coords = {
            lat: position.coords.latitude,
            lng: position.coords.longitude
          };
          localStorage.setItem('coffee_user', username);
          localStorage.setItem('coffee_coords', JSON.stringify(coords));
          navigate('/dashboard');
        },
        (error) => {
          setLoading(false);
          // Default Surabaya
          const defaultCoords = { lat: -7.250445, lng: 112.768845 };
          localStorage.setItem('coffee_user', username);
          localStorage.setItem('coffee_coords', JSON.stringify(defaultCoords));
          navigate('/dashboard');
        }
      );
    } else {
      setLoading(false);
      setErrorMsg('Geolocation is not supported by your browser.');
    }
  };

  return (
    <div className="min-h-screen bg-background flex flex-col items-center justify-center relative overflow-hidden">
      <div className="absolute top-[-10%] left-[-10%] w-96 h-96 bg-primary/20 rounded-full blur-[100px]" />
      <div className="absolute bottom-[-10%] right-[-10%] w-96 h-96 bg-primary/20 rounded-full blur-[100px]" />
      
      <motion.div 
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8 }}
        className="z-10 w-full max-w-md px-6"
      >
        <div className="text-center mb-10">
          <motion.div 
            initial={{ scale: 0.8 }}
            animate={{ scale: 1 }}
            transition={{ delay: 0.3, type: "spring" }}
            className="w-20 h-20 bg-surface rounded-3xl mx-auto flex items-center justify-center mb-6 shadow-xl border border-gray-100"
          >
             <MapPin className="text-primary w-10 h-10" />
          </motion.div>
          <h1 className="text-4xl font-bold text-textMain mb-3 tracking-tight">
            Coffee<span className="text-primary">Track</span>
          </h1>
          <p className="text-textMuted text-sm font-medium">
            Discover premium coffee experiences around you
          </p>
        </div>

        <form onSubmit={handleEnter} className="space-y-6 bg-surface p-8 rounded-[2rem] border border-gray-100 shadow-2xl">
          <div>
            <label className="block text-xs font-bold text-textMuted uppercase tracking-wider mb-2">
              How should we call you?
            </label>
            <input
              type="text"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              placeholder="Enter your name"
              className="w-full bg-background border border-gray-200 rounded-2xl px-4 py-4 text-textMain placeholder:text-textMuted/50 focus:outline-none focus:ring-4 focus:ring-primary/20 focus:border-primary transition-all font-medium"
            />
          </div>

          {errorMsg && (
            <motion.p 
              initial={{ opacity: 0 }} 
              animate={{ opacity: 1 }} 
              className="text-red-500 text-sm text-center font-medium"
            >
              {errorMsg}
            </motion.p>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-primary hover:bg-primary-hover text-white font-bold rounded-2xl px-4 py-4 flex items-center justify-center gap-2 transition-all disabled:opacity-70 shadow-lg shadow-primary/30 hover:shadow-primary/50 hover:-translate-y-0.5"
          >
            {loading ? (
              <>
                <Loader2 className="w-5 h-5 animate-spin" />
                Detecting Location...
              </>
            ) : (
              <>
                Find Nearby Coffee
                <ArrowRight className="w-5 h-5" />
              </>
            )}
          </button>
        </form>
      </motion.div>
    </div>
  );
}
