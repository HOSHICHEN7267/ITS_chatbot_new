import 'package:flutter/material.dart';

class FormTextfield extends StatelessWidget {
  final TextEditingController textfieldController;
  final String hintText;
  final bool isPassword;

  const FormTextfield(
      {super.key,
      required this.textfieldController,
      required this.hintText,
      required this.isPassword});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: screenWidth * 0.024,
        ),
        Expanded(
            child: TextField(
          controller: textfieldController,
          keyboardType: TextInputType.text,
          obscureText: isPassword ? true : false,
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: screenWidth * 0.040, height: 1.2),
          cursorColor: Colors.black,
          cursorWidth: 2.5,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(0.0),
              hintText: hintText,
              hintStyle: TextStyle(
                  color: const Color.fromARGB(255, 134, 134, 134),
                  fontSize: screenWidth * 0.040,
                  fontWeight: FontWeight.normal),
              border: InputBorder.none),
        ))
      ],
    );
  }
}
