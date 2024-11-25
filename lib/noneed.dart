/// 3. 선택된 마커의 상세 정보 가져오기
/*Future<void> _fetchStorageDetails(String storageId) async {
  final String url =
      'http://3.35.175.114:8080/storages/nearby?latitude=$_currentLatitude&longitude=$_currentLongitude&radius=10000';


  try {
    // Secure Storage에서 토큰 읽기
    final token = await secureStorage.read(key: 'auth_token');
    if (token == null) {
      print("로그인 토큰이 없습니다. 로그인이 필요합니다.");
      return;
    }

    // 요청 헤더에 토큰 추가
    final headers = {
      'accept': 'application/json',
      'Authorization': token,
    };
    // GET 요청 보내기
    final response = await http.get(Uri.parse(url), headers: headers);
    final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
    print('Full Response: ${response.body}');
    print('Data Array: ${jsonResponse['data']}');
    print('Number of Storages: ${jsonResponse['data']?.length ?? 0}');


    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      print('Server response: $jsonResponse'); // 전체 응답 출력

      // 서버 응답에서 `data` 필드 추출
      if (jsonResponse['isSuccess'] == true) {
        //음 여기 뭔가 이상함
        final Map<String, dynamic> storageDetails = jsonResponse['data']?? [];
        print('Storage Details: $storageDetails');
        // 데이터 필드 출력

        setState(() {
          _selectedMarkerInfo = {
            'name': storageDetails['name'], // 보관소 이름
            'image': (storageDetails['images'] as List).isNotEmpty
                ? storageDetails['images'][0] // 첫 번째 이미지 URL
                : '',
            'tags': List<String>.from(storageDetails['storageOptions'] ?? []), // 태그
            'description': storageDetails['description'], // 보관소 설명
            'address': storageDetails['detailedAddress'], // 상세 주소
          };
        });
      } else {
        print("Server responded with error: ${jsonResponse['message']}");
      }
    } else {
      print("Failed to load storage details: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching storage details: $e");
  }
}
*/