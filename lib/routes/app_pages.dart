import 'package:get/get.dart';
import 'package:firman/modules/home/bindings/home_binding.dart';
import 'package:firman/modules/home/views/home_view.dart';
import 'package:firman/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:firman/modules/onboarding/views/onboarding_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();
  static final routes = [
    GetPage(
      name: _Path.ONBOARDING,
      binding: OnBoardingBinding(),
      page: () => OnboardingView(),
    ),
    GetPage(
      name: _Path.HOME,
      binding: HomeBinding(),
      page: () => HomeView(),
    ),
  ];
}
