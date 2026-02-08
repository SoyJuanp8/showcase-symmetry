import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 30,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.auto_awesome),
          ),
          const SizedBox(width: 10),
          const Text('Symmetry'),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 16.0, left: 8.0),
          child: CircleAvatar(
            radius: 18,
            backgroundImage:
                NetworkImage('https://i.pravatar.cc/150?u=symmetry'),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
