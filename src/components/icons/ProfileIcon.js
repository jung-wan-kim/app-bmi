import React from 'react';
import Svg, { Path, Circle } from 'react-native-svg';

const ProfileIcon = ({ color = '#fff', focused = false, size = 24 }) => {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle
        cx="12"
        cy="8"
        r="4"
        stroke={color}
        strokeWidth={focused ? "2.5" : "2"}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path
        d="M20 21C20 16.5817 16.4183 13 12 13C7.58172 13 4 16.5817 4 21"
        stroke={color}
        strokeWidth={focused ? "2.5" : "2"}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
};

export default ProfileIcon;