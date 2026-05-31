import 'package:flutter/material.dart';
import '../controllers/forum_controller.dart';

import '../widgets/app_header.dart';
import '../widgets/home_tab_bar.dart';
import '../widgets/forum_list_view.dart';
import '../widgets/event_list_view.dart';
import '../widgets/home_floating_buttons.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/user_model.dart';
import '../models/report_chat_thread_model.dart';
import '../services/auth_service.dart';
import '../services/report_chat_service.dart';

import 'counsellor_dashboard_page.dart';
import 'messages_page.dart';
import 'report_page.dart';
import 'records_page.dart';
import 'hotline_page.dart';
import 'account_profile_page.dart';
import 'self_check_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {

  late TabController tabController;

  final ForumController controller = ForumController();
  final AuthService authService = AuthService();
  final ReportChatService chatService = ReportChatService();

  int currentIndex = 0;

  static const List<String> _studentTitles = [
    '', // Home uses AppHeader widget
    'Messages',
    'Report',
    'Self-Check',
    'Hotline',
  ];

  static const List<String> _counsellorTitles = [
    '', // Home uses AppHeader widget
    'Messages',
    'Dashboard',
    'Records',
    'Hotline',
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  Widget _buildBody({required bool isCounsellor}) {
    switch (currentIndex) {
      case 1:
        return MessagesPage(isCounsellor: isCounsellor);
      case 2:
        return isCounsellor
            ? const CounsellorDashboardPage()
            : const ReportPage();
      case 3:
        return isCounsellor
            ? const RecordsListSection(isCounsellor: true)
            : const SelfCheckPage();
      case 4:
        return HotlinePage(isCounsellor: isCounsellor);
      default:
        // Home — Forum + Event tabs
        return Column(
          children: [
            HomeTabBar(controller: tabController),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  ForumListView(controller: controller),
                  const EventListView(),
                ],
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: authService.watchCurrentUserProfile(),
      builder: (context, snapshot) {
        final bool isCounsellor = snapshot.data?.isCounsellor ?? false;
        final profile = snapshot.data;
        final titles = isCounsellor ? _counsellorTitles : _studentTitles;

        return Scaffold(

          appBar: AppBar(
            leading: currentIndex != 0
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        currentIndex = 0;
                      });
                    },
                  )
                : null,
            title: currentIndex == 0
                ? const AppHeader()
                : Text(titles[currentIndex]),
            actions: [
              if (currentIndex == 0)
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AccountProfilePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_outline),
                  tooltip: 'Account Profile',
                ),
              if (currentIndex == 0)
                IconButton(
                  onPressed: () async {
                    await authService.logout();
                  },
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                ),
            ],
          ),

          body: _buildBody(isCounsellor: isCounsellor),

          // FABs only relevant on the Home tab
          floatingActionButton: currentIndex == 0
              ? HomeFloatingButtons(
                  controller: tabController,
                  isCounsellor: isCounsellor,
                )
              : null,

          bottomNavigationBar: StreamBuilder<List<ReportChatThread>>(
            stream: profile == null
                ? Stream<List<ReportChatThread>>.value(const <ReportChatThread>[])
                : (isCounsellor
                    ? chatService.getThreadsForCounsellor(profile.uid)
                    : chatService.getThreadsForStudent(profile.uid)),
            builder: (context, chatSnapshot) {
              final threads = chatSnapshot.data ?? const <ReportChatThread>[];
              final unreadCount = profile == null
                  ? 0
                  : threads.where((thread) {
                      if (thread.lastMessageSenderUid == profile.uid) {
                        return false;
                      }

                      final lastReadAt = isCounsellor
                          ? thread.lastReadByCounsellorAt
                          : thread.lastReadByStudentAt;

                      if (lastReadAt == null) {
                        return true;
                      }

                      return thread.updatedAt.isAfter(lastReadAt);
                    }).length;

              return HomeBottomNavBar(
                currentIndex: currentIndex,
                isCounsellor: isCounsellor,
                messageBadgeCount: unreadCount,
                onTap: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              );
            },
          ),
        );
      },
    );
  }
}