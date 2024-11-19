import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';

void showMessage(BuildContext context, String Message, String type) {
  Color builderColor;
  Icon builderIcon;

  if(type=="success"){
    builderColor = Colors.green;
    builderIcon = Icon(
      Icons.check_circle_outline,
      size: 28,
      color: Colors.white,
    );
  }
  else if(type=="error"){
    builderColor = Colors.red;
    builderIcon = Icon(
      Icons.error_outline,
      size: 28,
      color: Colors.white,
    );
  }
  else {
    builderColor = Colors.orange;
    builderIcon = Icon(
      Icons.warning_amber_outlined,
      size: 28,
      color: Colors.white,
    );
  }

  DelightToastBar(
    animationDuration: Duration(seconds: 2),
    autoDismiss: true,
    builder: (context) => ToastCard(
      color: builderColor,
      leading: builderIcon,
      title: Text(
        Message,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    ),
  ).show(context);
}