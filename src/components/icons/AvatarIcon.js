import React from 'react';
import { View } from 'react-native';
import Svg, { Circle, Path, G, Defs, LinearGradient, Stop } from 'react-native-svg';

const AvatarIcon = ({ size = 48, hasImage = false }) => {
  return (
    <View style={{ width: size, height: size }}>
      <Svg width={size} height={size} viewBox="0 0 48 48" fill="none">
        <Defs>
          <LinearGradient id="avatarGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <Stop offset="0%" stopColor="#fff" />
            <Stop offset="100%" stopColor="#f0f0f0" />
          </LinearGradient>
        </Defs>
        
        {/* 외곽 테두리 원 */}
        <Circle 
          cx="24" 
          cy="24" 
          r="23" 
          stroke="#fff" 
          strokeWidth="2"
          fill="url(#avatarGradient)"
        />
        
        {hasImage ? (
          // 이미지가 있을 경우
          <Circle cx="24" cy="24" r="22" fill="#ddd" />
        ) : (
          // 기본 아바타 아이콘
          <G>
            {/* 배경 원 */}
            <Circle cx="24" cy="24" r="22" fill="#333" />
            {/* 머리 */}
            <Circle cx="24" cy="20" r="8" fill="#fff" />
            {/* 몸통 */}
            <Path
              d="M24 30c-7 0-13 4-14 9a22 22 0 0 0 28 0c-1-5-7-9-14-9z"
              fill="#fff"
            />
          </G>
        )}
      </Svg>
    </View>
  );
};

export default AvatarIcon;