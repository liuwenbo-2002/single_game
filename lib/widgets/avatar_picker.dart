import 'package:flutter/material.dart';

class AvatarPicker extends StatelessWidget {
  const AvatarPicker({super.key});

  static const List<_AvatarIcon> _avatarIcons = [
    _AvatarIcon(Icons.pets, Color(0xFFFF6B6B)),
    _AvatarIcon(Icons.face, Color(0xFF4ECDC4)),
    _AvatarIcon(Icons.star, Color(0xFFFFA07A)),
    _AvatarIcon(Icons.local_fire_department, Color(0xFF45B7D1)),
    _AvatarIcon(Icons.rocket_launch, Color(0xFFDDA0DD)),
  ];

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AvatarPicker(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '选择头像',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _avatarIcons
                  .map((item) => _buildOption(context, item))
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('取消'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, _AvatarIcon item) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: CircleAvatar(
        radius: 28,
        backgroundColor: item.color.withValues(alpha: 0.15),
        child: Icon(item.icon, color: item.color, size: 28),
      ),
    );
  }
}

class _AvatarIcon {
  final IconData icon;
  final Color color;

  const _AvatarIcon(this.icon, this.color);
}
