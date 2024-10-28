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

  // 초기 맵 위치 설정 (위도, 경도)
  final LatLng _initialPosition = const LatLng(37.5045563, 126.9569379); // 중앙대 위치 넣음

  // GoogleMap 위젯에서 카메라 제어
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }



  @override
  Widget build(BuildContext context){
    return Scaffold(
      // Scaffold로 화면 전체 레이아웃을 감싸고, 배경색을 설정
      body: Container(
        color: Color.fromARGB(255, 00, 206, 209), //홈화면 기본 색상 정하기
      ),
    );
  }
}