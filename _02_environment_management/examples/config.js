/**
 * Centralized Configuration Module
 * 
 * All environment variables should be accessed through this file.
 * This ensures:
 * 1. Single source of truth for configuration
 * 2. Easy validation of required variables
 * 3. Type coercion (string → boolean, number)
 * 4. Sensible defaults
 */

const config = {
  // API Configuration
  api: {
    baseUrl: import.meta.env.VITE_API_URL || 'http://localhost:3001/api',
    timeout: parseInt(import.meta.env.VITE_API_TIMEOUT || '10000', 10),
  },

  // App Metadata
  app: {
    title: import.meta.env.VITE_APP_TITLE || 'My React App',
    version: import.meta.env.VITE_APP_VERSION || '0.0.0',
  },

  // Feature Flags
  features: {
    debug: import.meta.env.VITE_ENABLE_DEBUG === 'true',
    mockData: import.meta.env.VITE_ENABLE_MOCK_DATA === 'true',
  },

  // Analytics
  analytics: {
    enabled: import.meta.env.VITE_ANALYTICS_ENABLED === 'true',
    id: import.meta.env.VITE_ANALYTICS_ID || '',
  },

  // Built-in Vite environment info
  isDevelopment: import.meta.env.DEV,
  isProduction: import.meta.env.PROD,
  mode: import.meta.env.MODE,
};

// Validate required config in production
if (config.isProduction) {
  const requiredKeys = [
    { key: 'api.baseUrl', value: config.api.baseUrl },
  ];

  requiredKeys.forEach(({ key, value }) => {
    if (!value) {
      throw new Error(`❌ Missing required environment variable for: ${key}`);
    }
  });
}

export default config;
