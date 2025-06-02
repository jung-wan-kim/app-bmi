import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  StyleSheet,
  FlatList,
  Dimensions,
  Text,
  ActivityIndicator,
} from 'react-native';
import { supabase } from '../config/supabase';
import VideoPlayer from '../components/VideoPlayer';

const { height: SCREEN_HEIGHT } = Dimensions.get('window');

// 샘플 비디오 데이터
const SAMPLE_VIDEOS = [
  {
    id: '1',
    video_url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    description: '멋진 댄스 챌린지! 함께 추어요 💃 #댄스 #챌린지 #트렌드 #fyp',
    user: {
      username: 'dancer_kim',
      profile_picture: null,
    },
    likes_count: 12500,
    comments_count: 230,
    shares_count: 145,
    music: '♬ Original Sound - dancer_kim',
  },
  {
    id: '2',
    video_url: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    description: '오늘의 요리 🍳 초간단 파스타 레시피 #요리 #레시피 #파스타 #먹방',
    user: {
      username: 'cook_lee',
      profile_picture: null,
    },
    likes_count: 8700,
    comments_count: 156,
    shares_count: 89,
    music: '♬ Cooking Time - BGM President',
  },
];

export default function HomeScreen() {
  const [videos, setVideos] = useState([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadVideos();
  }, []);

  const loadVideos = async () => {
    try {
      setLoading(true);
      
      const { data, error } = await supabase
        .from('videos')
        .select(`
          *,
          user:users!user_id(
            id,
            username,
            profile_picture
          )
        `)
        .order('created_at', { ascending: false })
        .limit(10);

      if (error) {
        console.error('Error loading videos:', error);
        setVideos(SAMPLE_VIDEOS);
      } else {
        setVideos(data || SAMPLE_VIDEOS);
      }
    } catch (error) {
      console.error('Error loading videos:', error);
      setVideos(SAMPLE_VIDEOS);
    } finally {
      setLoading(false);
    }
  };

  const onViewableItemsChanged = useRef(({ viewableItems }) => {
    if (viewableItems.length > 0) {
      setCurrentIndex(viewableItems[0].index);
    }
  }).current;

  const viewabilityConfig = useRef({
    itemVisiblePercentThreshold: 50,
  }).current;

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#fff" />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <FlatList
        data={videos}
        renderItem={({ item, index }) => (
          <VideoPlayer item={item} isActive={index === currentIndex} />
        )}
        keyExtractor={(item) => item.id}
        pagingEnabled
        showsVerticalScrollIndicator={false}
        onViewableItemsChanged={onViewableItemsChanged}
        viewabilityConfig={viewabilityConfig}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#000',
  },
});