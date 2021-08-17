import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ContactUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Us"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 50),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/black-logo.svg",
                  height: size.height * 0.15,
                ),
                SizedBox(height: size.height * 0.05),
                Center(
                  child: Text(
                    "Thank you for using Conspaces! We'd love to hear from you. If you have any questions, problems or uncertainties regarding Conspaces, contact us at homes@swap.com. We will get back to you as soon as possible.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
