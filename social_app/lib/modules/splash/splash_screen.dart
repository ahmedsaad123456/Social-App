import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:social_app/shared/components/components.dart';

// ignore: must_be_immutable
class SplashView extends StatefulWidget {
  Widget startWidget;
  SplashView(this.startWidget, {Key? key}) : super(key: key);

  @override
  _SplashViewState createState() => _SplashViewState(startWidget);
}

class _SplashViewState extends State<SplashView> {
  Widget startWidget;

  _SplashViewState(this.startWidget) : super();

  Timer? _timer;

  _startDelay() {
    _timer = Timer(Duration(seconds: 2), _goNext);
  }

  _goNext() async {
    navigateAndFinish(context, startWidget);
  }

  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#673ab7"),
      body: Center(
        child: Image(
          image: AssetImage("assets/images/splash3.png"),
        ),
      ),
    );
  }
}
