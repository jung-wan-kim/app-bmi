import React from 'react';
import { View } from 'react-native';
import Svg, { Rect, Defs, LinearGradient, Stop, Path } from 'react-native-svg';

const UploadButton = ({ focused = false }) => {
  return (
    <View style={{ width: 45, height: 30, position: 'relative' }}>
      <Svg width="45" height="30" viewBox="0 0 45 30" fill="none" style={{ position: 'absolute' }}>
        <Defs>
          <LinearGradient id="leftGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <Stop offset="0%" stopColor="#00F2EA" />
            <Stop offset="100%" stopColor="#00D4E0" />
          </LinearGradient>
          <LinearGradient id="rightGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <Stop offset="0%" stopColor="#FF0050" />
            <Stop offset="100%" stopColor="#FF0030" />
          </LinearGradient>
        </Defs>
        
        {/* Left shadow rectangle */}
        <Rect x="-4" y="0" width="20" height="30" rx="8" fill="url(#leftGradient)" />
        
        {/* Right shadow rectangle */}
        <Rect x="29" y="0" width="20" height="30" rx="8" fill="url(#rightGradient)" />
        
        {/* Center white rectangle */}
        <Rect 
          x="0" 
          y="0" 
          width="45" 
          height="30" 
          rx="8" 
          fill={focused ? "#fff" : "rgba(255, 255, 255, 0.9)"}
        />
        
        {/* Plus icon */}
        <Path
          d="M22.5 10V20M17.5 15H27.5"
          stroke="#000"
          strokeWidth="2.5"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </Svg>
    </View>
  );
};

export default UploadButton;