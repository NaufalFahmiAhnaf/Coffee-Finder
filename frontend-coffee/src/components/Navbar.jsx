export default function Navbar() {
const username = localStorage.getItem("username");

return (
    <div className="fixed top-0 left-0 w-full bg-white shadow-md p-4 flex justify-between z-50">
    <h1 className="font-bold">☕ Coffee Finder</h1>
    <p className="text-sm">Hi, {username} 👋</p>
    </div>
);
}