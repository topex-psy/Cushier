import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'models/person.dart';
import 'utils/constants.dart';
import 'utils/routes.dart';
import 'utils/utils.dart';
import 'utils/widgets.dart';
import 'admin.dart';
import 'dashboard.dart';
import 'intro.dart';
import 'splash.dart';

void main() => runApp(MyApp());

class AppState with ChangeNotifier {
  AppState();

  bool _isLoading = false;
  bool _isStarted = false;

  bool get isLoading => _isLoading;
  bool get isStarted => _isStarted;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  void setStarted() {
    _isStarted = true;
    notifyListeners();
  }
  void setStartedWithPerson(PersonApi person) {
    _currentPerson = person;
    _isStarted = true;
    notifyListeners();
  }

  //current person
  PersonApi _currentPerson;
  PersonApi get me => _currentPerson;
  void setCurrentPerson(PersonApi person) {
    _currentPerson = person;
    notifyListeners();
  }

  //current scaffold key
  GlobalKey<ScaffoldState> _currentScaffoldKey;
  GlobalKey<ScaffoldState> get getCurrentScaffoldKey => _currentScaffoldKey;
  void setCurrentScaffoldKey(GlobalKey<ScaffoldState> key) {
    _currentScaffoldKey = key;
    notifyListeners();
  }

