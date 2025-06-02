class VideoModel {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String username;
  final String userAvatar;
  final String description;
  final String musicName;
  final int likes;
  final int comments;
  final int shares;
  bool isLiked;
  
  VideoModel({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.username,
    required this.userAvatar,
    required this.description,
    required this.musicName,
    required this.likes,
    required this.comments,
    required this.shares,
    this.isLiked = false,
  });
  
  // 샘플 데이터 생성
  static List<VideoModel> getSampleVideos() {
    return [
      VideoModel(
        id: '1',
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        thumbnailUrl: 'https://picsum.photos/360/640?random=1',
        username: 'nature_lover',
        userAvatar: 'https://picsum.photos/100/100?random=1',
        description: '아름다운 나비의 날갯짓 🦋',
        musicName: 'Original Sound - nature_lover',
        likes: 12500,
        comments: 234,
        shares: 56,
      ),
      VideoModel(
        id: '2',
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        thumbnailUrl: 'https://picsum.photos/360/640?random=2',
        username: 'bee_keeper',
        userAvatar: 'https://picsum.photos/100/100?random=2',
        description: '열심히 일하는 꿀벌 🐝',
        musicName: 'Buzzing Beats - DJ Honey',
        likes: 8900,
        comments: 156,
        shares: 89,
      ),
      VideoModel(
        id: '3',
        videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
        thumbnailUrl: 'https://picsum.photos/360/640?random=3',
        username: 'animation_world',
        userAvatar: 'https://picsum.photos/100/100?random=3',
        description: '토끼의 모험 🐰',
        musicName: 'Adventure Time - Cartoon Network',
        likes: 45000,
        comments: 890,
        shares: 234,
      ),
    ];
  }
}