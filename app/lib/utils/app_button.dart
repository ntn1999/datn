
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../configs/colors.dart';

class GradientButton extends StatelessWidget {
  final BorderRadiusGeometry? borderRadius;
  final double? width;
  final double height;
  final bool enable;
  final Gradient gradient;
  final VoidCallback? onPressed;
  final Widget child;

  const GradientButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.borderRadius,
    this.width,
    this.enable = true,
    this.height = 52.0,
    this.gradient = const LinearGradient(
        colors: [ColorConstants.gradientLeft, ColorConstants.gradientRight]),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(8);
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: borderRadius,
          color: Colors.amberAccent),
      child: ElevatedButton(
        onPressed: enable ? onPressed : null,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (enable) {
                return Colors.transparent;
              } else if (!enable) {
                return Colors.white.withOpacity(0.6);
              }
              return Colors.transparent;
            },
          ),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
          textStyle: MaterialStateProperty.all(
            const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ColorConstants.white,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}
Widget buildOutLineButton(String title,
    {required VoidCallback onTap,
      Key? key,
      double? height,
      double? width,
      double horizontalMargin = 0,
      double borderRadius = 16.0,
      double? radiusTopLeft,
      double? radiusTopRight,
      double? radiusBottomLeft,
      double? radiusBottomRight,
      double horizontalSpace = 16.0,
      double verticalSpace = 4.0,
      Color? borderColor,
      Color textColor = Colors.black54,
      double? fontSize,
      FontWeight? fontWeight,
      Color? enableBackgroundColor,
      Color? disableBackgroundColor,
      double borderThick = 1,
      bool enable = true,
      bool isShowBorder = true,
      Color? progressColor,
      Widget? leftIcon,
      Widget? rightIcon,
      int flexText = 1,
      TextStyle? textStyle}) {
  return InkWell(
    key: key,
    customBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radiusTopLeft ?? borderRadius),
          topRight: Radius.circular(radiusTopRight ?? borderRadius),
          bottomLeft: Radius.circular(radiusBottomLeft ?? borderRadius),
          bottomRight: Radius.circular(radiusBottomRight ?? borderRadius)),
    ),
    onTap: enable ? onTap : null,
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      width: width,
      height: height,
      padding: EdgeInsets.symmetric(
          vertical: verticalSpace, horizontal: horizontalSpace),
      decoration: BoxDecoration(
        color: enable ? enableBackgroundColor : disableBackgroundColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radiusTopLeft ?? borderRadius),
            topRight: Radius.circular(radiusTopRight ?? borderRadius),
            bottomLeft: Radius.circular(radiusBottomLeft ?? borderRadius),
            bottomRight: Radius.circular(radiusBottomRight ?? borderRadius)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leftIcon != null) ...[
            leftIcon,
            const SizedBox(
              width: 8,
            )
          ],
          Flexible(
            flex: flexText,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: textStyle ??
                    TextStyle(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: fontWeight),
              ),
            ),
          ),
          if (rightIcon != null) ...[
            const Spacer(),
            rightIcon,
          ],
        ],
      ),
    ),
  );
}
