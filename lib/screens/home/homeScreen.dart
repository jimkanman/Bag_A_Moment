import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:bag_a_moment/screens/home/afterMarker/StorageDetailPage.dart';
import 'package:bag_a_moment/widgets/marker_details_widget.dart';
import 'package:http/http.dart' as http;
import 'package:bag_a_moment/model/searchModel.dart';
import 'package:bag_a_moment/service/storageService.dart';

import '../../main.dart';

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
  //2. 검색용
  final StorageService _storageService = StorageService();
  List<searchModel> _storages = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSearchActive = false;


  // dispose에서 컨트롤러 해제
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 1-1. 초기 맵 위치 설정 (위도, 경도) - 사용자 현위치로 수정
  late GoogleMapController _mapController;
  LatLng _currentPosition = const LatLng(37.5045563, 126.9569379);
  final double _currentLatitude = 37.5045563; // 사용자의 현재 위도
  final double _currentLongitude = 126.9569379; // 사용자의 현재 경도
  //현재는 우선 고정 위도 경도 사용함


  // 2. 선택된 마커 정보
  Map<String, dynamic>? _selectedMarkerInfo;
  // 2-1. 선택된 마커 위치 (상세 탭 위젯에 사용)
  LatLng? _selectedMarkerPosition;
  // 3. 마커 리스트
  final List<Marker> _markers = [];
  final Map<String, Map<String, dynamic>> _markerDetails = {}; // 마커 상세 정보 매핑





  // 5. 검색 필터 변수
  String _location = "현위치";
  int _selectedItems  = 1; // 초기값 설정
  int _smallBagItems =1;
  int _mediumBagItems =1;
  int _largeBagItems =1;
  DateTimeRange? _selectedDateRange;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  bool _isExpanded = false; // 검색창 확장 여부
  // 6. 미니 상세탭 클릭용
  bool _showExtraContainer = false;

