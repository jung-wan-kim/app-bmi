import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { StatusBar } from 'expo-status-bar';
import { View, Text, StyleSheet } from 'react-native';
import 'react-native-url-polyfill/auto';

// Import screens
import HomeScreen from './src/screens/HomeScreen';
import DiscoverScreen from './src/screens/DiscoverScreen';
import UploadScreen from './src/screens/UploadScreen';
import InboxScreen from './src/screens/InboxScreen';
import ProfileScreen from './src/screens/ProfileScreen';

// Import icons
import HomeIcon from './src/components/icons/HomeIcon';
import DiscoverIcon from './src/components/icons/DiscoverIcon';
import UploadButton from './src/components/icons/UploadButton';
import InboxIcon from './src/components/icons/InboxIcon';
import ProfileIcon from './src/components/icons/ProfileIcon';

// Import Supabase config
import './src/config/supabase';

const Tab = createBottomTabNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <StatusBar style="light" />
      <Tab.Navigator
        screenOptions={{
          tabBarStyle: {
            backgroundColor: '#000',
            borderTopColor: '#333',
            height: 85,
            paddingBottom: 10,
          },
          tabBarActiveTintColor: '#fff',
          tabBarInactiveTintColor: '#8e8e8e',
          headerShown: false,
        }}
      >
        <Tab.Screen
          name="Home"
          component={HomeScreen}
          options={{
            tabBarIcon: ({ color, focused }) => (
              <HomeIcon color={color} focused={focused} />
            ),
          }}
        />
        <Tab.Screen
          name="Discover"
          component={DiscoverScreen}
          options={{
            tabBarIcon: ({ color, focused }) => (
              <DiscoverIcon color={color} focused={focused} />
            ),
          }}
        />
        <Tab.Screen
          name="Upload"
          component={UploadScreen}
          options={{
            tabBarLabel: () => null,
            tabBarIcon: ({ focused }) => (
              <UploadButton focused={focused} />
            ),
          }}
        />
        <Tab.Screen
          name="Inbox"
          component={InboxScreen}
          options={{
            tabBarIcon: ({ color, focused }) => (
              <InboxIcon color={color} focused={focused} />
            ),
          }}
        />
        <Tab.Screen
          name="Me"
          component={ProfileScreen}
          options={{
            tabBarIcon: ({ color, focused }) => (
              <ProfileIcon color={color} focused={focused} />
            ),
          }}
        />
      </Tab.Navigator>
    </NavigationContainer>
  );
}