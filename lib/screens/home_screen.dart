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

  // GoogleMap 위젯에서 카메라 제어
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

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

  // 마커로 카메라 이동
  void _moveToMarker(Marker marker) {
    mapController.animateCamera(CameraUpdate.newLatLng(marker.position));
  }



  Future<void> _addMarkers() async {
    // fromAssetImage를 사용하여 BitmapDescriptor 생성, 이미지로 아이콘 설정
    final BitmapDescriptor bagIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)), // 크기 설정
      'assets/images/bag_icon.png', // 파일 경로
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
      appBar: AppBar(title: const Text("보관소 검색하기")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "가장 가까운 보관소 찾아보기",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: _searchMarkers, // 입력할 때마다 검색
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 14.0, // 초기 줌 레벨
                  ),
                  markers: _markers, // 마커 설정
                ),
                if (_searchController.text.isNotEmpty)
                  Positioned(
                    top: 60,
                    left: 15,
                    right: 15,
                    child: Material(
                      color: Colors.white,
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredMarkers.length,
                        itemBuilder: (context, index) {
                          final marker = _filteredMarkers[index];
                          return ListTile(
                            title: Text(marker.infoWindow.title!),
                            onTap: () {
                              _moveToMarker(marker); // 클릭 시 지도 이동
                              _searchController.clear(); // 검색창 지우기
                              setState(() {
                                _filteredMarkers = _markers.toList();
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}