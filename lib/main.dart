import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firman/core/services/db/database_service.dart';
import 'package:firman/core/services/user_service.dart';
import 'package:firman/modules/home/bindings/home_binding.dart';
import 'package:firman/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userService = await Get.putAsync(() async {
    final service = UserService();
    await service.initSharedPref();

    return service;
  });
  await Get.putAsync<DatabaseService>(() async => DatabaseService());

  runApp(MainApp(
    isFirstTime: userService.isFirstTime(),
  ));
}

class MainApp extends StatelessWidget {
  final bool isFirstTime;

  MainApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    HomeBinding().dependencies;
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, context) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: isFirstTime ? Routes.ONBOARDING : Routes.Home,
            getPages: AppPages.routes,
          );
        });
  }
}
