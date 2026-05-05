import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rental_app/core/config/colors.dart';
import '../../home/pages/home_page.dart';
import '../../profile/pages/profile_page.dart';
import 'favorites_page.dart';
import '../providers/favorites_provider.dart';
import '../../chat/pages/chat_list_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late List<AnimationController> _iconControllers;
  late List<Animation<double>> _iconScales;

  static const _pages = [
    HomePage(),
    FavoritesPage(),
    ChatListPage(),
    ProfilePage(),
  ];

  static const _navItems = [
    _NavItem(icon: LucideIcons.home, label: 'Home'),
    _NavItem(icon: LucideIcons.heart, label: 'Saved'),
    _NavItem(icon: LucideIcons.messageCircle, label: 'Messages'),
    _NavItem(icon: LucideIcons.user, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _iconControllers = List.generate(
      _navItems.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );
    _iconScales = _iconControllers.map((ctrl) {
      return Tween<double>(
        begin: 1.0,
        end: 1.25,
      ).animate(CurvedAnimation(parent: ctrl, curve: Curves.elasticOut));
    }).toList();

    // Animate initial tab
    _iconControllers[0].forward();
  }

  @override
  void dispose() {
    for (final c in _iconControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabTap(int index) {
    if (_currentIndex == index) return;
    _iconControllers[_currentIndex].reverse();
    setState(() => _currentIndex = index);
    _iconControllers[index].forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(_navItems.length, (index) {
              return Expanded(child: _buildNavItem(index));
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isActive = _currentIndex == index;
    final item = _navItems[index];

    // Badge for favorites
    final showBadge = index == 1;

    return GestureDetector(
      onTap: () => _onTabTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ScaleTransition(
                  scale: _iconScales[index],
                  child: Icon(
                    item.icon,
                    size: 22,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                if (showBadge)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Consumer<FavoritesProvider>(
                      builder: (context, fav, _) {
                        final count = fav.favorites.length;
                        if (count == 0) return const SizedBox.shrink();
                        return Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              count > 9 ? '9+' : '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
              child: Text(item.label.toLowerCase().tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
