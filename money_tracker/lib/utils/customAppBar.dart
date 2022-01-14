import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  final String title;
  final Widget leading;
  final Widget trailing;

  CustomAppBar(
    this.title,
    this.leading,
    this.trailing, {
    Key? key,
  })  : preferredSize = const Size.fromHeight(70.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      shadowColor: null,
      title: Text(
        title,
        style: const TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.transparent,

      //automaticallyImplyLeading: true,
      leading: leading,
      actions: [trailing],
      // leading: IconButton(
      //   onPressed: () => {Navigator.pop(context)},
      //   icon: const Icon(
      //     Icons.arrow_back_ios,
      //     color: Colors.black,
      //   ),
      // ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            color: Colors.blue),
      ),
      titleSpacing: 0,
    );
  }
}