  //current menu
  int _currentMenu = -1;
  int get getCurrentMenu => _currentMenu;
  void setCurrentMenu(int indeks) {
    _currentMenu = indeks;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    assert(isDebugMode = true);
    return ChangeNotifierProvider<AppState>(
      builder: (_) => AppState(),
      child: MaterialApp(
        title: APP_NAME,
        theme: ThemeData(
          primarySwatch: Colors.pink,
          scaffoldBackgroundColor: Color(0XFFF8F2FA),
          fontFamily: "Lato",
          textTheme: TextTheme(
            body1: TextStyle(fontSize: 15.0, height: 1.4),
            body2: TextStyle(fontSize: 13.0, height: 1.4),
          ),
        ),
        home: Home(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<TargetFocus> _targets = List();
  List<MenuBar> _menu = [
    MenuBar(value: "profile", icon: MdiIcons.account, teks: "Profil Saya", isNonGuest: true),
    MenuBar(value: "account_settings", icon: MdiIcons.cogs, teks: "Pengaturan Akun", isNonGuest: true),
    MenuBar(teks: "", isNonGuest: true),
    MenuBar(value: "help_center", icon: MdiIcons.libraryBooks, teks: "Pusat Bantuan"),
    MenuBar(value: "about_us", icon: MdiIcons.informationOutline, teks: "Tentang Kami"),
    MenuBar(value: "logout", icon: MdiIcons.logout, teks: "Keluar", isNonGuest: true),
  ];

  GlobalKey keyTour1 = GlobalKey();
  GlobalKey keyTour2 = GlobalKey();
  GlobalKey keyTour3 = GlobalKey();

  _showTour() {
    final appState = Provider.of<AppState>(context);
    if (_targets.isNotEmpty) TutorialCoachMark(
      context,
      targets: _targets,
      colorShadow: Theme.of(context).primaryColor,
      textSkip: "Lewati",
      paddingFocus: 10.0,
      clickTarget: (target) {
        if (target.identify.toString() == "Tour 1") {
          appState.setCurrentMenu(3);
        }
        print(target);
      },
      clickSkip: () {
        print("skip");
      },
      finish: () {
        print("finish");
      },
    )..show();
  }

  Future _splashScreen() async {
    final appState = Provider.of<AppState>(context);
    Map results = await Navigator.of(context).push(TransparentRoute(builder: (_) => Splash()));
    if (results != null) {
      bool isFirstRun = results['isFirstRun']; // || isDebugMode;
      print("FIRST RUUUUUUUUUUUUUUUUUUN = $isFirstRun");
      PersonApi me = results['me'];
      if (isFirstRun) {
        results = await Navigator.of(context).push(TransparentRoute(builder: (_) => Intro()));
        appState.setCurrentMenu(1);
        appState.setStarted();
        _showTour();
      } else if (me != null) {
        print("SET STARTED WITH PERSON: ${me?.namaLengkap}");
        appState.setStartedWithPerson(me);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String rememberMe = prefs.getString('rememberMe');
        if (rememberMe != null) {
          appState.setLoading(true);
          List<String> rememberData = rememberMe.split("|");
          getPerson(rememberData[1]).then((p) {
            print("DATA SAYA BERHASIL DIMUAT: ${p?.namaLengkap}");
            LoginForm(p).show(doOnDismiss: () => appState.setStarted());
          }).catchError((e) {
            print("DATA SAYA ERROOOOOOOOOOOOR 2: $e");
            appState.setStarted();
          }).whenComplete(() {
            print("DATA SAYA DONEEEEEEEEEEEEE 2!");
            appState.setLoading(false);
          });
        } else {
          appState.setStarted();
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _targets.add(
      TargetFocus(
        identify: "Tour 1",
        keyTarget: keyTour1,
        contents: [
          ContentTarget(
            align: AlignContent.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 30.0,),
                  Text(TOUR_TITLE1, style: TextStyle(
                    fontFamily: 'FlamanteRoma',
                    color: Colors.white,
                    fontSize: 20.0
                  ),),
                  SizedBox(height: 10.0,),
                  Text(TOUR_DESC1, style: TextStyle(color: Colors.white),),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    _targets.add(
      TargetFocus(
        identify: "Tour 2",
        keyTarget: keyTour2,
        contents: [
          ContentTarget(
            align: AlignContent.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(TOUR_TITLE2, style: TextStyle(
                    fontFamily: 'FlamanteRoma',
                    color: Colors.white,
                    fontSize: 20.0
                  ),),
                  SizedBox(height: 10.0,),
                  Text(TOUR_DESC2, style: TextStyle(color: Colors.white),),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    /* _targets.add(
      TargetFocus(
        identify: "Tour 3",
        keyTarget: keyTour3,
        contents: [
          ContentTarget(
            align: AlignContent.right,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Title lorem ipsum",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20.0
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin pulvinar tortor eget maximus iaculis.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ); */

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context);
      SharedPreferences.getInstance().then((prefs) {
        int lastMenuOpen = prefs.getInt('lastMenuOpen') ?? -1;
        if (lastMenuOpen > -1) appState.setCurrentMenu(lastMenuOpen);
      });
      appState.setCurrentScaffoldKey(_scaffoldKey);
      print("LAUNCH SPLASH SCREEN!");
      _splashScreen();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    h = MyHelper(context);
    a = MyAppHelper(context);

    return WillPopScope(
      onWillPop: () async {
        if (appState.getCurrentMenu > -1) {
          appState.setCurrentMenu(-1);
          return false;
        }
        return h.showConfirm(
          //judul: "Tutup Aplikasi",
          pesan: "Apakah Anda yakin ingin menutup aplikasi ini?",
          aksi: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop')
        ) ?? false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Color(0XFFF8F2FA),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0.0,
          titleSpacing: 0.0,
          title: appState.isStarted ? Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Hero(
              tag: "SplashLogo",
              child: Image.asset("images/logo.png", width: 88.0, height: 40.0, fit: BoxFit.contain,),
            ),
          ) : Container(),
          actions: appState.isStarted ? <Widget>[
            appState.me == null ? SizedBox() : IconButton(icon: Icon(MdiIcons.bell, color: Colors.grey, size: 20.0), onPressed: () {},),
            PopupMenuButton<String>(
              icon: Icon(appState.me == null ? MdiIcons.menu : MdiIcons.account, color: Colors.grey),
              tooltip: "Menu",
              offset: Offset(0, 10.0),
              onSelected: (String value) {
                print("KLIK MENU = $value");
                switch (value) {
                  //TODO menu action
                  case "profile": break;
                  case "account_settings": break;
                  case "help_center": break;
                  case "about_us": break;
                  case "logout":
                    firebaseAuth.currentUser().then((user) {
                      String uid = user.uid;
                      firebaseAuth.signOut().then((a) {
                        logout({'uid': uid}).then((status) {
                          print("POST LOGOUT STATUS: ${status?.status}");
                          print("POST LOGOUT PESAN: ${status?.message}");
                          appState.setCurrentPerson(null);
                        });
                      });
                    });
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return _menu.map<PopupMenuEntry<String>>((menu) {
                  if (menu.isNonGuest && appState.me == null) return null;
                  return menu.teks.isEmpty ? PopupMenuDivider(height: 10.0) : PopupMenuItem(value: menu.value, child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Icon(menu.icon, color: Colors.grey,),
                    SizedBox(width: 8.0,),
                    Text(menu.teks),
                  ],),);
                }).toList();
              },
            ),
            SizedBox(width: 10.0,),
          ] : null,
        ),
        body: SafeArea(
          child: Stack(children: <Widget>[
            Positioned.fill(child: Container(
              child: SingleChildScrollView(
                child: appState.me == null ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  SizedBox(height: 25.0,),
                  Column(
                    children: listPersonLevel.map((int i, PersonLevelInfo t) {
                      return MapEntry(i, CardMenu(
                        keyTour: t.level == PersonLevel.USER_ADMIN ? keyTour1 : (t.level == PersonLevel.USER_KASIR ? keyTour2 : GlobalKey()),
                        pos: i,
                        info: t,
                      ));
                    }).values.toList(),
                  ),
                  SizedBox(height: 35.0,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: h.html('Anda harus menyetujui <a href="${APP_HOST}terms">Syarat Aturan</a> dan <a href="${APP_HOST}privacy">Kebijakan Privasi</a>', textStyle: TextStyle(fontSize: 13.0)),
                  ),
                  SizedBox(height: 75.0,),
                ],) : Dashboard(me: appState.me),
              ),
            ),),
            Positioned(left: 0, right: 0, top: 0, child: IgnorePointer(child: Container(
              height: 20.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(1.0),
                    Colors.white.withOpacity(0.0),
                  ],
                  stops: [
                    0.0,
                    1.0,
                  ]
                ),
              ),
            ),),),
            Positioned.fill(child: appState.isStarted && !appState.isLoading ? Container() : Container(
              child: Visibility(visible: appState.isLoading, child: Center(child: LoadingCircle(),),),
              color: Colors.white,
            ),),
          ],),
        ),
      ),
    );
  }
}

class CardMenu extends StatefulWidget {
  CardMenu({Key key, this.keyTour, this.pos, this.info}) : super(key: key);
  final GlobalKey keyTour;
  final int pos;
  final PersonLevelInfo info;

  @override
  CardMenuState createState() => CardMenuState();
}

class CardMenuState extends State<CardMenu> with TickerProviderStateMixin {
  AnimationController _animationController;
  AnimationController _introController;
  Animation _animation;
  Animation _intro;
  bool _introDone = false;

  List<PersonApi> _lastPersons = [];

  _getLastPersons(String uids) {
    print("_getLastPersons ${widget.info.judul}: $uids");
    if (uids.isNotEmpty) getListPersons(uids: uids).then((responseJson) {
      print("DATA PERSON RESPONSE:" + responseJson.toString());
      if (responseJson == null) {
        print("DATA PERSON EXCEPTION NULL!");
      } else {
        var result = responseJson["result"];
        List<PersonApi> listLastPerson = [];
        for (Map res in result) { listLastPerson.add(PersonApi.fromJson(res)); }
        setState(() {
          _lastPersons = listLastPerson;
        });
        print("DATA PERSON BERHASIL DIMUAT!");
      }
      print("DATA PERSON BERHASIL DIMUAT!");
    }).catchError((e) {
      print("DATA PERSON ERROOOOOOOOOOOOR: $e");
    }).whenComplete(() {
      print("DATA PERSON DONEEEEEEEEEEEEE!");
    });
  }

  Future _cekLastPersons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> lastPersons = prefs.getStringList('lastPersons') ?? [];
    if (lastPersons.isNotEmpty) {
      List<String> listLastPersonUid = [];
      for (String data in lastPersons) {
        List<String> personData = data.split("|");
        if (widget.pos == int.parse(personData[0])) {
          listLastPersonUid.add(personData[1]);
        }
      }
      _getLastPersons(listLastPersonUid.join(","));
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    )..addStatusListener((status) {
      //if (status == AnimationStatus.completed) _exposeIt();
    }));
    _introController = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _intro = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOut,
    ));

    /* _lastPersons = [
      PersonApi(uid: '1', email: "regina@cushier.id", level: widget.judul, namaLengkap: "Regina Wardoyo", foto: "https://www.carapdkt.net/wp-content/uploads/2017/03/Cara-PDKT-Langsung-cewek-cantik.png", terakhir: "5 menit"),
      PersonApi(uid: '2', email: "yunisw@cushier.id", level: widget.judul, namaLengkap: "Yuni Saraswati", foto: "https://s.kaskus.id/images/2019/06/11/5595555_20190611050842.jpg", terakhir: "15 menit"),
    ]; */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      _cekLastPersons();
    });
  }

  @override
  void didUpdateWidget(CardMenu oldWidget) {
    print("DID UPDATE WIDGET ${widget.info.judul}!!!!!");
    final appState = Provider.of<AppState>(context);
    if (appState.isStarted) _introAnimation();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _introController.dispose();
    super.dispose();
  }

  _introAnimation() {
    if (_introDone) return;
    _introDone = true;
    Future.delayed(Duration(milliseconds: 500 + widget.pos * 150), () {
      _introController.forward();
    });
  }

  _toggleIt() {
    final appState = Provider.of<AppState>(context);
    print("TOGGLE CARD MENU ${widget.pos}: ${widget.info.judul}");
    if (appState.getCurrentMenu == widget.pos) {
      appState.setCurrentMenu(-1);
    } else {
      appState.setCurrentMenu(widget.pos);
      _animationController.reset();
      _animationController.forward();
    }
  }

  _scan() {
    final appState = Provider.of<AppState>(context);
    a.scanQR().then((uid) {
      if (uid.isNotEmpty) {
        print("BARCODE BERHASIL = $uid");
        h.showSnackbar("BARCODE BERHASIL = $uid", scaffoldKey: appState.getCurrentScaffoldKey);
        appState.setLoading(true);

        getPerson(uid).then((p) {
          print("DATA PERSON BERHASIL DIMUAT!");
          LoginForm(p).show();
        }).catchError((e) {
          print("DATA PERSON ERROOOOOOOOOOOOR: $e");
          h.failAlertLogin();
        }).whenComplete(() {
          print("DATA PERSON DONEEEEEEEEEEEEE!");
          appState.setLoading(false);
        });
      }
    });
  }

  _register() async {
    final appState = Provider.of<AppState>(context);
    if (widget.info.level == PersonLevel.USER_ADMIN) {
      Map results = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => RegisterAdmin(warna: widget.info.warna)));
      if (results != null && results.containsKey('me')) {
        print("REGISTER ADMIN RESULT = $results");
        PersonApi me = results['me'];
        appState.setCurrentPerson(me);
      }
    } else _scan();
  }

  _login() {
    PersonApi p = PersonApi(uid: null, idLevel: widget.pos);
    LoginForm(p).show();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return AnimatedBuilder(
        animation: _introController,
        builder: (BuildContext context, Widget child) {
          return Transform.scale(
            scale: 1.0 + _intro.value * 0.3,
            //transform: Matrix4.translationValues(0, _intro.value * (100.0 + widget.pos * 0.0), 0)..scale(1.0 + _intro.value * 0.3),
            child: Opacity(
              opacity: _intro.value + 1.0,
              child: Card(
                key: widget.keyTour,
                clipBehavior: Clip.antiAlias,
                elevation: 0.0,
                margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(40.0), side: BorderSide(
                  color: appState.getCurrentMenu == widget.pos ? HSLColor.fromColor(widget.info.warna).withLightness(0.85).toColor() : Colors.grey[350],
                  width: appState.getCurrentMenu == widget.pos ? 4.0 : 1.0,
                )),
                child: Material(
                  color: appState.getCurrentMenu == widget.pos ? HSLColor.fromColor(widget.info.warna).withLightness(0.95).toColor() : Colors.white,
                  child: InkWell(
                    splashColor: appState.getCurrentMenu == widget.pos ? Colors.transparent : widget.info.warna.withOpacity(0.1),
                    highlightColor: appState.getCurrentMenu == widget.pos ? Colors.transparent : widget.info.warna.withOpacity(0.1),
                    onTap: _toggleIt,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (BuildContext context, Widget child) {
                          return Column(children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(widget.info.icon, color: widget.info.warna ?? Colors.grey, size: appState.getCurrentMenu == widget.pos ? (50.0 + _animation.value * 10.0) : 50.0,),
                                SizedBox(width: 12.0,),
                                Expanded(
                                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                    SizedBox(height: 2.0,),
                                    Text(widget.info.judul, style: TextStyle(height: 1.2, fontSize: 16.0, fontFamily: 'FlamanteRoma'),),
                                    SizedBox(height: 6.0,),
                                    Text(widget.info.deskripsi, style: TextStyle(height: 1.2, fontSize: 13.0, color: Colors.blueGrey),),
                                    SizedBox(height: 6.0,),
                                  ],),
                                ),
                                SizedBox(width: appState.getCurrentMenu == widget.pos ? (20.0 - _animation.value * 10.0) : 20.0,),
                                Transform.rotate(
                                  angle: appState.getCurrentMenu == widget.pos ? (-0.5 * _animation.value * pi) : 0.0,
                                  child: Icon(Icons.chevron_right, color: Colors.grey, size: 30.0,),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: appState.getCurrentMenu == widget.pos ? (_lastPersons.length * 70.0 + 70.0) : 0.0,
                              child: Container(
                                child: AnimatedOpacity(
                                  opacity: appState.getCurrentMenu == widget.pos ? 1.0 : 0.0,
                                  duration: Duration(milliseconds: 200),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(height: 8.0,),
                                      Expanded(
                                        child: _lastPersons.isEmpty ? Container() : ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: _lastPersons.length,
                                          itemExtent: 70.0,
                                          itemBuilder: (context, index) {
                                            double offset = max(0, 200.0 - index * 50.0);
                                            return Transform.translate(
                                              offset: Offset(-offset + offset * _animation.value, 0),
                                              child: CardLastPerson(_lastPersons[index]),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        height: 55.0,
                                        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                                          FlatButton(
                                            child: Row(
                                              children: <Widget>[
                                                Icon(MdiIcons.login, size: 15.0, color: widget.info.warna ?? Colors.lightBlue,),
                                                SizedBox(width: 5.0,),
                                                Text("Login", style: TextStyle(color: widget.info.warna ?? Colors.lightBlue, fontWeight: FontWeight.bold),),
                                              ],
                                            ),
                                            onPressed: _login,
                                          ),
                                          SizedBox(height: 44.0, child: UiButton(color: widget.info.warna ?? Colors.lightBlue, teks: widget.info.level == PersonLevel.USER_ADMIN ? "Daftar Baru" : "Scan QR", ukuranTeks: 15.0, posisiTeks: MainAxisAlignment.center, icon: widget.info.level == PersonLevel.USER_ADMIN ? MdiIcons.accountPlus : MdiIcons.qrcodeScan, aksi: _register,),),
                                        ],),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],);
                        }
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
    );
  }
}

class LoginForm extends StatefulWidget {
  LoginForm(this.p);
  final PersonApi p;

  show({doOnDismiss}) => h.showAlert(isi: this, showButton: false, warnaAksen: listPersonLevel[p.idLevel]?.warna, doOnDismiss: doOnDismiss);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _rememberMe = false;
  TextEditingController _emailController;
  TextEditingController _sandiController;
  FocusNode _emailFocusNode;
  FocusNode _sandiFocusNode;
  bool _isAnonymous;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _sandiController = TextEditingController();
    _emailFocusNode = FocusNode();
    _sandiFocusNode = FocusNode();
    _isAnonymous = widget.p.uid == null;
    _isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //FocusNode node = _isAnonymous ? _emailFocusNode : _sandiFocusNode;
      //node.requestFocus();
      _rememberCheck();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _sandiController.dispose();
    _emailFocusNode.dispose();
    _sandiFocusNode.dispose();
    super.dispose();
  }

  _rememberCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString('rememberMe');
    if (data != null) {
      List<String> personData = data.split("|");
      if (!_isAnonymous && widget.p.uid == personData[1]) {
        setState(() { _rememberMe = true; });
      }
    }
  }

  _login() async {
    final appState = Provider.of<AppState>(context);
    String email = _isAnonymous ? _emailController.text : widget.p.email;
    String sandi = _sandiController.text;
    if (_isAnonymous && (email.isEmpty || sandi.isEmpty)) {
      h.failAlert("Login Gagal", "Harap masukkan email dan nomor PIN Anda!", doOnDismiss: () {
        if (email.isEmpty) _emailFocusNode.requestFocus(); else _sandiFocusNode.requestFocus();
      });
    } else if (sandi.isEmpty) {
      h.failAlert("Login Gagal", "Harap masukkan nomor PIN Anda!", doOnDismiss: () {
        _sandiFocusNode.requestFocus();
      });
    } else {
      setState(() { _isLoading = true; });

      print("STEP 1: firebase login");
      print("WILL LOGIN ...............\nemail = $email\nsandi = $sandi");
      final AuthResult authResult = await a.firebaseLoginEmailPassword(email, sandi);
      if (authResult == null) {
        setState(() { _isLoading = false; });
        h.failAlertLogin();
      } else {
        print("FIREBASE USER = ${authResult.user}");
        h.closeAlert();
        appState.setLoading(true);

        print("STEP 2: cushier login using firebase user id");
        login({'uid': authResult.user.uid, 'pin': sandi}).then((status) {
          print("DATA LOGIN BERHASIL DIMUAT!");
          if (status.status == 0) {
            h.failAlertLogin(status.message);
            firebaseAuth.signOut();
          } else {
            PersonApi p = PersonApi.fromJson(status.result);
            appState.setCurrentPerson(p);

            print("STEP 3: save last person, last menu, and remember");
            SharedPreferences.getInstance().then((prefs) {
              int menuOpen = appState.getCurrentMenu;
              prefs.setInt('lastMenuOpen', menuOpen);
              if (_rememberMe) prefs.setString('rememberMe', a.generatePersonData(widget.p));
              List<String> lastPersons = prefs.getStringList('lastPersons') ?? [];
              String thisPerson = a.generatePersonData(p);
              if (!lastPersons.contains(thisPerson)) {
                lastPersons.add(thisPerson);
                prefs.setStringList('lastPersons', lastPersons);
              }
            });
          }
        }).catchError((e) {
          print("DATA LOGIN ERROOOOOOOOOOOOR: $e");
          h.failAlertLogin();
          firebaseAuth.signOut();
        }).whenComplete(() {
          print("DATA LOGIN DONEEEEEEEEEEEEE!");
          appState.setLoading(false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return _isLoading ? Center(child: LoadingCircle(noCard: true)) : Column(
      children: <Widget>[
        Row(children: <Widget>[
          CircleAvatar(backgroundImage: _isAnonymous ? AssetImage("images/anon.png") : NetworkImage(widget.p.foto),),
          SizedBox(width: 15.0,),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _isAnonymous ? <Widget>[
            Text("Login ${listPersonLevel[widget.p.idLevel].judul}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
          ] : <Widget>[
            Text(widget.p.namaLengkap, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
            SizedBox(height: 4.0,),
            Text(widget.p.email, style: TextStyle(fontSize: 12.0, color: Colors.blueGrey),),
            SizedBox(height: 4.0,),
            Text(widget.p.level, style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
          ],)),
          SizedBox(width: 10.0,),
        ],),
        SizedBox(height: 20.0,),
        _isAnonymous ? CardInput(icon: MdiIcons.email, placeholder: "Alamat email", controller: _emailController, focusNode: _emailFocusNode, aksi: (String val) => _login()) : SizedBox(),
        CardInput(icon: MdiIcons.lock, placeholder: "Masukkan PIN", jenis: CardInputType.PIN, controller: _sandiController, focusNode: _sandiFocusNode, aksi: (String val) => _login()),
        SizedBox(height: 5.0,),
          CheckboxListTile(
            title: Text("Selalu gunakan akun ini pada ponsel ini", style: TextStyle(fontSize: 13.0),),
            value: _rememberMe,
            onChanged: (bool value) {
              setState(() { _rememberMe = value; });
            },
          ),
        SizedBox(height: 12.0,),
        Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceAround, children: <Widget>[
          FlatButton(
            onPressed: () {
              a.scanQR().then((uid) {
                if (uid.isNotEmpty) {
                  print("BARCODE BERHASIL = $uid");
                  Navigator.of(context).pop();
                  h.showSnackbar("BARCODE BERHASIL = $uid", scaffoldKey: appState.getCurrentScaffoldKey);
                  appState.setLoading(true);

                  getPerson(uid).then((p) {
                    if (p == null) {
                      print("DATA SAYA NUUUUUUUUUUUUULL!");
                      appState.setLoading(false);
                      h.failAlertLogin();
                    } else if (p.uid.isEmpty) {
                      print("DATA SAYA INVALIIIIIIIIIID!");
                      appState.setLoading(false);
                      h.failAlertLogin("Akun tidak terdaftar!");
                    } else {
                      print("DATA SAYA BERHASIL DIMUAT!");
                      LoginForm(p).show();
                    }
                  }).catchError((e) {
                    print("DATA SAYA ERROOOOOOOOOOOOR 1: $e");
                    appState.setLoading(false);
                    h.failAlertLogin();
                  }).whenComplete(() {
                    print("DATA SAYA DONEEEEEEEEEEEEE 1!");
                  });
                }
              });
            },
            child: Text("Scan QR", style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold),),
          ),
          FlatButton(
            onPressed: _login,
            child: Text("Masuk", style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold),),
          ),
        ],),
      ],
    );
  }
}

class CardLastPerson extends StatelessWidget {
  CardLastPerson(this.p);
  final PersonApi p;

  @override
  Widget build(BuildContext context) {
    List<String> time = p.terakhir.split(' ');
    List<String> date = time[0].split('-'); //List<int>.from(time[0].split('-'));
    List<String> clock = time[1].split(':'); //time[1].split(':').map((s) => int.parse(s));
    DateTime timeAgo = DateTime(
      int.parse(date[0]),
      int.parse(date[1]),
      int.parse(date[2]),
      int.parse(clock[0]),
      int.parse(clock[1]),
      int.parse(clock[2]),
    );

    timeago.setLocaleMessages('id', timeago.IdMessages());

    return Container(
      child: Card(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          splashColor: listPersonLevel[p.idLevel].warna.withOpacity(0.1),
          highlightColor: listPersonLevel[p.idLevel].warna.withOpacity(0.1),
          onTap: () => LoginForm(p).show(),
          child: Row(children: <Widget>[
            SizedBox(
              width: 4.0,
              height: double.infinity,
              child: Material(color: listPersonLevel[p.idLevel].warna,),
            ),
            Expanded(
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.only(left: 8.0),
                leading: CircleAvatar(backgroundImage: NetworkImage(p.foto),),
                title: Text(p.namaLengkap, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),),
                subtitle: Row(children: <Widget>[
                  Icon(Icons.access_time, color: Colors.grey, size: 14.0,),
                  SizedBox(width: 4.0,),
                  Text(timeago.format(timeAgo, locale: 'id'), style: TextStyle(fontSize: 12.0, color: Colors.blueGrey),),
                ],),
                trailing: IconButton(
                  icon: Icon(MdiIcons.closeCircle),
                  iconSize: 18.0,
                  color: Colors.grey,
                  onPressed: () {},
                ),
              ),
              /* child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(children: <Widget>[
                  CircleAvatar(backgroundImage: NetworkImage(p.foto),),
                  SizedBox(width: 15.0,),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Text(p.namaLengkap, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),),
                    SizedBox(height: 2.0,),
                    Row(children: <Widget>[
                      Icon(Icons.access_time, color: Colors.grey, size: 14.0,),
                      SizedBox(width: 4.0,),
                      Text(p.terakhir, style: TextStyle(fontSize: 12.0, color: Colors.blueGrey),),
                    ],),
                  ],)),
                  SizedBox(width: 10.0,),
                  Icon(MdiIcons.closeCircle, size: 18.0, color: Colors.grey,),
                  SizedBox(width: 5.0,),
                ],),
              ), */
            ),
          ],),
        ),
      ),
    );
  }
}