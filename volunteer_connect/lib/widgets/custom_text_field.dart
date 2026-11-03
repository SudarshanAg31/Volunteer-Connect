// import 'package:flutter/material.dart';

// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final String? hint;
//   final IconData? icon;
//   final bool obscureText;
//   final TextInputType keyboardType;
//   final String? Function(String?)? validator;
//   final int maxLines;
//   final Widget? suffixIcon;

//   const CustomTextField({
//     super.key,
//     required this.controller,
//     required this.label,
//     this.hint,
//     this.icon,
//     this.obscureText = false,
//     this.keyboardType = TextInputType.text,
//     this.validator,
//     this.maxLines = 1,
//     this.suffixIcon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       maxLines: maxLines,
//       validator: validator,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         prefixIcon: icon != null ? Icon(icon) : null,
//         suffixIcon: suffixIcon,
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Color(0xFF2E7D32)),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.red),
//         ),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 14,
//         ),
//       ),
//     );
//   }
// }