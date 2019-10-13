import 'package:flutter/material.dart';
import 'models/company.dart';
import 'utils/constants.dart';
import 'utils/utils.dart';

class PointOfSale extends StatefulWidget {
  PointOfSale({Key key, @required this.outlet}) : super(key: key);
  final OutletPOSApi outlet;

  @override
  _PointOfSaleState createState() => _PointOfSaleState();
}

class _PointOfSaleState extends State<PointOfSale> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  bool _isFinished = false;

  _sessionClose(BuildContext context) {
    Navigator.of(context).pop({'isFinished': _isFinished});
  }

  @override
  void initState() {
    _animationController = AnimationController(duration: Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    /* _animationController = AnimationController(duration: Duration(seconds: 2), vsync: this)..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    }); */
    _animation = Tween(begin: 1.0, end: 0.5).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    a = MyAppHelper(context);

    return Scaffold(
      backgroundColor: a.uiCardSecondaryColor(),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: GestureDetector(
                onTap: () => _sessionClose(context),
                child: Hero(tag: "SplashLogo", child: Image.asset(
                  "images/logo.png",
                  width: SPLASH_ICON_SIZE,
                  height: SPLASH_ICON_SIZE,
                  fit: BoxFit.contain,
                ),),
              ),
        );
      }
              ),
              Text("Memuat Point of Sale ...", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey),),
            ],
          ),
        ),
      ),
    );
  }
}