import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//홈화면 클래스 생성
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Google Map Controller
  late GoogleMapController mapController;
  // 검색 컨트롤러 초기화
  final TextEditingController _searchController = TextEditingController();
  // 초기 맵 위치 설정 (위도, 경도) - 사용자 현위치로 수정
  final LatLng _initialPosition = const LatLng(37.5045563, 126.9569379); // 중앙대 위치 넣음
  //마커 표시(추후 수정할 것-보관소 추가할 때)
  final Set<Marker> _markers = {};
  // 검색된 마커 리스트
  List<Marker> _filteredMarkers = [];
  String _location = "현위치";
  int _selectedItems = 1; // 초기값 설정
  DateTimeRange? _selectedDateRange;
  bool _isExpanded = false; // 검색창 확장 여부


  @override
  void initState() {
    super.initState();
    _addMarkers();
  }
// dispose에서 컨트롤러 해제
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 검색 기능
  void _searchMarkers(String query) {
    final results = _markers.where((marker) {
      return marker.infoWindow.title!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredMarkers = results;
    });
  }

  //필터
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


  // GoogleMap 위젯에서 카메라 제어
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // 마커로 카메라 이동
  void _moveToMarker(Marker marker) {
    mapController.animateCamera(CameraUpdate.newLatLng(marker.position));
  }



  Future<void> _addMarkers() async {
    // fromAssetImage를 사용하여 BitmapDescriptor 생성, 이미지로 아이콘 설정
    final BitmapDescriptor bagIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)), // 크기 설정
      'assets/images/box_icon.png', // 파일 경로
    );


    // 특정 위치에 마커 추가 1
    final Marker marker = Marker(
      markerId: MarkerId('chungang'),
      position: _initialPosition,
      infoWindow: InfoWindow(
        title: '중앙대학교',
        snippet: '중앙대학교 보관소 입니다.',
      ),
      icon: BitmapDescriptor.defaultMarker, // 기본 마커 아이콘
    );

    // 특정 위치에 마커 추가 2
    final marker2 = Marker(
      markerId: MarkerId('example'),
      position: LatLng(37.5700, 126.9830),
      infoWindow: InfoWindow(
        title: '종각역',
        snippet: '종각역 보관소 입니다.',
      ),
      icon: bagIcon, // custom한 가방 아이콘 사용
    );

    setState(() {
      _markers.add(marker); // 마커 추가
      _markers.add(marker2); // 마커 추가
      _filteredMarkers = _markers.toList(); // 초기 검색 결과는 모든 마커
    });
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
            markers: _markers,
          ),
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _location,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "가장 가까운 보관소 찾아보기",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: _searchMarkers,
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _openFilterDialog,
                          child: Text("필터 선택"),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _location,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "보관소 검색",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Icon(Icons.search),
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