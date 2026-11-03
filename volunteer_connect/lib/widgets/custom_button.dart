// import 'package:flutter/material.dart';

// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   final bool isLoading;
//   final bool isOutlined;
//   final Color? color;
//   final double? width;

//   const CustomButton({
//     super.key,
//     required this.text,
//     required this.onPressed,
//     this.isLoading = false,
//     this.isOutlined = false,
//     this.color,
//     this.width,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final button = isOutlined
//         ? OutlinedButton(
//             onPressed: isLoading ? null : onPressed,
//             style: OutlinedButton.styleFrom(
//               minimumSize: Size(width ?? double.infinity, 48),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               side: BorderSide(color: color ?? Theme.of(context).primaryColor),
//             ),
//             child: isLoading
//                 ? const SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : Text(
//                     text,
//                     style: TextStyle(
//                       color: color ?? Theme.of(context).primaryColor,
//                     ),
//                   ),
//           )
//         : ElevatedButton(
//             onPressed: isLoading ? null : onPressed,
//             style: ElevatedButton.styleFrom(
//               minimumSize: Size(width ?? double.infinity, 48),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               backgroundColor: color ?? Theme.of(context).primaryColor,
//             ),
//             child: isLoading
//                 ? const SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: Colors.white,
//                     ),
//                   )
//                 : Text(text),
//           );

//     return button;
//   }
// }