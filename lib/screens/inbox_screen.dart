import 'package:flutter/material.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '받은 메시지함',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
            onPressed: () {
              // 새 메시지 작성
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // 활동 섹션
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '활동',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActivityItem(
                  icon: Icons.favorite,
                  iconColor: Colors.red,
                  title: '새로운 좋아요',
                  subtitle: '지난 주',
                  count: '23',
                ),
                _buildActivityItem(
                  icon: Icons.person_add,
                  iconColor: Colors.blue,
                  title: '새로운 팔로워',
                  subtitle: '어제',
                  count: '8',
                ),
                _buildActivityItem(
                  icon: Icons.comment,
                  iconColor: Colors.green,
                  title: '새로운 댓글',
                  subtitle: '2시간 전',
                  count: '15',
                ),
              ],
            ),
          ),
          
          Divider(color: Colors.grey.shade800),
          
          // 메시지 섹션
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '메시지',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMessageItem(
                  avatar: 'https://picsum.photos/100/100?random=20',
                  name: '김민수',
                  message: '안녕하세요! 콜라보 제안이 있어요.',
                  time: '오후 3:45',
                  unread: true,
                ),
                _buildMessageItem(
                  avatar: 'https://picsum.photos/100/100?random=21',
                  name: '이서연',
                  message: '영상 잘 봤어요 👍',
                  time: '오전 11:23',
                  unread: false,
                ),
                _buildMessageItem(
                  avatar: 'https://picsum.photos/100/100?random=22',
                  name: '박준호',
                  message: '다음에 같이 촬영해요!',
                  time: '어제',
                  unread: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String count,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 12,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () {
        // 활동 상세 보기
      },
    );
  }
  
  Widget _buildMessageItem({
    required String avatar,
    required String name,
    required String message,
    required String time,
    required bool unread,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(avatar),
      ),
      title: Text(
        name,
        style: TextStyle(
          color: Colors.white,
          fontWeight: unread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        message,
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
            ),
          ),
          if (unread) ...[
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        // 메시지 열기
      },
    );
  }
}