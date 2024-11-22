import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bag_a_moment/screens/detailed_page.dart';
import 'package:bag_a_moment/widgets/marker_details_widget.dart';
import 'package:http/http.dart' as http;

//홈화면 클래스 생성
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  //@@@@변수@@@@
  // 1. Google Map Controller
  late GoogleMapController mapController;
  // dispose에서 컨트롤러 해제
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 1-1. 초기 맵 위치 설정 (위도, 경도) - 사용자 현위치로 수정
  final LatLng _initialPosition = const LatLng(
      37.5045563, 126.9569379); // 중앙대 위치 넣음
  final double _currentLatitude = 37.5045563; // 사용자의 현재 위도
  final double _currentLongitude = 126.9569379; // 사용자의 현재 경도


  // 2. 선택된 마커 정보
  Map<String, dynamic>? _selectedMarkerInfo;
  // 2-1. 선택된 마커 위치 (상세 탭 위젯에 사용)
  LatLng? _selectedMarkerPosition;
  // 3. 마커 리스트
  final List<Marker> _markers = [];
  // 검색된 마커 리스트
  //List<Marker> _filteredMarkers = [];
  String? _selectedStorageId; //선택된 마커 아이디
  String? _selectedName; // 선택된 마커의 이름
  String? _selectedImageUrl; // 선택된 마커의 이미지 URL
  List<String>? _selectedTags; // 선택된 마커의 태그
  Offset? _markerScreenPosition; // 마커의 화면상 좌표

  // 4. 검색 컨트롤러 초기화
  final TextEditingController _searchController = TextEditingController();

  // 5. 검색 필터 변수
  String _location = "현위치";
  int _selectedItems = 1; // 초기값 설정
  DateTimeRange? _selectedDateRange;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  bool _isExpanded = false; // 검색창 확장 여부

