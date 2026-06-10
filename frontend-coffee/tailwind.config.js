/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,jsx}",
  ],
  theme: {
    extend: {
      colors: {
        background: '#FDFBF7', // Cream / Off-white
        surface: '#FFFFFF',
        primary: '#E67E22', // Vibrant Orange / Caramel
        'primary-hover': '#D35400',
        textMain: '#2C3E50', // Deep Coffee Brown
        textMuted: '#7F8C8D',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      }
    },
  },
  plugins: [],
}