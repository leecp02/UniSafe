import 'package:flutter/material.dart';
import '../style/style.dart';

class HomeBottomNavBar extends StatelessWidget {

  final int currentIndex;
  final Function(int) onTap;
  final bool isCounsellor;
  final int messageBadgeCount;

  const HomeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isCounsellor,
    this.messageBadgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: CustomStyle.primary,
      unselectedItemColor: Colors.black54,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      items: [

        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: _GlowIcon(icon: Icons.home, color: CustomStyle.primary),
          label: "Home",
        ),

        BottomNavigationBarItem(
          icon: _BadgeIcon(
            icon: Icons.message_outlined,
            color: Colors.black54,
            count: messageBadgeCount,
          ),
          activeIcon: _BadgeIcon(
            icon: Icons.message,
            color: CustomStyle.primary,
            count: messageBadgeCount,
            glow: true,
          ),
          label: "Messages",
        ),

        BottomNavigationBarItem(
          icon: Icon(isCounsellor ? Icons.dashboard_outlined : Icons.report_outlined),
          activeIcon: _GlowIcon(
            icon: isCounsellor ? Icons.dashboard : Icons.report,
            color: CustomStyle.primary,
          ),
          label: isCounsellor ? "Dashboard" : "Report",
        ),

        BottomNavigationBarItem(
          icon: Icon(isCounsellor ? Icons.folder_outlined : Icons.psychology_outlined),
          activeIcon: _GlowIcon(
            icon: isCounsellor ? Icons.folder : Icons.psychology,
            color: CustomStyle.primary,
          ),
          label: isCounsellor ? "Records" : "Self-Check",
        ),

        BottomNavigationBarItem(
          icon: const Icon(Icons.phone_outlined),
          activeIcon: _GlowIcon(icon: Icons.phone, color: CustomStyle.primary),
          label: "Hotline",
        ),
      ],
    );
  }
}

class _GlowIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _GlowIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  final bool glow;

  const _BadgeIcon({
    required this.icon,
    required this.color,
    required this.count,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseIcon = glow
        ? _GlowIcon(icon: icon, color: color)
        : Icon(icon, color: color);

    if (count <= 0) {
      return baseIcon;
    }

    final label = count > 99 ? '99+' : count.toString();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        baseIcon,
        Positioned(
          right: -8,
          top: -4,
          child: Container(
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1.2),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}