// 초기화!
  void initState() {
    super.initState();
    _requestLocationPermission();
    _fetchNearbyStorages(); // 서버에서 storage 목록 가져오기
  }

  //함수
  // 1.위치 권한 요청 함수
  void _requestLocationPermission() async {
    if (await Permission.location.request().isGranted) {
      // 권한이 부여됨
      print("위치 권한이 부여되었습니다.");
    } else {
      // 권한이 거부됨
      print("위치 권한이 거부되었습니다.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("위치 권한이 필요합니다."),
        ),
      );
    }
  }

  /// 1. 서버에서 사용자의 현재 위치 기반 storage 정보 가져오기
  Future<void> _fetchNearbyStorages() async {
    final String url = 'http://3.35.175.114:8080/storages/nearby?latitude=$_currentLatitude&longitude=$_currentLongitude&radius=1000';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> storages = jsonResponse['data.id'];

        _addMarkers(storages); // 마커 추가
      } else {
        print("Failed to fetch nearby storages: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching nearby storages: $e");
    }
  }


    // 날짜 선택
    void _pickDateRange() async {
      DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 365)),
      );
      if (picked != null) {
        setState(() {
          _selectedDateRange = picked;
        });
      }
    }

    // 시간 선택
    void _pickTimeRange() async {
      // from 시간 선택
      TimeOfDay? fromPicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (fromPicked != null) {
        // to 시간 선택
        TimeOfDay? toPicked = await showTimePicker(
          context: context,
          initialTime: fromPicked,
        );
        if (toPicked != null) {
          setState(() {
            _fromTime = fromPicked;
            _toTime = toPicked;
          });
        }
      }
    }

    // 검색 기능
    void _searchMarkers(String query) {
      final results = _markers.where((marker) {
        return marker.infoWindow.title!.toLowerCase().contains(
            query.toLowerCase());
      }).toList();

      setState(() {
        //_markerList = results;
      });
    }

    // 필터 조건에 맞는 검색 로직
    void _searchWithFilters() {
      // 필터된 마커를 찾는 조건을 적용
      final results = _markers.where((marker) {
        // 예시: 마커의 제목이나 날짜/시간과 관련된 추가 조건을 설정
        // 예를 들어 가방 개수와 날짜/시간 조건을 체크
        return true; // 원하는 조건에 맞게 true/false 설정
      }).toList();

      setState(() {
       // _markerList = results;
      });
    }

    //조건 선택(가방 개수, 시간, 필터)
    void _openFilterDialog() {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('짐 개수 선택'),
                Slider(
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '$_selectedItems개',
                  value: _selectedItems.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      _selectedItems = value.toInt();
                    });
                  },
                ),
                SizedBox(height: 10),
                Text('보관 기간 선택'),
                ElevatedButton(
                  onPressed: () async {
                    DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    setState(() {
                      _selectedDateRange = picked;
                    });
                  },
                  child: Text(
                    _selectedDateRange == null
                        ? '기간 선택'
                        : '${_selectedDateRange!.start} - ${_selectedDateRange!.end}',
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // 마커로 카메라 이동
    void _moveToMarker(Marker marker) {
      mapController.animateCamera(CameraUpdate.newLatLng(marker.position));
    }

    //마커 추가
    Future<void> _addMarkers(List<dynamic> storages) async {
      print('Adding markers...');
      print('Storages received: $storages'); // 서버 응답 데이터 출력
      // fromAssetImage를 사용하여 BitmapDescriptor 생성, 이미지로 아이콘 설정
      final BitmapDescriptor bagIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(150, 150)), // 크기 설정
        'assets/images/box_icon3.png', // 파일 경로
      );



      //사용자 현위치 _initialPosition을 기반으로 주변 보관소 위치 GET 요청 날리기

      // 받은 GET 정보를 리스트에 저장하고, 이에 따라 지도 상에 마커 표현하기
      for (var storage in storages) {
        print('Adding marker for storage: ${storage['name']}'); // 각 마커 정보 출력


        final marker = Marker(
          markerId: MarkerId(storage['id'].toString()),
          position: LatLng(storage['latitude'], storage['longitude']),
          icon: bagIcon,
          onTap: () {
            print("marker is clicked");
            // 디버깅용: 서버에서 받아온 데이터 출력
            print('Storage ID: ${storage['id']}');
            print('Name: ${storage['name']}');
            print('Latitude: ${storage['latitude']}');
            print('Longitude: ${storage['longitude']}');
            _fetchStorageDetails(storage['id'].toString()); // 클릭한 마커의 상세 정보 가져오기
            setState(() {
              _selectedMarkerPosition = LatLng(
                storage['latitude'],
                storage['longitude'],
              );
            });
          },
        );
        _markers.add(marker);
      }
// 디버깅용: 전체 마커 개수 확인
      print('Total markers added: ${_markers.length}');

      setState(() {}); // 상태 갱신



      // 만약 마커가 클릭되면, 클릭된 storageId와 함께 서버에 상세정보 요청을 GET 하기
      //_fetchStorageDetails()함수 이용

      //받은 정보로 마커 위에 정보를 보이기.


      // 특정 위치에 마커 추가 1: 기본 테스트용 마커, 서버와 통신 한 것 x
      final marker = Marker(
        markerId: MarkerId('chungang'),
        position: LatLng(37.5045563, 126.9569379),
        onTap: () async {
          setState(() {
            _selectedMarkerInfo = {
              'name': '기본 스토리지',
              'image': "https://via.placeholder.com/150", // 박스 이미지 경로
              'tags': ['큰 보관', '냉장', '24시간'],
            };
            // 클릭된 마커의 위치 저장
            _selectedMarkerPosition = LatLng(37.5045563, 126.9569379);
          });
          //final storageInfo = await _fetchStorageDetails('1'); // 예제 storageId = '1'
          final response = await http.get(
            Uri.parse('http://3.35.175.114:8080/storages/1'),
            headers: {'accept': 'application/json'}, // 필수 헤더
            //당연히 에러. 서버에는 해당 위치 보관소 없음
          );

          // 클릭된 마커 위치를 화면 좌표로 변환 -> 상세 박스 표현
          ScreenCoordinate screenCoordinate =
          await mapController.getScreenCoordinate(_selectedMarkerPosition!);
        },
        icon: bagIcon,
      );
      // 마커 리스트를 setState로 업데이트
      setState(() {
        _markers.add(marker); // 마커 추가
        //_markers.add(marker2); // 마커 추가
        //_markerList = _markers.toList(); // 마커 리스트로 저장
        //_filteredMarkers = _markers.toList(); // 초기 검색 결과는 모든 마커
      });


    }



  /// 3. 선택된 마커의 상세 정보 가져오기
  Future<void> _fetchStorageDetails(String storageId) async {
    final String url = 'http://3.35.175.114:8080/storages/$storageId';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print('Server response: $jsonResponse'); // 전체 응답 출력

        // 서버 응답에서 `data` 필드 추출
        if (jsonResponse['isSuccess'] == true) {
          final Map<String, dynamic> storageDetails = jsonResponse['data'];
          print('Storage Details: $storageDetails'); // 데이터 필드 출력

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


  @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.0,
              ),
              markers: Set.from(_markers),
              onTap: (_) {
                // 지도 클릭 시 선택된 정보 초기화
                setState(() {
                  _selectedName = null;
                  _selectedImageUrl = null;
                  _selectedTags = null;
                  _selectedImageUrl = null;
                  _selectedTags = null;
                });
              },
            ),

    if (_selectedMarkerInfo != null)
          Positioned(
          top: MediaQuery.of(context).size.height / 2 - 100,
          left: MediaQuery.of(context).size.width / 2 - 150,
            child: Container(
              width: 300,
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
               child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                _selectedMarkerInfo!['name'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  ),
                ),
                  const SizedBox(height: 8),
                Text(
                _selectedMarkerInfo!['address'] ?? '',
                style: TextStyle(fontSize: 14),
                ),
                  const SizedBox(height: 8),
                  Text(
                  _selectedMarkerInfo!['description'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                  children: (_selectedMarkerInfo!['tags'] as List<String>)
                  .map((tag) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                child: Text(
                  tag,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade800,
                      ),
                    ),
                ))
                    .toList(),
                ),
                  const SizedBox(height: 8),
                  Image.network(
                  _selectedMarkerInfo!['image'] ?? '',
                    height: 100,
                    fit: BoxFit.cover,
                  ),

              ],

    ),

            ),
          ),
            // 마커 클릭 시 상세 정보 박스 표시
            if (_selectedMarkerInfo != null && _selectedMarkerPosition != null)
              Positioned(
                top: MediaQuery.of(context).size.height / 2 - 100,
                left: MediaQuery.of(context).size.width / 2 - 150,
                child: Container(
                  width: 300,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedMarkerInfo!['name'] ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: (_selectedMarkerInfo!['tags'] as List<String>)
                            .map(
                              (tag) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                        )
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Image.network(
                        _selectedMarkerInfo!['image'] ?? '',
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
              )
            else
                Center(
                child: Text('No marker selected'),
                ),
            //상단 검색창
            Positioned(
              top: 20,
              left: 15,
              right: 15,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Color(0xFF43CBBA)),
                              SizedBox(width: 5),
                              Text(
                                "현위치",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                                Icons.filter_list, color: Color(0xFF43CBBA)),
                            onPressed: _searchWithFilters, // 필터 적용 버튼
                            // 필터 선택 로직 추가
                          ),
                        ],
                      ),
                      if (_isExpanded)
                        Column(
                          children: [
                            Divider(color: Colors.grey),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          if (_selectedItems >
                                              1) _selectedItems--;
                                        });
                                      },
                                    ),
                                    SizedBox(width: 5),
                                    Icon(Icons.shopping_bag,
                                        color: Color(0xFF43CBBA)),
                                    Text("캐리어 $_selectedItems개",
                                        style: TextStyle(fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(width: 5),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          _selectedItems++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: Color(0xFF43CBBA)),
                                    SizedBox(width: 5),
                                    Text(
                                      _selectedDateRange == null
                                          ? '날짜 선택'
                                          : '${_selectedDateRange!.start
                                          .toLocal()} - ${_selectedDateRange!
                                          .end.toLocal()}',
                                      style: TextStyle(fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.date_range),
                                  onPressed: _pickDateRange,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        color: Color(0xFF43CBBA)),
                                    SizedBox(width: 5),
                                    Text(
                                      _fromTime == null || _toTime == null
                                          ? '시간 선택'
                                          : '${_fromTime!.format(
                                          context)} - ${_toTime!.format(
                                          context)}',
                                      style: TextStyle(fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.schedule),
                                  onPressed: _pickTimeRange,
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }
}
