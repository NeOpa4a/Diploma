import 'package:flutter/material.dart';

AppBar LogoHead(BuildContext? context) {
  return AppBar(
    backgroundColor: Color(0xFFFF8C0F),
    leading: context != null
        ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        : null,
    title: Image(
      image: AssetImage('images/go_box.jpg'),
      height: 60,
      width: 60,
      fit: BoxFit.fill,
    ),
    centerTitle: true,
  );
}
