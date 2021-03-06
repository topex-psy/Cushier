import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:badges/badges.dart';
import 'package:expandable/expandable.dart';
import 'package:launch_review/launch_review.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'models/person.dart';
import 'utils/constants.dart';
import 'utils/provider.dart';
import 'utils/routes.dart';
import 'utils/utils.dart';
import 'utils/widgets.dart';
import 'admin.dart';
import 'dashboard.dart';
import 'intro.dart';
import 'splash.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    //cek apakah aplikasi berjalan dalam mode debug
    assert(isDebugMode = true);

    ThemeData lightTheme = ThemeData(
      primarySwatch: THEME_COLOR,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Color(0XFFF8F2FA),
      fontFamily: "Lato",
      textTheme: TextTheme(
        headline: TextStyle(fontSize: 30.0, fontFamily: 'FlamanteRoma'),
        title: TextStyle(fontSize: 20.0, fontFamily: 'FlamanteRoma'),
        body1: TextStyle(fontSize: 15.0, height: 1.4),
        body2: TextStyle(fontSize: 13.0, height: 1.4),
      ),
    );

    ThemeData darkTheme = ThemeData(
      primarySwatch: THEME_COLOR,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(0XFF262224),
      fontFamily: "Lato",
      textTheme: TextTheme(
        headline: TextStyle(fontSize: 30.0, fontFamily: 'FlamanteRoma'),
        title: TextStyle(fontSize: 20.0, fontFamily: 'FlamanteRoma'),
        body1: TextStyle(fontSize: 15.0, height: 1.4),
        body2: TextStyle(fontSize: 13.0, height: 1.4),
      ),
    );

    //pake bloc pattern untuk state management
    return ChangeNotifierProvider<AppState>(
      builder: (context) => AppState(),

      //menyediakan tema custom yang dapat dipilih secara runtime
      child: ThemeProvider(
        saveThemesOnChange: true,
        loadThemeOnInit: true,
        defaultThemeId: THEME_LIGHT,
        themes: [
          //AppTheme.light(), // This is standard light theme (id is default_light_theme)
          //AppTheme.dark(), // This is standard dark theme (id is default_dark_theme)
          AppTheme(
            id: THEME_LIGHT,
            description: "$APP_NAME Light Theme",
            data: lightTheme,
          ),
          AppTheme(
            id: THEME_DARK,
            description: "$APP_NAME Dark Theme",
            data: darkTheme,
          ),
        ],
        child: MaterialApp(
          title: APP_NAME,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: ThemeConsumer(child: Home()),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class MenuBar {
  MenuBar({@required this.value, this.icon, this.teks = "", this.isNonGuest = false});
  final MenuBarValues value;
  final IconData icon;
  final String teks;
  final bool isNonGuest;
}

enum MenuBarValues {
  PROFILE,
  ACCOUNT_SETTINGS,
  HELP_CENTER,
  RATE_US,
  LOGOUT,
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<TargetFocus> _targets = List();
  List<MenuBar> _menu = [
    MenuBar(value: MenuBarValues.PROFILE, icon: MdiIcons.account, teks: "Profil Saya", isNonGuest: true),
    MenuBar(value: MenuBarValues.ACCOUNT_SETTINGS, icon: MdiIcons.cogs, teks: "Pengaturan Akun", isNonGuest: true),
    MenuBar(value: null, isNonGuest: true),
    MenuBar(value: MenuBarValues.HELP_CENTER, icon: MdiIcons.humanGreeting, teks: "Pusat Bantuan"),
    MenuBar(value: MenuBarValues.RATE_US, icon: MdiIcons.commentMultiple, teks: "Rating & Feedback"),
    MenuBar(value: MenuBarValues.LOGOUT, icon: MdiIcons.logout, teks: "Keluar", isNonGuest: true),
  ];

  GlobalKey keyTour1 = GlobalKey();
  GlobalKey keyTour2 = GlobalKey();
  GlobalKey keyTour3 = GlobalKey();
  GlobalKey btnNotifKey = GlobalKey();

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
          appState.currentMenu = 3;
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
      bool isFirstRun = results['isFirstRun'] || (DEBUG_ONBOARDING && isDebugMode);
      print("FIRST RUUUUUUUUUUUUUUUUUUN = $isFirstRun");
      PersonApi me = results['me'];
      if (isFirstRun) {
        results = await Navigator.of(context).push(TransparentRoute(builder: (_) => Intro()));
        appState.currentMenu = 1;
        appState.isStarted = true;
        _showTour();
      } else if (me != null) {
        print("SET STARTED WITH PERSON: ${me?.namaLengkap}");
        currentPerson = me;
        appState.isLoggedIn = true;
        // appState.isStarted = true;
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String rememberMe = prefs.getString('rememberMe');
        if (rememberMe != null) {
          appState.isLoading = true;
          List<String> rememberData = rememberMe.split("|");
          getPerson(rememberData[1]).then((p) {
            print("DATA SAYA BERHASIL DIMUAT: ${p?.namaLengkap}");
            LoginForm(p).show(doOnDismiss: () => appState.isStarted = true);
          }).catchError((e) {
            print("DATA SAYA ERROOOOOOOOOOOOR 2: $e");
            appState.isStarted = true;
          }).whenComplete(() {
            print("DATA SAYA DONEEEEEEEEEEEEE 2!");
            appState.isLoading = false;
          });
        } else {
          appState.isStarted = true;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context);
      SharedPreferences.getInstance().then((prefs) {
        int lastMenuOpen = prefs.getInt('lastMenuOpen') ?? -1;
        if (lastMenuOpen > -1) appState.currentMenu = lastMenuOpen;
      });
      //appState.currentScaffoldKey = _scaffoldKey;
      print("LAUNCH SPLASH SCREEN!");
      _splashScreen();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _showNotif() {
    PopupMenu menu = PopupMenu(
      // backgroundColor: Colors.teal,
      // lineColor: Colors.tealAccent,
      // maxColumn: 2,
      items: [
        MenuItem(
            title: 'Home',
            // textStyle: TextStyle(fontSize: 10.0, color: Colors.tealAccent),
            image: Icon(
              Icons.home,
              color: Colors.white,
            )),
        MenuItem(
            title: 'Mail',
            image: Icon(
              Icons.mail,
              color: Colors.white,
            )),
        MenuItem(
            title: 'Power',
            image: Icon(
              Icons.power,
              color: Colors.white,
            )),
        MenuItem(
            title: 'Setting',
            image: Icon(
              Icons.settings,
              color: Colors.white,
            )),
        MenuItem(
            title: 'PopupMenu',
            image: Icon(
              Icons.menu,
              color: Colors.white,
            ))
      ],
      onClickMenu: (MenuItemProvider item) {
        print('notif menu -> ${item.menuTitle}');
      },
      stateChanged: (bool isShow) {
        print('notif menu is ${isShow ? 'showing' : 'closed'}');
      },
      onDismiss: () {
        print('notif menu is dismiss');
      },
    );
    menu.show(widgetKey: btnNotifKey);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    h = MyHelper(context);
    a = MyAppHelper(context);

    return WillPopScope(
      onWillPop: () async {
        if (!appState.isLoggedIn && appState.currentMenu > -1) {
          appState.currentMenu = -1;
          return false;
        }
        return h.showConfirm(
          pesan: "Apakah Anda yakin ingin menutup aplikasi ini?",
          aksi: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop')
        ) ?? false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: appState.isStarted ? a.uiAppBarColor() : Colors.white,
          elevation: 0.0,
          titleSpacing: 0.0,
          title: appState.isStarted ? Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: NavLogo(),
          ) : Container(),
          actions: appState.isStarted ? <Widget>[
            //TODO interval update DataJumlah.NOTIF
            !appState.isLoggedIn || (appState.jumlah[DataJumlah.NOTIF] ?? 0) == 0 ? SizedBox() : Badge(
              badgeColor: Colors.redAccent,
              badgeContent: Text("${appState.jumlah[DataJumlah.NOTIF]}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0, color: Colors.white)),
              position: BadgePosition.topRight(top: -3.0, right: 3.0),
              child: IconButton(key: btnNotifKey, icon: Icon(MdiIcons.bell, color: Colors.grey, size: 20.0), onPressed: _showNotif,),
            ),
            PopupMenuButton<MenuBarValues>(
              icon: Icon(!appState.isLoggedIn ? MdiIcons.menu : MdiIcons.account, color: Colors.grey),
              tooltip: "Menu",
              offset: Offset(0, 10.0),
              onSelected: (MenuBarValues value) {
                print("KLIK MENU = $value");
                switch (value) {
                  case MenuBarValues.PROFILE:
                    //TODO menu action profile
                    break;
                  case MenuBarValues.ACCOUNT_SETTINGS:
                    //TODO menu action account settings
                    break;
                  case MenuBarValues.HELP_CENTER:
                    //TODO menu action help center
                    break;
                  case MenuBarValues.RATE_US:
                    LaunchReview.launch();
                    break;
                  case MenuBarValues.LOGOUT:
                    firebaseAuth.currentUser().then((user) {
                      firebaseAuth.signOut().then((a) {
                        logout({'uid': user.uid}).then((status) {
                          print("POST LOGOUT STATUS: ${status?.status}");
                          print("POST LOGOUT PESAN: ${status?.message}");
                          currentPerson = null;
                          appState.isLoggedIn = false;
                        });
                      });
                    });
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return _menu.map<PopupMenuEntry<MenuBarValues>>((menu) {
                  if (menu.isNonGuest && !appState.isLoggedIn) return null;
                  return menu.value == null ? PopupMenuDivider(height: 10.0) : PopupMenuItem(value: menu.value, child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: <Widget>[
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
                child: !appState.isLoggedIn ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Selamat Datang!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                        SizedBox(height: 4.0,),
                        Text('Silakan pilih peran Anda untuk memulai pekerjaan:', style: TextStyle(fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("©${DateTime.now().year} $APP_AUTHOR", style: TextStyle(fontSize: 13.0),),
                        SizedBox(height: 10.0,),
                        h.html(
                          'Menggunakan aplikasi ini berarti menyetujui <a href="${APP_HOST}terms">Syarat Aturan</a> dan <a href="${APP_HOST}privacy">Kebijakan Privasi</a>',
                          textStyle: TextStyle(fontSize: 13.0, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.0,),
                ],) : Dashboard(),
              ),
            ),),
            appState.isStarted ? TopGradient() : Container(),
            Positioned.fill(child: appState.isStarted && !appState.isLoading ? Container() : Container(
              child: Visibility(visible: appState.isLoading, child: LoadingCircle(),),
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
  ExpandableController _expandableController;

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
      print("DATA PERSON ERROOOOOOOOOOOOR 1: $e");
    }).whenComplete(() {
      print("DATA PERSON DONEEEEEEEEEEEEE!");
    });
  }

  Future _cekLastPersons() async {
    final appState = Provider.of<AppState>(context);
    if (!appState.isLoggedIn && appState.isStarted) _introAnimation();

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
    _expandableController = ExpandableController()..addListener(() {
      final appState = Provider.of<AppState>(context);
      if (_expandableController.expanded) {
        appState.currentMenu = widget.pos;
        print("CURRENT MENU = ${widget.pos}");
        _animationController.reset();
        _animationController.forward();
      } else {
        if (appState.currentMenu == widget.pos) appState.currentMenu = -1;
      }
    });
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      print("CEK LAST PERSON!!!!!!!!!!!!!!!!!!!!!");
      _cekLastPersons();
    });
  }

  @override
  void didUpdateWidget(CardMenu oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("DID UPDATE WIDGET ${widget.info.judul}!!!!!");
      final appState = Provider.of<AppState>(context);
      if (appState.isStarted) {
        _introAnimation();
        if (appState.currentMenu != widget.pos && _expandableController.expanded) {
          _expandableController.toggle();
        }
      }
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _expandableController.dispose();
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

    final appState = Provider.of<AppState>(context);
    if (appState.currentMenu == widget.pos && !_expandableController.expanded) {
      _expandableController.toggle();
    }
  }

  _scan() {
    final appState = Provider.of<AppState>(context);
    a.scanQRLogin(onLoading: () => appState.isLoading = true, onDoneLoading: () => appState.isLoading = false, onSuccess: (p) => LoginForm(p).show());
  }

  _register() async {
    final appState = Provider.of<AppState>(context);
    if (widget.info.level == PersonLevel.USER_ADMIN) {
      Map results = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ThemeConsumer(child: RegisterAdmin(warna: widget.info.warna))));
      if (results != null && results.containsKey('me')) {
        print("REGISTER ADMIN RESULT = $results");
        PersonApi me = results['me'];
        currentPerson = me;
        appState.isLoggedIn = true;
      }
    } else _scan();
  }

  _login() {
    PersonApi p = PersonApi(uid: null, idLevel: widget.pos);
    LoginForm(p).show();
  }

  @override
  Widget build(BuildContext context) {
    Color flatColor = ThemeProvider.themeOf(context).id == THEME_LIGHT ? widget.info.warna : Colors.white;
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return AnimatedBuilder(
          animation: _introController,
          builder: (BuildContext context, Widget child) {
            return Transform.scale(
              scale: 1.0 + _intro.value * 0.3,
              //transform: Matrix4.translationValues(0, _intro.value * (100.0 + widget.pos * 0.0), 0)..scale(1.0 + _intro.value * 0.3),
              child: Opacity(
                opacity: _intro.value + 1.0,
                child: ExpandableNotifier(
                  child: ScrollOnExpand(
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CARD_RADIUS)),
                      clipBehavior: Clip.antiAlias,
                      elevation: CARD_ELEVATION,
                      key: widget.keyTour,
                      margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          //color: appState.currentMenu == widget.pos ? widget.info.warna.withOpacity(0.1) : Colors.transparent,
                          gradient: LinearGradient(
                            begin: FractionalOffset(0.0, 0.0), //Alignment.topLeft,
                            end: FractionalOffset(0.75, 1.0), //Alignment.bottomRight,
                            colors: [
                              appState.currentMenu == widget.pos ? widget.info.warna.withOpacity(0.2) : widget.info.warna.withOpacity(0.1),
                              appState.currentMenu == widget.pos ? widget.info.warna.withOpacity(0.1) : widget.info.warna.withOpacity(0.05),
                            ],
                          ),
                        ),
                        //padding: EdgeInsets.all(CARD_PADDING),
                        //color: appState.currentMenu == widget.pos ? widget.info.warna.withOpacity(0.1) : Colors.transparent,
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (BuildContext context, Widget child) {
                            Widget expandedWidget = Padding(padding: EdgeInsets.only(left: CARD_PADDING, right: CARD_PADDING, bottom: CARD_PADDING), child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                //SizedBox(height: 8.0,),
                                SizedBox(
                                  height: _lastPersons.isEmpty ? 0.0 : (_lastPersons.length * 70.0 + 8.0),
                                  child: ListView.builder(
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
                                          Icon(MdiIcons.login, size: 15.0, color: flatColor,),
                                          SizedBox(width: 5.0,),
                                          Text("Login", style: TextStyle(color: flatColor, fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                      onPressed: _login,
                                    ),
                                    SizedBox(height: 44.0, child: UiButton(color: widget.info.warna, teks: widget.info.level == PersonLevel.USER_ADMIN ? "Daftar Baru" : "Scan QR", ukuranTeks: 15.0, posisiTeks: MainAxisAlignment.center, icon: widget.info.level == PersonLevel.USER_ADMIN ? MdiIcons.accountPlus : MdiIcons.qrcodeScan, aksi: _register,),),
                                  ],),
                                ),
                              ],
                            ));
                            return ExpandablePanel(
                              controller: _expandableController,
                              header: InkWell(
                                splashColor: widget.info.warna.withOpacity(0.1),
                                highlightColor: widget.info.warna.withOpacity(0.1),
                                onTap: _expandableController.toggle,
                                child: Padding(
                                  padding: EdgeInsets.all(CARD_PADDING),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(widget.info.icon, color: widget.info.warna ?? Colors.grey, size: appState.currentMenu == widget.pos ? (50.0 + _animation.value * 10.0) : 50.0,),
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
                                      SizedBox(width: appState.currentMenu == widget.pos ? (20.0 - _animation.value * 10.0) : 20.0,),
                                      Transform.rotate(
                                        angle: appState.currentMenu == widget.pos ? (-0.5 * _animation.value * pi) : 0.0,
                                        child: Icon(Icons.chevron_right, color: Colors.grey, size: 25.0,),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              collapsed: Container(),
                              expanded: expandedWidget,
                              tapHeaderToExpand: false,
                              hasIcon: false,
                            );
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
      },
    );
  }
}

class LoginForm extends StatefulWidget {
  LoginForm(this.p);
  final PersonApi p;

  show({doOnDismiss}) => h.showAlert(
    header: Container(
      padding: EdgeInsets.all(20.0),
      color: listPersonLevel[p.idLevel]?.warna?.withOpacity(0.2),
      child: Row(children: <Widget>[
        CircleAvatar(backgroundImage: p.uid == null ? AssetImage("images/anon.png") : NetworkImage(p.foto),),
        SizedBox(width: 15.0,),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: p.uid == null ? <Widget>[
          Text(listPersonLevel[p.idLevel].judul, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
          SizedBox(height: 5.0,),
          Text("Login", style: TextStyle(fontSize: 14.0),),
        ] : <Widget>[
          Text(p.namaLengkap, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
          SizedBox(height: 4.0,),
          Text(p.email, style: TextStyle(fontSize: 12.0, color: Colors.blueGrey),),
          SizedBox(height: 4.0,),
          Text(p.level, style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
        ],)),
        SizedBox(width: 10.0,),
      ],),
    ),
    warnaAksen: listPersonLevel[p.idLevel]?.warna,
    showButton: false,
    isi: this,
  ).then((res) {
    if (doOnDismiss != null) doOnDismiss();
  });

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

  static const bool AUTOFOCUS = false;

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
      if (AUTOFOCUS) {
        FocusNode node = _isAnonymous ? _emailFocusNode : _sandiFocusNode;
        node.requestFocus();
      }
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
        appState.isLoading = true;

        print("STEP 2: cushier login using firebase user id");
        login({'uid': authResult.user.uid, 'pin': sandi}).then((status) {
          print("DATA LOGIN BERHASIL DIMUAT!");
          if (status.status == 0) {
            h.failAlertLogin(status.message);
            firebaseAuth.signOut();
          } else {
            PersonApi p = PersonApi.fromJson(status.result);
            currentPerson = p;
            appState.isLoggedIn = true;

            print("STEP 3: save last person, last menu, and remember");
            SharedPreferences.getInstance().then((prefs) {
              int menuOpen = appState.currentMenu;
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
          appState.isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return _isLoading ? Center(child: LoadingCircle(noCard: true)) : Column(
      children: <Widget>[
        //SizedBox(height: 20.0,),
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
            onPressed: () => a.scanQRLogin(
              onLoading: () {
                h.closeAlert();
                appState.isLoading = true;
              },
              onDoneLoading: () => appState.isLoading = false,
              onSuccess: (p) => LoginForm(p).show()
            ),
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
    List<String> date = time[0].split('-');
    List<String> clock = time[1].split(':');
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
        color: a.uiCardSecondaryColor(),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
        child: InkWell(
          splashColor: listPersonLevel[p.idLevel].warna.withOpacity(0.1),
          highlightColor: listPersonLevel[p.idLevel].warna.withOpacity(0.1),
          onTap: LoginForm(p).show,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(width: 4.0, color: a.uiCardSecondaryColor()),
              ),
            ),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.only(left: 8.0),
              leading: CircleAvatar(backgroundImage: NetworkImage(p.foto),),
              title: Text(p.namaLengkap, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),),
              subtitle: Row(children: <Widget>[
                Icon(Icons.access_time, color: Colors.grey, size: 14.0,),
                SizedBox(width: 4.0,),
                Expanded(
                  child: Text(timeago.format(timeAgo, locale: 'id'), style: TextStyle(fontSize: 12.0, color: Colors.blueGrey),),
                ),
              ],),
              trailing: IconButton(
                icon: Icon(MdiIcons.closeCircle),
                iconSize: 18.0,
                color: Colors.grey,
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}