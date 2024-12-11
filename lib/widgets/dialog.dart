import 'package:bag_a_moment/widgets/primarybtn.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDialogUI extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final VoidCallback onPressed;
  final String content;
  final String title;
  const CustomDialogUI({super.key, required this.padding, required this.onPressed, required this.content, required this.title});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 280,
        height: 204,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: 204,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 280,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(color: Color(0xFF343432)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                            height: 0,
                            letterSpacing: -0.32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 77,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                 content,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF343432),
                                  fontSize: 14,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  height: 0,
                                  letterSpacing: -0.28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                          decoration: BoxDecoration(
                            color: Color(0xFF2CB598),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Primarybtn(padding: padding, onPressed: onPressed, text: "완료")
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
