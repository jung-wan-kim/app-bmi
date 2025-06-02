import { createClient } from '@supabase/supabase-js';
import * as SecureStore from 'expo-secure-store';

const supabaseUrl = 'https://puoscoaltsznczqdfjh.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB1b3Njb2FsdHN6bmN6cWRmamgiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTczMjg2MDk2NSwiZXhwIjoyMDQ4NDM2OTY1fQ.P2FrZXJdcds7O7enI2qLrO-qCgBKu-51lzoMfBU6Nxo';

// Expo SecureStore adapter for Supabase
const ExpoSecureStoreAdapter = {
  getItem: (key) => {
    return SecureStore.getItemAsync(key);
  },
  setItem: (key, value) => {
    SecureStore.setItemAsync(key, value);
  },
  removeItem: (key) => {
    SecureStore.deleteItemAsync(key);
  },
};

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: ExpoSecureStoreAdapter,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});