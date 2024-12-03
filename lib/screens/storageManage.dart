import 'package:bag_a_moment/screens/storage.dart';
import 'package:flutter/material.dart';

import 'detailed_page.dart';

class StorageManagementPage extends StatelessWidget {




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '보관소 관리',
          style: TextStyle(
            color: Colors.white, // 글씨 색상을 흰색으로 설정
            fontWeight: FontWeight.bold, // 글씨를 볼드체로 설정
            fontSize: 20, // 글씨 크기를 설정
          ),
        ),
        centerTitle: true, // 제목을 중앙 정렬
        backgroundColor: Color(0xFF4DD9C6), // 민트색 배경
        elevation: 0, // 앱바 그림자 제거
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // 뒤로가기 버튼
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 동작
          },
        ),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // 첫 번째 버튼: 상세보기
                                  TextButton(
                                    onPressed: index % 2 == 0
                                        ? () {
                                      print('상세보기 클릭됨');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StorageDetailPage(storageId: 1), // storageId 전달
                                        ),
                                      );
                                    }
                                        : null, // '점검중'일 경우 버튼 비활성화
                                    child: Text(
                                      '상세보기',
                                      style: TextStyle(
                                        color: index % 2 == 0 ? Colors.blue : Colors.grey, // '점검중'일 경우 비활성화 색상
                                      ),
                                    ),
                                  ),
                                  // 두 번째 버튼: 점검중
                                  Text(
                                    index % 2 == 0 ? '' : '점검중', // 두 번째 칸은 '점검중' 표시
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
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
                                    'Doldom 님의 새로운 예약!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    //'가방 x${index + 2} 캐리어 y${index}개',
                                    '가방 2개, 캐리어 1개',
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
                                //'보관소 ${index + 1}',
                                'Lemon Tree 보관소',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '24.09.${27 + index} ~ 24.09.${28 + index}\n'
                                    '13시-  19시 \n13,000원 (예상 금액)',
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
