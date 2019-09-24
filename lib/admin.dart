import 'models/person.dart';
import 'package:flutter/material.dart';
import 'package:intervalprogressbar/intervalprogressbar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'models/company.dart';
import 'utils/utils.dart';
import 'utils/widgets.dart';

const int jumlahTahapDaftar = 3;

class RegisterAdmin extends StatefulWidget {
  RegisterAdmin({Key key, this.warna}) : super(key: key);
  final Color warna;

  @override
  _RegisterAdminState createState() => _RegisterAdminState();
}

class _RegisterAdminState extends State<RegisterAdmin> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _namaLengkapController;
  TextEditingController _tanggalLahirController;
  TextEditingController _nomorPonselController;
  TextEditingController _namaUsahaController;
  TextEditingController _kategoriUsahaController;
  TextEditingController _emailController;
  TextEditingController _sandiController;
  TextEditingController _konfirmSandiController;
  FocusNode _namaLengkapFocusNode;
  FocusNode _tanggalLahirFocusNode;
  FocusNode _nomorPonselFocusNode;
  FocusNode _namaUsahaFocusNode;
  FocusNode _kategoriUsahaFocusNode;
  FocusNode _emailFocusNode;
  FocusNode _sandiFocusNode;
  FocusNode _konfirmSandiFocusNode;

  List<String> _jenisKelaminLbl = ['Laki-laki', 'Perempuan'];
  List<String> _jenisKelaminVal = ['L', 'P'];

  String _jenisKelamin = 'L';
  String _tanggalLahir = "";
  int _idKategoriUsaha;

  PageController _pageController;
  double _pageValue = 0.0;
  int _tahap = 1;

  @override
  void initState() {
    super.initState();
    _namaLengkapController = TextEditingController();
    _tanggalLahirController= TextEditingController();
    _nomorPonselController= TextEditingController();
    _namaUsahaController = TextEditingController();
    _kategoriUsahaController = TextEditingController();
    _emailController = TextEditingController();
    _sandiController = TextEditingController();
    _konfirmSandiController = TextEditingController();
    _namaLengkapFocusNode = FocusNode();
    _tanggalLahirFocusNode = FocusNode();
    _nomorPonselFocusNode = FocusNode();
    _namaUsahaFocusNode = FocusNode();
    _kategoriUsahaFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _sandiFocusNode = FocusNode();
    _konfirmSandiFocusNode = FocusNode();

    _pageController = PageController(viewportFraction: 1.0, initialPage: _pageValue.toInt());
    _pageController.addListener(() {
      setState(() => _pageValue = _pageController.page);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _namaLengkapFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _namaLengkapController.dispose();
    _tanggalLahirController.dispose();
    _nomorPonselController.dispose();
    _namaUsahaController.dispose();
    _kategoriUsahaController.dispose();
    _emailController.dispose();
    _sandiController.dispose();
    _emailFocusNode.dispose();
    _sandiFocusNode.dispose();
    super.dispose();
  }

  _onPageChanged(int page) {
    setState(() {
      _tahap = page + 1;
      print("TAHAP REGISTRASI = $_tahap");
      switch (_tahap) {
        case 1:
          if (_namaLengkapController.text.isEmpty) _namaLengkapFocusNode.requestFocus();
          break;
        case 2:
          if (_namaUsahaController.text.isEmpty) _namaUsahaFocusNode.requestFocus();
          break;
        case 3:
          if (_emailController.text.isEmpty) _emailFocusNode.requestFocus();
          break;
      }
    });
  }

  _prev() {
    if (_tahap == 1) {
      h.showConfirm(
        judul: "Batal Mendaftar",
        pesan: "Apakah Anda yakin ingin membatalkan pendaftaran akun?",
        aksi: () {
          Navigator.of(context).pop();
        },
      );
    } else {
      _pageController.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeOutQuint);
    }
  }

  _next() {
    _invalid(String judul, String pesan, int page) {
      h.closeAlert();
      _pageController.animateToPage(page, duration: Duration(milliseconds: 200), curve: Curves.easeOut);
      h.failAlert(judul, pesan, doOnDismiss: () {
      });
    }

    if (_tahap == jumlahTahapDaftar) {
      h.loadAlert(teks: "Mendaftarkan akun ...");
      if (_tanggalLahir.isEmpty) {
        _invalid("Data Belum Lengkap", "Harap masukkan tanggal lahir Anda!", 0);
      } else if (_idKategoriUsaha == null) {
        _invalid("Data Belum Lengkap", "Harap pilih kategori usaha Anda!", 1);
      } else if (_sandiController.text != _konfirmSandiController.text) {
        _invalid("Konfirmasi PIN Tidak Cocok", "Harap periksa kembali PIN dan konfirmasi PIN Anda!", 2);
      } else {
        print(
          "\n nama_lengkap      = ${_namaLengkapController.text}" +
          "\n gender            = $_jenisKelamin" +
          "\n tanggal_lahir     = $_tanggalLahir" +
          "\n no_hp             = ${_nomorPonselController.text}" +
          "\n nama_usaha        = ${_namaUsahaController.text}" +
          "\n kategori_usaha    = ${_kategoriUsahaController.text}" +
          "\n id_kategori_usaha = $_idKategoriUsaha" +
          "\n email             = ${_emailController.text}" +
          "\n pin               = ${_sandiController.text}"
        );

        final PostRegister postData = PostRegister(
          namaLengkap: _namaLengkapController.text,
          gender: _jenisKelamin,
          tanggalLahir: _tanggalLahir,
          noHP: _nomorPonselController.text,
          namaUsaha: _namaUsahaController.text,
          idKategoriUsaha: _idKategoriUsaha,
          email: _emailController.text,
          pin: _sandiController.text,
        );

        print("STEP 1: register auth firebase dan dapetin uid (firebase user id)");
        firebaseAuth.createUserWithEmailAndPassword(
          email: postData.email,
          password: postData.pin,
        ).then((authResult) {
          print("authResult = $authResult");
          print("STEP 2: register data akun ke database cushier");
          postData.uid = authResult.user.uid;
          register(postData.toMap()).then((status) {
            print("DATA REGISTER STATUUUUUUUUUUUS: $status");
            h.closeAlert();
            var angka = status == null ? 0 : status.status;
            var pesan = status == null ? "Terjadi kendala saat memproses pendaftaran akun. Coba kembali nanti!" : status.message;
            if (angka == 1) {
              print(status.result);
              Navigator.of(context).pop({'me': PersonApi.fromJson(status.result)});
            } else {
              print("DATA REGISTER FAIIIIIIIIIIIIIL: $status");
              h.failAlert("Gagal Mendaftar", pesan);
            }
          }).catchError((e) {
            print("DATA REGISTER ERROOOOOOOOOOOOR: $e");
            //h.closeAlert();
            h.failAlert("Gagal Mendaftar", "Terjadi kendala saat memproses pendaftaran akun. Coba kembali nanti!");
          }).whenComplete(() {
            print("DATA REGISTER DONEEEEEEEEEEEEE!");
          });
        });
      }
    } else {
      _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeOutQuint);
    }
  }

  @override
  Widget build(BuildContext context) {
    h = MyHelper(context);
    a = MyAppHelper(context);

    return WillPopScope(
      onWillPop: () async {
        _prev();
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: Row(children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Image.asset("images/logo.png", width: 88.0, height: 40.0, fit: BoxFit.contain,),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Text("Daftar Akun", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Theme.of(context).primaryColor), textAlign: TextAlign.end,),
              ),
            ),
          ],),
          titleSpacing: 0.0,
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: <Widget>[
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 0.0,
                      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                          FormCaption(no: 1, icon: MdiIcons.accountEdit, teks: "Identitas Anda", warna: widget.warna,),
                          CardInput(icon: MdiIcons.accountTie, placeholder: "Nama lengkap", caps: TextCapitalization.words, controller: _namaLengkapController, focusNode: _namaLengkapFocusNode),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Jenis kelamin:", style: TextStyle(fontSize: 14.0, color: Colors.grey),),
                              SizedBox(height: 8.0,),
                              ToggleButtons(
                                borderRadius: BorderRadius.circular(20.0),
                                children: <Widget>[
                                  Row(children: <Widget>[
                                    SizedBox(width: 10.0),
                                    Icon(MdiIcons.genderMale),
                                    SizedBox(width: 5.0),
                                    Text(_jenisKelaminLbl[0]),
                                    SizedBox(width: 10.0),
                                  ],),
                                  Row(children: <Widget>[
                                    SizedBox(width: 10.0),
                                    Icon(MdiIcons.genderFemale),
                                    SizedBox(width: 5.0),
                                    Text(_jenisKelaminLbl[1]),
                                    SizedBox(width: 10.0),
                                  ],),
                                ],
                                onPressed: (int index) {
                                  setState(() {
                                    _jenisKelamin = _jenisKelaminVal[index];
                                  });
                                },
                                isSelected: <bool>[
                                  _jenisKelamin == _jenisKelaminVal[0],
                                  _jenisKelamin == _jenisKelaminVal[1],
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0,),
                          CardInput(icon: MdiIcons.calendar, placeholder: "Tanggal lahir", jenis: CardInputType.DATE_OF_BIRTH, controller: _tanggalLahirController, focusNode: _tanggalLahirFocusNode, initialValue: _tanggalLahir, onChanged: (val) {
                            try {
                              DateTime value = val;
                              setState(() {
                                _tanggalLahir = value.toString().substring(0, 10);
                                //_tanggalLahir = "${value.day.toString().padLeft(2,'0')}/${value.month.toString().padLeft(2,'0')}/${value.year}";
                              });
                              print("TANGGAL YANG DIPILIH = $_tanggalLahir");
                            } catch (e) {
                            }
                          },),
                          CardInput(icon: MdiIcons.cellphoneAndroid, placeholder: "Nomor ponsel", jenis: CardInputType.PHONE, controller: _nomorPonselController, focusNode: _nomorPonselFocusNode),
                          BottomNav(tahap: 1, prev: _prev, next: _next, warna: widget.warna),
                        ],),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 0.0,
                      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                          FormCaption(no: 2, icon: MdiIcons.officeBuilding, teks: "Informasi Usaha", warna: widget.warna,),
                          CardInput(icon: MdiIcons.officeBuilding, placeholder: "Nama usaha", caps: TextCapitalization.words, controller: _namaUsahaController, focusNode: _namaUsahaFocusNode),
                          CardInput(icon: MdiIcons.briefcaseSearch, placeholder: "Kategori usaha", controller: _kategoriUsahaController, focusNode: _kategoriUsahaFocusNode, klik: () {
                            h.showAlert(
                              contentPadding: EdgeInsets.zero,
                              showButton: false,
                              listView: ListCompanyField(onSelect: (int id, String teks) {
                                _kategoriUsahaController.text = teks;
                                _idKategoriUsaha = id;
                              },),
                            );
                          },),
                          BottomNav(tahap: 2, prev: _prev, next: _next, warna: widget.warna),
                        ],),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 0.0,
                      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                          FormCaption(no: 3, icon: MdiIcons.accountTie, teks: "Data Login", warna: widget.warna,),
                          CardInput(icon: MdiIcons.email, placeholder: "Alamat email", tipe: TextInputType.emailAddress, controller: _emailController, focusNode: _emailFocusNode),
                          CardInput(icon: MdiIcons.lock, placeholder: "Buat PIN", info: "6 Angka", jenis: CardInputType.PIN, controller: _sandiController, focusNode: _sandiFocusNode),
                          CardInput(icon: MdiIcons.lock, placeholder: "Konfirmasi PIN", jenis: CardInputType.PIN, controller: _konfirmSandiController, focusNode: _konfirmSandiFocusNode),
                          BottomNav(tahap: 3, prev: _prev, next: _next, warna: widget.warna),
                        ],),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TopGradient(),
            Positioned(top: 0, right: 20.0, child: IntervalProgressBar(
              direction: IntervalProgressDirection.horizontal,
              max: 3,
              progress: _tahap,
              intervalSize: 2,
              size: Size(h.screenSize().width - 200.0, 4.0),
              highlightColor: Theme.of(context).primaryColor,
              defaultColor: Colors.grey[400],
              intervalColor: Colors.transparent,
              intervalHighlightColor: Colors.transparent,
              radius: 2.0,
            ),),
            /* Positioned(top: 0, right: 0, child: LinearPercentIndicator(
              width: h.screenSize().width - 200.0,
              lineHeight: 4.0,
              animation: false,
              percent: (_pageValue + 1.0) / 3.0,
              linearStrokeCap: LinearStrokeCap.roundAll,
              progressColor: Theme.of(context).primaryColor,
            ),), */
          ],
        ),
      ),
    );
  }
}

