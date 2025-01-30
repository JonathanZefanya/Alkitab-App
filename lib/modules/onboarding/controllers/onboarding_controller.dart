import 'package:get/get.dart';
import 'package:firman/core/services/user_service.dart';
import 'package:firman/routes/app_pages.dart';

class OnBoardingController extends GetxController {
  final userService = Get.find<UserService>();

  Future<void> gotoHome() async {
    userService.saveBool(false);
    Get.offAndToNamed(Routes.Home);
  }
}
