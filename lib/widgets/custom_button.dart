import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool isHome;
  final VoidCallback onTap; // using function instead of voidcallback won't work for us bcox with that u will be calling the fn and not storing the address of fun
  const CustomButton({super.key, required this.text, 
   this.isHome = false,
    required this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ElevatedButton(
      onPressed: onTap, 
      child: Text(text,
       style: const TextStyle(
        fontSize: 16, color: Colors.white
       ),),
       style: ElevatedButton.styleFrom(
        minimumSize: Size ( !isHome ?  width : width/4, 50),
        backgroundColor: Colors.blue
       ),
      );
  }
}