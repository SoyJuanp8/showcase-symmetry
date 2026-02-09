import 'package:flutter/material.dart';

class DiscoverSearchBar extends StatelessWidget {
  final Function(String)? onSearch;
  const DiscoverSearchBar({super.key, this.onSearch});

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
                    onSubmitted: onSearch,
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
      ],
    );
  }
}
