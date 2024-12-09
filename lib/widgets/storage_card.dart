import 'package:bag_a_moment/screens/registerStorage.dart';
import 'package:flutter/material.dart';

/// '내 보관소' 화면의 보관소 카드
class StorageCard extends StatelessWidget {
  const StorageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    
      child: Row(
        children: [
          // 보관소 이미지 // TODO: image 삽입
          Container(width: 70, height: 70, color: Colors.black,),
          const SizedBox(width: 16),

          // 보관소 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text( '보관소 제목', /* TODO Title */ style: const TextStyle( fontSize: 16, fontWeight: FontWeight.bold,), overflow: TextOverflow.ellipsis,),
                const SizedBox(height: 4),
                Text('서울특별시 흑석로 84 310관', /* TODO 주소 */style: const TextStyle(fontSize: 10, overflow: TextOverflow.ellipsis),
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
                '점검중', // TODO status 보고 결정 (APPROVED 시 렌더링 X)
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // 상세보기
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO
                    print('상세보기 클릭됨');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StorageRegistraterScreen(), // TODO storageId 전달
                      ),
                    );
                  },
                  child: const Text('상세보기', style: TextStyle( color: Colors.blue,),),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
