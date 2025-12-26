import "package:flutter/material.dart";

class AvatarStack extends StatelessWidget {
  const AvatarStack({
    super.key,
    required this.first,
    required this.second,
  });

  final ImageProvider? first;
  final ImageProvider? second;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 32,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: _AvatarCircle(image: first),
          ),
          Positioned(
            left: 20,
            child: _AvatarCircle(image: second),
          ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.image});

  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return const CircleAvatar(
        radius: 16,
        backgroundColor: Color(0xFFF1E7EA),
        child: Icon(Icons.person, size: 14, color: Color(0xFF8B7D83)),
      );
    }
    return CircleAvatar(radius: 16, backgroundImage: image);
  }
}
