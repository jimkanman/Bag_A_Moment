import 'package:bag_a_moment/models/storage_model.dart';
import 'package:bag_a_moment/screens/storage/StorageDetailPage.dart';
import 'package:flutter/material.dart';

/// '내 보관소' 화면의 보관소 카드
class StorageCard extends StatelessWidget {
  final StorageModel storage;

  const StorageCard({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StorageDetailPage(storageId: storage.id, ),
          ),
        );
      },
      child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),

          child: Row(
            children: [
              Container(width: 70, height: 70,
                child: Image(image: NetworkImage(storage.images[0]))
              ),
              const SizedBox(width: 16),

              // 보관소 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text( storage.name ,style: const TextStyle( fontSize: 16, fontWeight: FontWeight.bold,), overflow: TextOverflow.ellipsis,),
                    const SizedBox(height: 4),
                    Text(storage.detailedAddress, style: const TextStyle(fontSize: 10, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),

              // 상태 텍스트
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 상태 텍스트 (검수 중 or REJECTED)
                  Text(
                    storage.status == 'REJECTED' ? '검수 거절' : '',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}
