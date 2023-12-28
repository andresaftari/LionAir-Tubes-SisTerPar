import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lion_air_flutter/utils/color_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final RxBool isLogin;
  final Widget child;
  final double height;

  const CustomAppBar({
    super.key,
    required this.child,
    this.height = kToolbarHeight,
    required this.isLogin,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 16.h, left: 48.w, right: 48.w),
      height: preferredSize.height.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(50.r),
        boxShadow: [
          BoxShadow(
            color: kDarkColorGrey,
            blurRadius: 2.r,
            spreadRadius: 0.r,
            offset: Offset(0.w, -2.h)
          ),
        ]
      ),
      child: child,
    );
  }
}