class ListCompanyField extends StatefulWidget {
  ListCompanyField({Key key, @required this.onSelect}) : super(key: key);
  final void Function(int, String) onSelect;

  @override
  _ListCompanyFieldState createState() => _ListCompanyFieldState();
}

class _ListCompanyFieldState extends State<ListCompanyField> {
  Widget _child;

  _getListCompanyField() {
    setState(() { _child = null; });
    getListCompanyField().then((responseJson) {
      print("DATA COMPANY FIELD RESPONSE:" + responseJson.toString());
      if (responseJson == null) {
        h.failAlertInternet();
      } else {
        var result = responseJson["result"];
        List<CompanyField> listCompanyField = [];
        for (Map res in result) { listCompanyField.add(CompanyField.fromJson(res)); }
        setState(() {
          _child = Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            CardInput(icon: MdiIcons.magnify, placeholder: "Cari kategori", showLabel: false, borderColor: Colors.white, height: 60.0,),
            Flexible(child: ListView.separated(
              itemCount: listCompanyField.length,
              separatorBuilder: (context, index) => Divider(height: 1.0, color: Colors.grey[400],),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (context, index) => InkWell(
                onTap: () {
                  widget.onSelect(listCompanyField[index].id, listCompanyField[index].kategori);
                  h.closeAlert();
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Row(children: <Widget>[
                    Expanded(child: Text(listCompanyField[index].kategori, style: TextStyle(fontSize: 15.0, height: 1.0),),),
                    SizedBox(width: 10.0),
                    Icon(MdiIcons.chevronRight, color: Colors.grey,),
                  ],),
                ),
              ),
            ),),
            SizedBox(height: 20.0,),
          ],);
        });
        print("DATA COMPANY FIELD BERHASIL DIMUAT!");
      }
    }).catchError((e) {
      print("DATA COMPANY FIELD ERROOOOOOOOOOOOR: $e");
      h.failAlertInternet();
    }).whenComplete(() {
      print("DATA COMPANY FIELD DONEEEEEEEEEEEEE!");
    });
  }

  @override
  void initState() {
    _getListCompanyField();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (Widget child, Animation<double> animation) => FadeTransition(child: child, opacity: animation,),
        child: _child ?? LoadingCircle(noCard: true,),
      ),
    );
  }
}

