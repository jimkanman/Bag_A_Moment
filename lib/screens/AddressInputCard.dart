import 'package:flutter/material.dart';

class AddressInputCard extends StatelessWidget {
  final TextEditingController userInputPostalCodeController;
  final TextEditingController userInputAddressController;

  AddressInputCard({
    required this.userInputPostalCodeController,
    required this.userInputAddressController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '주소 입력',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: userInputPostalCodeController,
              decoration: InputDecoration(
                labelText: '우편번호',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: userInputAddressController,
              decoration: InputDecoration(
                labelText: '주소',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.streetAddress,
            ),
          ],
        ),
      ),
    );
  }
}
