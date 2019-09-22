import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_html/flutter_html.dart';
import '../models/person.dart';
import 'widgets.dart';

MyHelper h;
MyAppHelper a;
bool isDebugMode = false;

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

const int FAIL_DEFAULT = 0;
const int FAIL_USER_NOT_FOUND = 1;

class MyAppHelper {
  final BuildContext context;
  MyAppHelper(this.context);

  String generatePersonData(PersonApi p) {
    String res = "${p.idLevel}|${p.uid}";
    return res;
  }

  Future<String> scanQR() async {
    String barcode = "";
    try {
      barcode = await BarcodeScanner.scan();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        print("BARCODE GAGAL = The user did not grant the camera permission!");
      } else {
        print("BARCODE GAGAL = Unknown error: $e");
      }
    } on FormatException {
      print("BARCODE GAGAL = User returned using the \"back\"-button before scanning anything.");
    } catch (e) {
      print("BARCODE GAGAL = Unknown error: $e");
    }
    h.playSound("beep.mp3");
    return barcode;
  }

  //firebase login with email & password
  Future<AuthResult> firebaseLoginEmailPassword(String email, String password) {
    if (email == null || password == null) return null;
    if (email.isEmpty || password.isEmpty) return null;
    try {
      return firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).catchError((e) {
        print("FIREBASE LOGIN ERROR: $e");
      });
    } catch(e) {
      print(e);
      return null;
    }
  }
}

class MyHelper {
  final BuildContext context;
  MyHelper(this.context);

  AudioCache player = AudioCache();
  Size screenSize() => MediaQuery.of(context).size;
  playSound(String sound) => player.play(sound);

  screenPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  screenReset() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  showSnackbar(String pesan, {GlobalKey<ScaffoldState> scaffoldKey, String aksiLabel, void Function() aksi}) {
    final scaffold = scaffoldKey?.currentState ?? Scaffold.of(context);
    scaffold?.hideCurrentSnackBar();
    scaffold?.showSnackBar(SnackBar(
      content: Text(pesan),
      behavior: SnackBarBehavior.floating,
      action: aksiLabel == null ? null : SnackBarAction(
        onPressed: aksi,
        label: aksiLabel,
      ),
    ));
  }

  //fungsi untuk menampilkan popup dialog berisi pesan atau konten apapun
  showAlert({String judul, Widget isi, Widget listView, EdgeInsetsGeometry contentPadding, bool barrierDismissible = true, bool showButton = true, FlatButton customButton, Color warnaAksen, void Function() doOnDismiss}) async {
    player.play("butt_press.wav");
    await showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: barrierDismissible,
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Theme(
          //data: Theme.of(context).copyWith(primaryColor: warnaAksen ?? Theme.of(context).primaryColor),
          data: ThemeData(primarySwatch: warnaAksen ?? Theme.of(context).primaryColor, fontFamily: "Lato",),
          child: Transform(
            //transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            transform: Matrix4.identity()..scale(1.0, 1.0 + curvedValue, 1.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                title: judul != null ? Text(judul, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),) : null,
                content: listView ?? SingleChildScrollView(child: isi,),
                contentPadding: contentPadding ?? EdgeInsets.all(24.0),
                actions: showButton ? <Widget>[
                  customButton ?? FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("OK", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ] : null,
              ),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 500),
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) => Container()
    ).then((val) {
      if (doOnDismiss != null) doOnDismiss();
    });
  }

  //fungsi untuk menampilkan popup dialog konfirmasi
  showConfirm({String judul, String pesan, void Function() aksi, void Function() doOnCancel}) async {
    player.play("butt_press.wav");
    await showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Theme(
          data: ThemeData(primarySwatch: Theme.of(context).primaryColor, fontFamily: "Lato",),
          child: Transform(
            transform: Matrix4.identity()..scale(1.0, 1.0 + curvedValue, 1.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                title: judul != null ? Text(judul, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),) : null,
                content: SingleChildScrollView(child: Text(pesan, style: TextStyle(fontSize: 16.0, height: 1.4),),),
                contentPadding: EdgeInsets.only(left: 24.0, top: 24.0, right: 24.0, bottom: 12.0),
                actions: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: FlatButton(child: Text("Tidak", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),), onPressed: () {
                      if (doOnCancel != null) doOnCancel();
                      Navigator.of(context).pop(false);
                    },),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: FlatButton(child: Text("Ya", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),), onPressed: () {
                      aksi();
                      Navigator.of(context).pop();
                    },),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 500),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) => Container()
    );
  }

  //fungsi untuk menutup popup
  closeAlert() => Navigator.of(context, rootNavigator: true).pop('dialog');
  
  //fungsi untuk menampilkan popup memuat data
  loadAlert({String teks}) => showAlert(isi: LoadingCircle(noCard: true, teks: teks,), showButton: false, barrierDismissible: false);

  //fungsi untuk menampilkan popup pesan gagal
  failAlert(String judul, String pesan, {void Function() doOnRetry, void Function() doOnDismiss}) => showAlert(
    judul: judul,
    isi: Column(children: <Widget>[
      Text(pesan, style: TextStyle(height: 1.4),),
      SizedBox(height: 12.0,),
      Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: doOnRetry == null ? MainAxisAlignment.center : MainAxisAlignment.spaceAround, children: <Widget>[
        doOnRetry == null ? SizedBox() : FlatButton(
          child: Text("Coba Lagi", style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold),),
          onPressed: doOnRetry,
        ),
        FlatButton(
          child: Text("OK", style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold),),
          //onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],),
    ],),
    showButton: false,
    doOnDismiss: doOnDismiss,
  );

  //fungsi untuk menampilkan popup pesan gagal login
  failAlertInternet([String pesan]) {
    failAlert("Gagal Memuat", pesan ?? "Terjadi kendala saat memuat data. Harap periksa koneksi internet Anda!");
  }

  //fungsi untuk menampilkan popup pesan gagal login
  failAlertLogin([String pesan]) {
    failAlert("Login Gagal", pesan ?? "Terjadi kendala saat login. Coba kembali nanti!");
  }

  //fungsi yang mengembalikan teks versi html
  Html html(String htmlString, {TextStyle textStyle}) => Html(
    data: htmlString,
    defaultTextStyle: textStyle,
    onLinkTap: (url) {
      print("OPENING URL $url...");
    },
  );
}