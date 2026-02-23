import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:holy_quran/contract/local/i_message_service.dart';
import 'package:holy_quran/generated/l10n.dart';
import 'package:holy_quran/values/color_manager.dart';
import 'package:injectable/injectable.dart';

@Singleton(as: IMessageService)
class MessageService implements IMessageService {
  @override
  void noInternetConnectionAlert() {
    Get.snackbar(
      'no internet',
      'please check your internet',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  @override
  void showSuccessSnackBarAlert<T>({required String? message}) {
    Get.snackbar(
      S.current.submit,
      message ?? "",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(milliseconds: 2000),
      backgroundColor: ColorManager.green,
      colorText: Colors.white,
    );
  }

  @override
  void snackBarActionAlert<T>({
    required String? message,
    required Function() onButtonPressed,
  }) {
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Text(
          message ?? "",
          style: Theme.of(
            Get.context!,
          ).textTheme.bodyMedium!.copyWith(color: Colors.white),
        ),
        duration: const Duration(milliseconds: 2000),
        backgroundColor: Theme.of(Get.context!).primaryColor,
      ),
    );
  }

  @override
  void snackBarAlert<T>({required String? message, Color color = Colors.red}) {
    Get.snackbar(
      "Alert",
      message ?? "",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(milliseconds: 2000),
      backgroundColor: color,
      colorText: Colors.white,
    );
  }
}
