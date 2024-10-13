import 'package:flutter/material.dart';
import 'package:voice_assistant/pallete.dart';

class Featuredbox extends StatelessWidget {
  final String headertext;
  final Color color;
  final String descriptionText;
  const Featuredbox(
      {super.key,
      required this.color,
      required this.headertext,
      required this.descriptionText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
      decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(15))),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
        ).copyWith(left: 15),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                headertext,
                style: const TextStyle(
                    fontFamily: 'Cera pro',
                    color: Pallete.blackColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                descriptionText,
                style: const TextStyle(
                  fontFamily: 'Cera pro',
                  color: Pallete.blackColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
