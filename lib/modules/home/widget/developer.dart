import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firman/styles/style_app.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDeveloperPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
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
              SizedBox(height: 20.h),
              Text(
                "Tentang Developer",
                style: StyleApp.styleBold(18.sp, StyleApp.black),
              ),
              SizedBox(height: 20.h),
              CircleAvatar(
                radius: 50.w,
                backgroundImage: AssetImage('assets/img/dev.png'),
              ),
              SizedBox(height: 10.h),
              Text(
                'Nama Developer',
                style: StyleApp.styleBold(20.sp, StyleApp.black),
              ),
              SizedBox(height: 20.h),
              Text(
                'Hubungi saya di :',
                style: StyleApp.styleBold(16.sp, StyleApp.black),
              ),
              SizedBox(height: 10.h),
              InkWell(
                onTap: () async {
                  String uri = 'https://xead.my.id';
                  Uri url = Uri.parse(uri);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.inAppWebView);
                  }
                },
                child: Text(
                  'https://xead.my.id',
                  style: StyleApp.styleNormal(14.sp, const Color.fromARGB(255, 212, 138, 0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}