import 'package:flutter/material.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _trendingItems = [
    {'title': '#춤챌린지', 'views': '125.3M'},
    {'title': '#요리레시피', 'views': '89.2M'},
    {'title': '#일상브이로그', 'views': '67.8M'},
    {'title': '#운동루틴', 'views': '45.6M'},
    {'title': '#뷰티팁', 'views': '34.2M'},
    {'title': '#여행일기', 'views': '28.9M'},
  ];
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Container(
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '검색',
              hintStyle: TextStyle(color: Colors.grey.shade600),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade600,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 9 / 16,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 20,
        itemBuilder: (context, index) {
          return _buildVideoThumbnail(index);
        },
      ),
    );
  }
  
  Widget _buildVideoThumbnail(int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 썸네일 이미지
        Image.network(
          'https://picsum.photos/360/640?random=${index + 10}',
          fit: BoxFit.cover,
        ),
        
        // 그라데이션 오버레이
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
        ),
        
        // 조회수
        Positioned(
          bottom: 8,
          left: 8,
          child: Row(
            children: [
              const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${(index + 1) * 12.3}K',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        // 클릭 가능한 영역
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // 비디오 재생 화면으로 이동
            },
          ),
        ),
      ],
    );
  }
}