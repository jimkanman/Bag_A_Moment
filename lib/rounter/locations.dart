import 'package:beamer/beamer.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:bag_a_moment/screens/home_screen.dart';


//Beamer HomeLocation (인스턴스)
class HomeLocation extends BeamLocation {
  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable<dynamic> state) {
    return [
      BeamPage(
        child: HomeScreen(),
        key: ValueKey('home'),
      )
    ];
  }

  @override
  // TODO: implement pathPatterns
  List<Pattern> get pathPatterns => ['/home']; // 오류 방지용 경로 패턴 설정
}



