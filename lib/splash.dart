import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/person.dart';
import 'utils/constants.dart';
import 'utils/utils.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController _animationController;
  Animation _animation1, _animation2;
  bool _isFirstRun = true;
  PersonApi _me;

  _lanjut() {
    Future.delayed(Duration(milliseconds: 2500), () => Navigator.of(context).pop({'isFirstRun': _isFirstRun, 'me': _me}));
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: Duration(seconds: 2), vsync: this);
    _animation1 = Tween(begin: 2.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceOut
    ));
    _animation2 = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.5, 1.0, curve: Curves.linear)
    ));
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
      SharedPreferences.getInstance().then((prefs) {
        _isFirstRun = prefs.getBool('isFirstRun') ?? true;
        prefs.setBool('isFirstRun', false);
        if (_isFirstRun) _lanjut(); else if (DEBUG_PERSON && isDebugMode) {
          _me = PersonApi.fromJson(DEBUG_PERSON_DATA);
          _lanjut();
        } else {
          _firebaseAuth.currentUser().then((user) {
            print("DATA SAYA CURRENT USEEEEEEEEEEEEEEEEEEEEEER: $user");
            if (user == null) _lanjut(); else getPerson(user.uid).then((me) {
              print("DATA SAYA BERHASIL DIMUAT: ${me?.namaLengkap}");
              _me = me;
            }).catchError((e) {
              print("DATA SAYA ERROOOOOOOOOOOOR: $e");
              _firebaseAuth.signOut();
            }).whenComplete(() {
              print("DATA SAYA DONEEEEEEEEEEEEE!");
              _lanjut();
            });
          });
        }
      });
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: Duration(milliseconds: 3000),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (BuildContext context, Widget child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: SPLASH_ICON_SIZE,
                    height: SPLASH_ICON_SIZE,
                    child: Transform.scale(
                      scale: _animation1.value,
                      child: Hero(tag: "SplashLogo", child: Image.asset(
                        "images/logo.png",
                        width: SPLASH_ICON_SIZE,
                        height: SPLASH_ICON_SIZE,
                        fit: BoxFit.contain,
                      ),),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Opacity(
                    opacity: _animation2.value,
                    child: Text(APP_TAGLINE, style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey)),
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }
}
