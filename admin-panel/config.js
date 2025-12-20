// API Configuration
const API_CONFIG = {
    BASE_URL: 'http://localhost:3000/api', // Change this to your API URL
    // For production: 'https://api.dalla3ni.com/api'
};

// Export for use in app.js
if (typeof module !== 'undefined' && module.exports) {
    module.exports = API_CONFIG;
}

