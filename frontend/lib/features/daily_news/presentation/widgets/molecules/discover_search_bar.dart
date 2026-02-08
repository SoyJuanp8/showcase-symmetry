import 'package:flutter/material.dart';

class DiscoverSearchBar extends StatelessWidget {
  const DiscoverSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.search,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for topics',
                      hintStyle: TextStyle(
                        color:
                            theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        TextButton(
          onPressed: () {},
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
