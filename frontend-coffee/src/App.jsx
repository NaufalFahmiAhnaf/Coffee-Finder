import { BrowserRouter, Routes, Route } from "react-router-dom";
import Landing from "./pages/Landing";
import Dashboard from "./pages/Dashboard";
import AdminSubmissions from "./pages/AdminSubmissions";

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Landing />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/admin/submissions" element={<AdminSubmissions />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