// 초기화!
  void initState() {
    super.initState();
    _initializeMapRenderer();
    _requestLocationPermission();
    _getCurrentLocation();
    _fetchNearbyStorages(); // 서버에서 storage 목록 가져오기
  }

  //상단 검색창 확장
  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded; // 버튼 누르면 상태 토글
    });
  }

  // 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 사용 가능한지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화된 경우 사용자에게 알림
      return Future.error('위치 서비스가 꺼져 있습니다.');
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('위치 권한이 거부되었습니다.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('위치 권한이 영구적으로 거부되었습니다.');
    }

    // 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted){
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    }
    moveCameraTo(_currentPosition);
  }

  // 지도 이동 함수
  void _goToCurrentLocation() {
    _mapController.animateCamera(
      CameraUpdate.newLatLng(_currentPosition),
    );
  }

  void _initializeMapRenderer() {
    final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }
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

  void moveCameraTo(LatLng position) {
    _mapController.animateCamera(CameraUpdate.newLatLng(position));
  }


  /// 1. 서버에서 사용자의 현재 위치 기반 storage 정보 가져오기
  Future<void> _fetchNearbyStorages() async {


    //사용자 현위치 _initialPosition을 기반으로 주변 보관소 위치! GET 요청 날리기
    final String url = 'http://3.35.175.114:8080/storages/nearby?latitude=$_currentLatitude&longitude=$_currentLongitude&radius=10000';

    final token = await secureStorage.read(key: 'auth_token');
    // 로그인 토큰이 없으면 요청 중단
      if (token == null) {
        print("로그인 토큰이 만료되었습니다. 다시 로그인 해주세요.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 토큰이 만료되었습니다. 다시 로그인해주세요.')),
        );
        return;
      }
    // 요청 헤더에 토큰 추가
    final headers = {
      'accept': 'application/json',
      'Authorization': token, // 로그인 토큰 포함
    };
    // GET 요청 보내기, http응답 받아서 response에 저장


    try {
          final response = await http.get(Uri.parse(url), headers: headers);
          print('@@@@@@@@@@@@@@@@@@@@@서버와 통신 결과, @@@@@@@@@@@@@@@@@@@@@@@@@');
          print('Response.body : ${response.body}');
          print('Response.StatusCode: ${response.statusCode}');
          // UTF-8, json 디코딩
          final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
          print('@@@@@@@@@@@@@@@@@@@@@서버와 통신 결과, decoded @@@@@@@@@@@@@@@@@@@@@@@@@');
          print('jsonResponse Body: ${jsonResponse}');
          print('jsonResponse isSuccess:${jsonResponse['isSuccess']}');
          print('jsonResponse code:${jsonResponse['code']}');
          print('jsonResponse Message: ${jsonResponse['message']}');
          print('jsonResponse Body Data ${jsonResponse['data']}'); // 모든 보관소 정보 다 담겨서 오는  곳 이거!

      if (response.statusCode == 200) {

        // 서버에서 성공 응답인지 확인
        if (jsonResponse['isSuccess'] == true) {
          //서버에서 받은 주변 보관소 리스트에 따라
          // 그 위치에 마커를 표출해야 함


          final List<dynamic> storages = (jsonResponse['data'] is List)
              ? jsonResponse['data'] // 이미 리스트라면 그대로 사용
              : [jsonResponse['data']]; // Map이라면 리스트로 변환

          //이 부분은 storages를 리스트로 변환한것. -> 여전히 내용물은 객체덩어리로 옴!

            if (storages.isEmpty) {
              print('근처에 보관소 없음!.');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('근처에 보관소가 없습니다.')),
              );
            } else {
              // storage마다 addMarker 실행
              for (var storage in storages) {
                _addMarkers(storage);
                print('storage id checked, sent to addMarkers : ${storage['id']}');
              }
            }

     } else { //isSuccess가 fail인 경우
          print("Failed to fetch nearby storages: ${response.statusCode}");
          print('서버 응답 실패: ${jsonResponse['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('스토리지 로드 실패: ${jsonResponse['message']}')),
          );
        }
      } else { //응답 상태코드 200 아닌 경우

          print("Failed to fetch nearby storages: ${response.statusCode}");
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('스토리지 로드 실패: ${jsonResponse['message']}')),
          );
        }
    }  catch (e) {
    print("Error fetching nearby storages: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버와 통신이 끊어졌습니다.')),
      );
    }
    return;
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
  Future<void> _searchStorages(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final storages = await _storageService.fetchStorages(
        latitude: _currentPosition.latitude,
        longitude: _currentPosition.longitude,
        radius: 1000,
        searchTerm: query,
      );
      setState(() {
        _storages = storages;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

    //2. 마커 추가
    Future<void> _addMarkers(Map<String, dynamic> storage) async {
      print('Adding marker for storage: ${storage['id']}');

      // fromAssetImage를 사용하여 BitmapDescriptor 생성, 이미지로 아이콘 설정
      final BitmapDescriptor bagIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(60, 60)), // 크기 설정
        'assets/images/box_icon3.png', // 파일 경로
      );

      // 이에 따라 지도 상에 마커 표현하기

        final marker = Marker(
          markerId: MarkerId(storage['id'].toString()),
          position: LatLng(storage['latitude'], storage['longitude']),
          icon: bagIcon,
            onTap: () {
              setState(() {
                //여기는 출력 잘 됨
                print('스토리지 ${storage}');
                print('스토리지 이미지 ${storage['previewImagePath']}');
                _selectedMarkerInfo = {
                  'id': storage['id'],
                  'name': storage['name'],
                  'address': storage['detailedAddress'],
                  'description': storage['description'],
                  'tags': List<String>.from(storage['storageOptions'] ?? []),
                  //이미지 디버깅
                  'previewImagePath': storage['previewImagePath'] ?? 'https://jimkanman-bucket.s3.ap-northeast-2.amazonaws.com/defaults/jimkanman-default-preview-image.png',
                  'opentime': storage['openingTime'],
                  'closetime' :storage['closingTime'],
                };
                _selectedMarkerPosition = LatLng(
                  storage['latitude'],
                  storage['longitude'],
                );
                // _selectedMarkerPosition 설정 후 확인 로그 추가
                print('@@@@@@###########################################0');
                print("Selected Marker Position: $_selectedMarkerPosition");
                print("Selected Marker Position: $_selectedMarkerInfo");
              });
            }
        );

        setState(() {
          //받은 정보로 마커 위에 정보를 보이기.
          _markers.add(marker);
          _markerDetails[storage['id'].toString()] = {
            'name': storage['name'],
            'address': storage['detailedAddress'],
            'description': storage['description'],
            'tags': List<String>.from(storage['storageOptions'] ?? []),
            'previewImagePath': storage['previewImagePath'] ??
                'https://jimkanman-bucket.s3.ap-northeast-2.amazonaws.com/defaults/jimkanman-default-preview-image.png',
          };

        }); // 상태 갱신
      // 디버깅용: 전체 마커 개수 확인
      print('Total markers added: ${_markers.length}');
      print('Total recommendations: ${_storages.length}');
      print('Storage id: ${storage['id']}');
      print('기본 이미지: ${storage['previewImagePath']}'); //얘는 대체 어디서 온거? - 서버 기본 이미지
      print('스토리지 이미지: ${storage['previewImagePath']}'); //여기가 널로 나옴
      print('----------------------');
      }

  // 태그 맵 정의
  final Map<String, String> tagMap = {
    'PARKING': '주차 가능',
    'CART': '카트 사용',
    'BOX': '박스 제공',
    'TWENTY_FOUR_HOURS': '24시간',
    'CCTV': 'CCTV 설치',
    'INSURANCE': '보험 제공',
    'REFRIGERATION': '냉장 보관',
    'VALUABLES': '귀중품 보관',
    'OTHER': '기타',
  };




  @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: Stack(
          children: [
            //1. 지도
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,

              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 16.35,
              ),
              markers: Set.from(_markers),
              onTap: (_) {
                // 지도 클릭 시 선택된 정보 초기화
                setState(() {
                  _selectedMarkerInfo = null;
                });
              },
            ),
            //2. 현위치 버튼
            Positioned(
              bottom: 90,
              right: 10,
                child: Container(
                    decoration: BoxDecoration(
                    shape: BoxShape.circle, // 버튼을 동그라미로 설정
                    border: Border.all(
                    color: Color(0xFF4DD9C6), // 외곽선 색상
                    width: 2.0, // 외곽선 두께
                    ),
                    color: Colors.white, // 버튼 배경색
                  ),
                child: FloatingActionButton(
                  onPressed: _goToCurrentLocation,
                  backgroundColor: Colors.white, // 배경을 투명하게 설정 (Container 배경 활용)
                  elevation: 0,
                  child: const Icon(Icons.my_location, color: Color(0xFF4DD9C6)),
                ),
              ),
            ),


            //3. 상단 검색창
            Positioned(
              top: 20,
              left: 15,
              right: 15,
              child: _buildSearchBar(context),
            ),

          // 4. 홈화면 마커의 세부정보 띄우기
          _selectedMarkerInfo != null
          ? Positioned(
            top: MediaQuery.of(context).size.height / 2 - 20,
            left: MediaQuery.of(context).size.width / 2 - 150,
            width: 320, // 명시적 너비
            height: 120, // 명시적 높이
            child: _buildMarkerInfoWidget(context),
          )
            :SizedBox.shrink(),


            //5.하단 슬라이드 바
            DraggableScrollableBottomSheet(

              markers: _markers,
              markerDetails: _markerDetails, // 상세 정보 전달
            ),

          ],


        ),
      );
  }




  Widget _buildMarkerInfoWidget(BuildContext context){
    return GestureDetector(
      //behavior: HitTestBehavior.opaque,
      behavior: HitTestBehavior.opaque,
      onTap: (){
        print('마커 눌린 storageId: ${_selectedMarkerInfo!['id']}');
        setState(() {
          _showExtraContainer = !_showExtraContainer; // 상태 변경
        });
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
        maxWidth: 320, // 최대 너비
        maxHeight: MediaQuery.of(context).size.height / 3, // 최대 높이
        ),
      child:  Container(

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
          crossAxisAlignment: CrossAxisAlignment.start, //좌측정렬
          children: [
            // 왼쪽: 사진
            ClipRRect(
              borderRadius: BorderRadius.circular(8), // 둥근 모서리 처리
              child: Image.network(
                _selectedMarkerInfo!['previewImagePath'] ?? 'https://jimkanman-bucket.s3.ap-northeast-2.amazonaws.com/defaults/jimkanman-default-preview-image.png', // 이미지 URL
                width: 80, // 고정된 너비
                height: 80, // 고정된 높이
                fit: BoxFit.cover, // 이미지 크기 조정
              ),
            ),
            const SizedBox(width: 8), // 사진과 텍스트 사이 간격
            // 오른쪽: 텍스트와 태그
            Expanded(
              child: Container(
                width: 100,
                height: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start, // 좌측 정렬
                children: [

                    // 보관소 제목
                    GestureDetector(
                      onTap: () {
                        print('제목 눌린 storageId: ${_selectedMarkerInfo!['id']}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StorageDetailPage(storageId: _selectedMarkerInfo!['id']),
                          ),
                        );
                      },
                      child: Text(
                        _selectedMarkerInfo!['name'] ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 18,
                          fontFamily: 'Paperlogy',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis, // 넘칠 경우 "..." 표시
                        maxLines: 1, // 최대 한 줄로 제한
                      ),
                    ),

                  const SizedBox(height: 8),


                    // 영업중 텍스트
                    Text(
                      "영업중",
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Paperlogy',
                        fontWeight: FontWeight.w400, // Regular
                        color: Colors.green,
                      ),
                    ),
                  const SizedBox(height: 8),
                    // 태그 리스트
                    Wrap(

                      spacing: 8, // 태그 사이 간격
                      runSpacing: 4, // 줄 간격
                      children: (_selectedMarkerInfo!['tags'] as List<String>)
                          .map((tag) => IntrinsicWidth(
                        child: Container(

                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF3AC4B0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                          // child 부분 수정
                          child: Text(
                            tagMap[tag] ?? tag, // tagMap에서 태그에 해당하는 값이 없으면 기본적으로 영어 태그를 표시
                            style: TextStyle(
                              fontSize: 7,
                              fontFamily: 'Paperlogy',
                              fontWeight: FontWeight.w400, // Regular
                              color: Color(0xFFE0F7F5),
                            ),
                            overflow: TextOverflow.ellipsis, // 넘칠 경우 "..." 표시
                          ),
                      ),
                      ),
                      )
                          .toList(),
                    ),

                ],
              ),
            ),
            )
          ],

        ),
      ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Positioned(
      top: 35,
      left: 15,
      right: 15,
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
            // 검색창 또는 현위치 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _isSearchActive
                      ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: '검색어를 입력하세요',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (value) {
                            _searchStorages(value); // 검색 수행
                            setState(() {
                              _isSearchActive = false; // 검색창 비활성화
                            });
                          },
                        ),
                      ),
                        IconButton(
                          icon: Icon(Icons.close, color: Color(0xFF43CBBA)),
                          onPressed: () {
                            setState(() {
                              _isSearchActive = false; // 검색창 비활성화
                            });
                          },
                        ),
                    ],
                  )
                      : GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSearchActive = true; // 검색창 활성화
                          });
                       },
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Color(0xFF43CBBA)),
                              SizedBox(width: 5),
                              Text(
                                "현 위치",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.filter_list, color: Color(0xFF43CBBA)),
                  onPressed: _toggleExpansion, // 상태 토글 함수 호출
                ),
              ],
            ),

            // 확장 가능한 필터 섹션
            if (_isExpanded)
              Column(
                children: [
                  Divider(color: Colors.grey),
                  _buildFilterOptions(), // 필터 옵션 빌더 함수로 분리
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 소형 가방
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, size: 20), // 아이콘 크기 줄이기
                  onPressed: () {
                    setState(() {
                      if (_smallBagItems > 0) _smallBagItems--;
                    });
                  },
                ),

                Icon(Icons.backpack, color: Color(0xFF43CBBA), size: 20),
                SizedBox(width: 3), // 간격 조정
                Text(
                  "소형 $_smallBagItems개",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 3), // 간격 조정
                IconButton(
                  icon: Icon(Icons.add, size: 20),
                  onPressed: () {
                    setState(() {
                      _smallBagItems++;
                    });
                  },
                ),
              ],
            ),
            // 중형 가방
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, size: 20),
                  onPressed: () {
                    setState(() {
                      if (_mediumBagItems > 0) _mediumBagItems--;
                    });
                  },
                ),
                SizedBox(width: 3),
                Icon(Icons.shopping_bag, color: Color(0xFF43CBBA), size: 20),
                SizedBox(width: 3),
                Text(
                  "중형 $_mediumBagItems개",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 3),
                IconButton(
                  icon: Icon(Icons.add, size: 20),
                  onPressed: () {
                    setState(() {
                      _mediumBagItems++;
                    });
                  },
                ),
              ],
            ),
            // 대형 가방
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove, size: 20),
                  onPressed: () {
                    setState(() {
                      if (_largeBagItems > 0) _largeBagItems--;
                    });
                  },
                ),
                SizedBox(width: 3),
                Icon(Icons.luggage, color: Color(0xFF43CBBA), size: 20),
                SizedBox(width: 3),
                Text(
                  "대형 $_largeBagItems개",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 3),
                IconButton(
                  icon: Icon(Icons.add, size: 20),
                  onPressed: () {
                    setState(() {
                      _largeBagItems++;
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
                IconButton(
                  icon: Icon(Icons.date_range, color: Color(0xFF4DD9C6),),
                  onPressed: _pickDateRange,
                ),
                SizedBox(width: 5),
                Text(
                  _selectedDateRange == null
                      ? '날짜 선택'
                      : '${_selectedDateRange!.start.toLocal()} - ${_selectedDateRange!.end.toLocal()}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                IconButton(
                  icon: Icon(Icons.schedule, color: Color(0xFF4DD9C6),),
                  onPressed: _pickTimeRange,
                ),
                SizedBox(width: 5),
                Text(
                  _fromTime == null || _toTime == null
                      ? '시간 선택'
                      : '${_fromTime!.format(context)} - ${_toTime!.format(context)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

          ],
        ),
      ],
    );
  }



}

