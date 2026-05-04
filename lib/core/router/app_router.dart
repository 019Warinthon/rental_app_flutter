import 'package:go_router/go_router.dart';
import '../../modules/auth/pages/login_page.dart';
import '../../modules/auth/pages/register_page.dart';
import '../../modules/main/pages/main_page.dart';
import '../../modules/room_detail/pages/room_detail_page.dart';
import '../../modules/booking/pages/booking_page.dart';
import '../../modules/onboarding/pages/onboarding_page.dart';
import '../../modules/onboarding/pages/splash_page.dart';
import '../../modules/home/models/room_model.dart';

import '../../modules/chat/pages/chat_page.dart';
import '../../modules/booking/pages/my_bookings_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainPage(),
      ),
      GoRoute(
        path: '/room_detail',
        builder: (context, state) {
          final room = state.extra as RoomModel;
          return RoomDetailPage(room: room);
        },
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) {
          final room = state.extra as RoomModel;
          return BookingPage(room: room);
        },
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final landlordName = extra['landlordName'] as String? ?? 'Landlord';
          final roomTitle = extra['roomTitle'] as String? ?? 'Room Inquiry';
          return ChatPage(landlordName: landlordName, roomTitle: roomTitle);
        },
      ),
      GoRoute(
        path: '/my-bookings',
        builder: (context, state) => const MyBookingsPage(),
      ),
    ],
  );
}
