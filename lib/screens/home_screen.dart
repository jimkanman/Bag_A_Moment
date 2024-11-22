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
  // Google Map Controller
  late GoogleMapController mapController;

  // 선택된 마커 정보
  Map<String, dynamic>? _selectedMarkerInfo;
  // 선택된 마커 위치
  LatLng? _selectedMarkerPosition;

  final List<Marker> _markers = [];
  String? _selectedStorageId; //선택된 마커 아이디
  String? _selectedName; // 선택된 마커의 이름
  String? _selectedImageUrl; // 선택된 마커의 이미지 URL
  List<String>? _selectedTags; // 선택된 마커의 태그
  Offset? _markerScreenPosition; // 마커의 화면 좌표

  void initState() {
    super.initState();
    _requestLocationPermission();
    _addMarkers();
  }
  // 위치 권한 요청 함수
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


  // GoogleMap 위젯에서 카메라 제어
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // 검색 컨트롤러 초기화
  final TextEditingController _searchController = TextEditingController();

  // 초기 맵 위치 설정 (위도, 경도) - 사용자 현위치로 수정
  final LatLng _initialPosition = const LatLng(
      37.5045563, 126.9569379); // 중앙대 위치 넣음


  //마커 리스트
  List<Marker> _markerList = []; // 마커 리스트 저장
  // 검색된 마커 리스트
  //List<Marker> _filteredMarkers = [];

  //필터 변수값
  String _location = "현위치";
  int _selectedItems = 1; // 초기값 설정
  DateTimeRange? _selectedDateRange;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  bool _isExpanded = false; // 검색창 확장 여부

  // dispose에서 컨트롤러 해제
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        _markerList = results;
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
    Future<void> _addMarkers() async {
      // fromAssetImage를 사용하여 BitmapDescriptor 생성, 이미지로 아이콘 설정
      final BitmapDescriptor bagIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(150, 150)), // 크기 설정
        'assets/images/box_icon3.png', // 파일 경로
      );

      //서버에서 마커 정보 가져오기!
      List<Map<String, dynamic>> markerData = [
        {"storageId": "1", "lat": 37.5665, "lng": 126.9780},
        {"storageId": "2", "lat": 37.5651, "lng": 126.9895},
      ];

      //서버 데이터 기반으로 마커 추가
      for (var data in markerData) {
        _markers.add(
          Marker(
            markerId: MarkerId(data['storageId']),
            position: LatLng(data['lat'], data['lng']),
            onTap: () {
              // 클릭된 마커의 storageId 저장
              setState(() {
                _selectedStorageId = data['storageId'];
              });
              // 서버에서 상세 정보 가져오기
              _fetchStorageDetails(data['storageId']);
            },
          ),
        );
      }

      // 특정 위치에 마커 추가 1
      final marker = Marker(
        markerId: MarkerId('chungang'),
        position: LatLng(37.5045563, 126.9569379),
        onTap: () async {
          setState(() {
            _selectedMarkerInfo = {
              'name': '중앙 스토리지',
              'image': "https://via.placeholder.com/150", // 박스 이미지 경로
              'tags': ['큰 보관', '냉장', '24시간'],
            };
            // 클릭된 마커의 위치 저장
            _selectedMarkerPosition = LatLng(37.5045563, 126.9569379);
          });
          // 서버에서 보관소 정보를 받아옴
          //final storageInfo = await _fetchStorageDetails('1'); // 예제 storageId = '1'
          final response = await http.get(
            Uri.parse('http://3.35.175.114:8080/storages/1'),
            headers: {'accept': 'application/json'}, // 필수 헤더
          );


          // 마커 위치를 화면 좌표로 변환
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


  Future<void> _fetchStorageDetails(String storageId) async {
    final response = await http.get(
        Uri.parse('http://3.35.175.114:8080/storages/1')
    );

    if (response.statusCode == 200) {
      // 서버 응답을 JSON으로 디코딩
      final data = jsonDecode(response.body);
      setState(() {
        _selectedMarkerInfo = data; // 상세 정보 저장
      });
    } else {
      // 에러 처리
      print("Failed to load storage details: ${response.statusCode}");
    }

  }

  Future<void> _fetchMarkerData(String storageId) async {
    // 마커 데이터 API 요청
    final response = await http.get(Uri.parse('http://3.35.175.114:8080/$storageId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _selectedName = data['name'];
        _selectedImageUrl = data['imageUrl'];
        _selectedTags = List<String>.from(data['tags']);
      });
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

            // 마커 위 상세 정보 표시
            if (_markerScreenPosition != null &&_selectedName != null &&_selectedImageUrl != null &&_selectedTags != null)
            Positioned(
                left: _markerScreenPosition!.dx - 150, // 위젯의 중앙 정렬
                top: _markerScreenPosition!.dy - 120, // 마커 위쪽에 위치
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                          markerInfo: _selectedMarkerInfo!,
                          ),
                        ),
                      );
                    },
                    child: MarkerDetails(
                    name: _selectedName!,
                    imageUrl: _selectedImageUrl!,
                    tags: _selectedTags!,
                    ),

                  ),
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