class DraggableScrollableBottomSheet extends StatelessWidget {
  final List<Marker> markers; // 마커 리스트를 받을 변수
  final Map<String, Map<String, dynamic>> markerDetails; // 마커 상세 정보 매핑
  DraggableScrollableBottomSheet({
    clipBehavior = Clip.hardEdge,
    required this.markers,
    required this.markerDetails,
  });// 생성자 추가






  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.1, // 화면의 5%만 보이도록 설정

      minChildSize: 0.05, // 최소 높이를 검은색 바 부분만 보이도록 설정

      maxChildSize: 0.8, // 최대 높이 설정


      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 검은색 바
              GestureDetector(
                onVerticalDragUpdate: (details) {
                  // 드래그 이벤트를 ScrollController에 전달
                  scrollController.jumpTo(scrollController.offset - details.delta.dy);
                },
                child: Center(
                  child: Container(
                    width: 40, // 검은색 바의 너비
                    height: 4, // 검은색 바의 높이
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // 2. 추천 짐스팟 Row
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: RecommendationTitle(),
              // ),
              // 3. 스크롤 가능한 리스트뷰
              Expanded( // 남은 공간을 스크롤 가능하도록 만듦
                child: ListView.builder(
                  controller: scrollController, // DraggableScrollableSheet와 연동
                  itemCount: markers.length + 1, // 마커 리스트의 길이를 기준으로 +1 (추천짐스팟 글씨)
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // 첫 번째 항목으로 추천 짐스팟 표시
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          "추천 짐스팟",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    } else if (index - 1 >= markers.length) {
                      // 유효하지 않은 인덱스 접근 방지
                      return const SizedBox.shrink();
                    }
                    final marker = markers[index - 1];
                    final markerInfo = markerDetails[marker.markerId.value]; // 매핑된 마커 정보 가져오기

                    return GestureDetector(
                      onTap: () {
                        // 마커 클릭 시 동작
                        print('Selected marker: $markerInfo');
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),

                        // 스와이프 창에 놓인 짐스팟 카드
                        child: GestureDetector(
                          onTap: () {
                            print(markerInfo);
                            final storageId = int.tryParse(marker.markerId.value);
                            if(storageId == null) {
                              return;
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder:
                                    (context) => StorageDetailPage(storageId: storageId), // TODO
                            ),
                          );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 왼쪽: 이미지
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  markerInfo?['previewImagePath'] ??
                                      'https://jimkanman-bucket.s3.ap-northeast-2.amazonaws.com/defaults/jimkanman-default-preview-image.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // 오른쪽: 텍스트 정보
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      markerInfo?['name'] ?? '보관소명',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      markerInfo?['address'] ?? '보관소 주소',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),




            ]
          )
        );
      }
    );
  }
}


              // ListView.builder(
              //   shrinkWrap: true, // 내부 스크롤을 위해 추가
              //   physics: NeverScrollableScrollPhysics(), // 외부 스크롤에만 반응
              //     controller: scrollController,
              //     itemCount:  markers.length,  // _markers 리스트의 길이를 기준으로? 일단 10개만?
              //     itemBuilder: (BuildContext context, int index) {
              //       return Padding(
              //           padding: const EdgeInsets.symmetric(vertical: 4.0), // 리스트 간의 간격 조정
              //       child: ListTile(
              //         leading: Icon(Icons.storage),
              //         title: Text("상도 스토리지 $index"),
              //         subtitle: Row(
              //           children: [
              //             Chip(
              //               label: Text("근접 보관"),
              //             ),
              //             SizedBox(width: 8),
              //             Chip(
              //               label: Text("냉장"),
              //             ),
              //             SizedBox(width: 8),
              //             Chip(
              //               label: Text("24시간"),
              //             ),
              //           ],
              //         ),
              //       ),
              //       );
              //     },
              //   ),





class SmallDragBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class RecommendationTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Text(
            "추천 짐스팟",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
