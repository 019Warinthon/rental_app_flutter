import 'package:go_router/go_router.dart';
import 'package:rental_app/modules/auth/pages/login_page.dart';
import 'package:rental_app/modules/auth/pages/register_page.dart';
import 'package:rental_app/modules/main/pages/main_page.dart';
import 'package:rental_app/modules/room_detail/pages/room_detail_page.dart';
import 'package:rental_app/modules/booking/pages/booking_page.dart';
import 'package:rental_app/modules/onboarding/pages/onboarding_page.dart';
import 'package:rental_app/modules/onboarding/pages/splash_page.dart';
import 'package:rental_app/modules/home/models/room_model.dart';

import 'package:rental_app/modules/chat/pages/chat_page.dart';
import 'package:rental_app/modules/booking/pages/my_bookings_page.dart';
import 'package:rental_app/modules/home/pages/create_property_page.dart';
import 'package:rental_app/modules/home/pages/edit_property_page.dart';

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
        path: '/create-property',
        builder: (context, state) => const CreatePropertyPage(),
      ),
      GoRoute(
        path: '/edit-property',
        builder: (context, state) {
          final room = state.extra as RoomModel;
          return EditPropertyPage(room: room);
        },
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
        builder: (context, state) => const ChatPage(),
      ),
      GoRoute(
        path: '/my-bookings',
        builder: (context, state) => const MyBookingsPage(),
      ),
    ],
  );
}
