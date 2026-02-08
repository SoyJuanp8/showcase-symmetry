import 'package:flutter/material.dart';

class ArticleHeader extends StatelessWidget {
  const ArticleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor.withOpacity(0.95),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Stack(
            children: [
              // Back Button
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.brightness == Brightness.dark
                          ? Colors.white10
                          : Colors.black.withOpacity(0.05),
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
              ),

              // Centered Channel/Source
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.auto_awesome, size: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Symmetry News',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.textTheme.titleLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
