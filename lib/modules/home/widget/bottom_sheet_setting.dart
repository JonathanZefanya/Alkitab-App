import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firman/modules/home/controllers/home_controller.dart';
import 'package:firman/styles/style_app.dart';

class BottomSheetSetting extends StatelessWidget {
  const BottomSheetSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: StyleApp.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.w),
          topRight: Radius.circular(20.w),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Obx(
          () => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.w),
                  child: Container(
                    width: 50.w,
                    height: 6.h,
                    decoration: BoxDecoration(color: Colors.grey[100]),
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                "Pengaturan",
                style: StyleApp.styleBold(18.sp, StyleApp.black),
              ),
              SizedBox(
                height: 20.h,
              ),
              Expanded(
                child: Center(
                  child: Obx(
                    () => Text(
                      "YESUS ADALAH TUHAN",
                      style: StyleApp.styleBold(
                        controller.textCurrentSize.value,
                        StyleApp.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Slider(
  activeColor: StyleApp.primary,
  thumbColor: StyleApp.light_black,
  inactiveColor: StyleApp.grey,
  value: controller.textCurrentSize.value.clamp(
    controller.textSizeMin.value,
    controller.textSizeMax.value,
  ),
  min: controller.textSizeMin.value > 0 ? controller.textSizeMin.value : 16.0,
  max: controller.textSizeMax.value > controller.textSizeMin.value
      ? controller.textSizeMax.value
      : 50.0,
  divisions: 7,
  onChanged: (double value) {
    double newValue = value.clamp(
      controller.textSizeMin.value,
      controller.textSizeMax.value,
    );
    controller.textCurrentSize.value = newValue;
    controller.saveSetting(newValue);
  },
),

              SizedBox(
                height: 20.h,
              ),
              Center(
                child: Text(
                  "Geser untuk mengubah ukuran teks",
                  style: StyleApp.styleReg(13.sp, StyleApp.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
