import 'package:flutter/material.dart';

class JimkanmanBottomNavigationBar extends StatelessWidget {
  final int? currentIndex;
  final Function(int)? onTap;
  const JimkanmanBottomNavigationBar({
    super.key,
    this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: '예약',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.table_rows),
          label: '내 보관소',

        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '마이페이지',
        ),
      ],
      currentIndex: currentIndex ?? 0,
      selectedItemColor: Color(0xFF21B2A6),
      unselectedItemColor: Colors.grey.shade600, // 클릭되지 않은 탭 색상 (회색)
      onTap: onTap, // 탭 변경 시 호출
    );
  }
}
