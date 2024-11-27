import 'package:bag_a_moment/screens/storage.dart';
import 'package:flutter/material.dart';

class StorageManagementPage extends StatelessWidget {




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('보관소 관리'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. 나의 보관소 섹션
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 섹션 타이틀
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '나의 보관소',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () async {
                          print("보관소 추가 버튼 클릭됨");
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StorageScreen(), // StorageScreen으로 이동
                            ),
                          );
                          // 서버로 전송이 완료되었는지 확인
                          if (result == true) {
                            // 서버로 전송이 완료된 상태
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('서버로 데이터가 전송되었습니다.')),
                            );
                          }

                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 보관소 리스트
                  Expanded(
                    child: ListView.builder(
                      itemCount: 2, // 예제 데이터 개수
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // 보관소 이미지
                              Container(
                                width: 50,
                                height: 50,
                                color: Colors.black, // 임시 색상
                              ),
                              const SizedBox(width: 12),
                              // 보관소 정보
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '보관소${index + 1}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '서울특별시 흑석로 84 30${index}관...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 상태 텍스트
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      print('상세보기 클릭됨');
                                    },
                                    child: Text(
                                      index % 2 == 0 ? '상세보기' : '점검중',
                                      style: TextStyle(
                                        color: index % 2 == 0
                                            ? Colors.blue
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          Divider(height: 1, thickness: 1),

          // 2. 최근 예약 섹션
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 섹션 타이틀
                  Text(
                    '최근 예약',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 예약 리스트
                  Expanded(
                    child: ListView.builder(
                      itemCount: 2, // 예제 데이터 개수
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 예약자 정보
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '집깐만 사용자${index + 1}님',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '가방 x${index + 2} 캐리어 y${index}개',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // 예약 상세
                              Text(
                                '보관소 ${index + 1}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '24.09.${27 + index} ~ 24.09.${28 + index}\n'
                                    '13시부터 19시까지\n13000원 (예정)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    print('예약 확인하기 클릭됨');
                                  },
                                  child: Text(
                                    '예약 확인하기',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
