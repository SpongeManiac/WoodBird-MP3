import 'package:flutter/material.dart';

class FlyoutItem extends StatelessWidget {
  const FlyoutItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTapped,
  });

  //define inputs
  final IconData icon;
  final String text;
  final void Function()? onTapped;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      onTap: onTapped,
      title: Text(
        text,
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.headline4?.fontSize,
        ),
      ),
    );
  }
}
