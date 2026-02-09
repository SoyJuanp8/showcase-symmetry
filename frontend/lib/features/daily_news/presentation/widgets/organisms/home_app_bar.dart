import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import '../../bloc/navigation/navigation_bloc.dart';
import '../../widgets/molecules/user_avatar.dart';

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
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
              children: const [
                TextSpan(text: 'Symmetry'),
                TextSpan(
                  text: ' News',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            String? photoUrl;
            String? userName;
            if (state is Authenticated) {
              photoUrl = state.user.photoURL;
              userName = state.user.displayName;
            }
            return GestureDetector(
              onTap: () {
                // Switch to Profile tab (Index 3)
                context
                    .read<NavigationBloc>()
                    .add(const NavigationTabChanged(3));
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 8.0),
                child: UserAvatar(
                  radius: 18,
                  profileImageUrl: photoUrl,
                  userName: userName,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
