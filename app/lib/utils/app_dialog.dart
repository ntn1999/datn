
import 'package:flutter/material.dart';

import '../configs/colors.dart';
import '../configs/constants.dart';
import 'app_button.dart';



class DialogService {
  DialogService._();

  static bool isDialogShowing = false;

  static Future dialog(
      BuildContext context, {
        double? width,
        double? height,
        Widget? child,
        Widget? action,
        Alignment alignment = Alignment.center,
        Color? backgroundColor,
        Color? barrierColor,
        EdgeInsets? margin,
        EdgeInsets? padding,
        BorderRadius? borderRadius,
        bool barrierDismissible = true,
        List<BoxShadow>? boxShadow,
        String? title,
        TextStyle? titleStyle,
        bool showCloseButton = false,
      }) async {
    isDialogShowing = true;

    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return SafeArea(
          minimum: EdgeInsets.only(bottom: MediaQuery.of(_).viewInsets.bottom),
          child: Align(
            alignment: alignment,
            child: Container(
              width: width,
              height: height,
              margin: margin,
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.white,
                borderRadius: borderRadius ?? BorderRadius.circular(12),
                boxShadow: boxShadow,
              ),
              child: ClipRRect(
                borderRadius: borderRadius ?? BorderRadius.circular(12),
                child: Container(
                  padding: padding,
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null) ...[
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Center(
                                  child: Text(
                                    title,
                                    style: StyleConstants.xLargeText,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              if (showCloseButton)
                                Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      width: 56,
                                      height: 48,
                                      color: Colors.transparent,
                                      child: const Center(
                                        child: Icon(
                                          Icons.clear_rounded,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ],
                        if (child != null) child,
                        if (action != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 20,
                            ),
                            child: action,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() => isDialogShowing = false);
  }

  static Future confirmDialog(
      BuildContext context, {
        Function? onAction,
        Function? onCancel,
        String? title,
        String? subTitle,
        bool showAction = true,
        String? actionTitle,
      }) async {
    return dialog(
      context,
      barrierDismissible: false,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.white,
      title: title,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subTitle != null) ...[
              const SizedBox(height: 20),
              Center(
                child: Text(
                  subTitle,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
      action: Row(
        children: [
          Expanded(
            flex: 5,
            child: buildOutLineButton(
              'Đóng',
              borderRadius: 12,
              height:42,
              onTap: () {
                Navigator.of(context).pop();
                if (onCancel != null) {
                  onCancel();
                }
              },
            ),
          ),
          if (showAction) ...[
            const SizedBox(width: 6),
            Expanded(
              flex: 5,
              child: buildOutLineButton(
                actionTitle ?? 'Xác nhận',
                textColor: Colors.white,
                height:42,
                borderRadius: 12,
                enableBackgroundColor: ColorConstants.gradientLeft,
                onTap: () {
                  Navigator.of(context).pop();
                  if (onAction != null) {
                    onAction();
                  }
                },
              ),
            )
          ],
        ],
      ),
    );
  }

  static Future errorDialog(
      BuildContext context, {
        Function? onCancel,
        String? title,
        String? message,
      }) async {
    return dialog(
      context,
      barrierDismissible: false,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.white,
      title: title ?? 'Error',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message != null) ...[
              const SizedBox(height: 20),
              Center(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
      action: Row(
        children: [
          Expanded(
            child: buildOutLineButton(
              'Đóng',
              height: 42,
              borderRadius: 12,
              textColor: Colors.white,
              enableBackgroundColor: ColorConstants.gradientLeft,
              onTap: () {
                Navigator.of(context).pop();
                if (onCancel != null) {
                  onCancel();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