class FormCaption extends StatelessWidget {
  FormCaption({Key key, this.no, this.icon, this.teks, this.warna}) : super(key: key);
  final int no;
  final IconData icon;
  final String teks;
  final Color warna;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Row(children: <Widget>[
        Icon(icon, color: warna, size: 40.0,),
        SizedBox(width: 8.0,),
        Text("$teks", style: TextStyle(fontSize: 16.0, fontFamily: 'FlamanteRoma', color: warna),),
      ],),
    );
  }
}

class BottomNav extends StatelessWidget {
  BottomNav({Key key, this.next, this.prev, this.tahap, this.warna}) : super(key: key);
  final void Function() prev;
  final void Function() next;
  final int tahap;
  final Color warna;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      SizedBox(height: 20.0,),
      Row(children: <Widget>[
        Expanded(child: Container(),),
        SizedBox(height: 46.0, width: 50.0, child: UiButton(color: Colors.grey, icon: MdiIcons.chevronLeft, aksi: prev,),),
        SizedBox(width: 10.0,),
        SizedBox(height: 46.0, child: UiButton(color: Theme.of(context).primaryColor, teks: tahap == jumlahTahapDaftar ? "Daftar" : "Lanjut", ukuranTeks: 15.0, posisiTeks: MainAxisAlignment.center, icon: tahap == jumlahTahapDaftar ? MdiIcons.check : MdiIcons.chevronRight, aksi: next,),),
      ],),
      SizedBox(height: 20.0,),
    ],);
  }
}