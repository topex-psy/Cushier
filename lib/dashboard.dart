import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:showcaseview/showcaseview.dart';
import 'models/company.dart';
import 'models/person.dart';
import 'utils/constants.dart';

class Dashboard extends StatelessWidget {
  Dashboard({Key key, this.me}) : super(key: key);
  final PersonApi me;

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(
        builder: (context) => DashboardAdmin(me: me,),
      ),
    );
  }
}

class DashboardAdmin extends StatefulWidget {
  DashboardAdmin({Key key, this.me}) : super(key: key);
  final PersonApi me;

  @override
  _DashboardAdminState createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> with TickerProviderStateMixin {
  GlobalKey _showCaseKey1 = GlobalKey();
  GlobalKey _showCaseKey2 = GlobalKey();
  CompanyApi _company;
  List<String> _companyNames = [];
  String _companyName;

  bool _isLoading = true;
  AnimationController _animationController;
  Animation _animation;

  _getDataUsaha() {
    getListCompany(uid: widget.me.uid).then((responseJson) {
      print("DATA LIST COMPANY RESPONSE:" + responseJson.toString());
      if (responseJson == null) {
        print("DATA LIST COMPANY EXCEPTION NULL!");
      } else {
        List<String> listCompanyNames = [];
        CompanyApi myCompany;
        String myCompanyName;

        for (Map res in responseJson["result"]) {
          CompanyApi company = CompanyApi.fromJson(res);
          listCompanyNames.add(company.judul);
          if (company.id == widget.me.idUsaha) {
            print("ID USAHA SAYA = ${widget.me.idUsaha}");
            if ((company.logo ?? "").isEmpty) {
              Future.delayed(Duration(milliseconds: 500), () {
                ShowCaseWidget.of(context).startShowCase([_showCaseKey1]);
              });
            }
            myCompany = company;
            myCompanyName = company.judul;
          }
        }

        setState(() {
          _company = myCompany;
          _companyName = myCompanyName;
          _companyNames = listCompanyNames;
        });
        print("DATA LIST COMPANY BERHASIL DIMUAT!");
      }
      print("DATA LIST COMPANY BERHASIL DIMUAT!");
    }).catchError((e) {
      print("DATA LIST COMPANY ERROOOOOOOOOOOOR 1: $e");
    }).whenComplete(() {
      print("DATA LIST COMPANY DONEEEEEEEEEEEEE!");
      Future.delayed(Duration(milliseconds: 2000), () {
        setState(() {
          _isLoading = false;
          _animationController.forward();
        });
      });
    });
  }

  @override
  void initState() {
    _animationController = AnimationController(duration: Duration(seconds: 2), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getDataUsaha();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
    ? Padding(padding: EdgeInsets.only(top: 100.0), child: Center(child: Welcome(),),)
    : AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(opacity: _animation.value, child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(children: <Widget>[
            SizedBox(height: 15.0,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Halo, ${widget.me.namaLengkap}!", textAlign: TextAlign.start, style: TextStyle(fontSize: 16.0),),
                      _company == null ? SizedBox() : DropdownButton(
                        value: _companyName,
                        hint: Text("Pilih Usaha"),
                        style: TextStyle(fontSize: 16.0, color: Colors.black87),
                        onChanged: (String newValue) {
                          setState(() {
                            _companyName = newValue;
                            _isLoading = true;
                            //TODO set _company
                          });
                          Future.delayed(Duration(milliseconds: 2000), () {
                            setState(() {
                              _isLoading = false;
                            });
                          });
                        },
                        items: _companyNames.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  )),
                  SizedBox(width: 15.0,),
                  Expanded(
                    child: Showcase(
                      key: _showCaseKey1,
                      title: 'Logo Anda',
                      description: 'Anda dapat mengatur gambar logo usaha Anda.',
                      showcaseBackgroundColor: Colors.blueAccent,
                      textColor: Colors.white,
                      shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                        Image.asset("images/dummy.png", width: 200.0, fit: BoxFit.contain,),
                        FlatButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                          child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                            Icon(MdiIcons.pencil, size: 14.0, color: Colors.blue,),
                            SizedBox(width: 4.0,),
                            Text("Ubah Logo", style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.end,),
                          ],),
                        ),
                      ],),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.0,),
            Column(children: <Widget>[
              CardSale(),
              IntrinsicHeight(
                child: Row(children: <Widget>[
                  Expanded(child: CardItem(tag: "outlet", key: _showCaseKey2, warna: Colors.purple, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Icon(MdiIcons.store, color: Colors.purple[400], size: 40.0,),
                    Text("Outlet", style: TextStyle(fontSize: 18.0, fontFamily: 'FlamanteRoma',),),
                    Text("5 Lokasi", style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
                  ],),),),
                  SizedBox(width: 10.0,),
                  Expanded(flex: 2, child: CardItem(tag: "product", warna: Colors.brown, status: ItemStatus.WARNING, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        Icon(MdiIcons.widgets, color: Colors.brown[400], size: 40.0,),
                        Text("Produk", style: TextStyle(fontSize: 18.0, fontFamily: 'FlamanteRoma',),),
                        Text("100 Unit, 8 Kategori", style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
                      ],),
                    ),
                    CircularPercentIndicator(
                      radius: 75.0,
                      lineWidth: 9.0,
                      animation: true,
                      animationDuration: 1000,
                      percent: 0.7,
                      center: Text(
                        "70.0%",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                      ),
                      footer: Text(
                        "Stok",
                        style: TextStyle(fontSize: 14.0),
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: Colors.green[400],
                    ),
                  ],),),),
                ],),
              ),
              Row(children: <Widget>[
                Expanded(child: CardItem(tag: "employee", warna: Colors.blue, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Icon(MdiIcons.briefcaseAccount, color: Colors.blue[400], size: 40.0,),
                  Text("Karyawan", style: TextStyle(fontSize: 18.0, fontFamily: 'FlamanteRoma',),),
                  Text("10 Operator, 20 Kasir", style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
                ],),),),
                SizedBox(width: 10.0,),
                Expanded(child: CardItem(tag: "customer", warna: Colors.orange, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Icon(MdiIcons.accountMultiple, color: Colors.orange[400], size: 40.0,),
                  Text("Konsumen", style: TextStyle(fontSize: 18.0, fontFamily: 'FlamanteRoma',),),
                  Text("200 Terdaftar, 5 Baru", style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
                ],),),),
              ],),
              CardItem(tag: "promo", warna: Colors.blue, child: Row(children: <Widget>[
                CircularPercentIndicator(
                  radius: 120.0,
                  lineWidth: 13.0,
                  animation: true,
                  animationDuration: 1000,
                  percent: 0.7,
                  center: Text(
                    "70.0%",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                  footer: Text(
                    "Jumlah Klaim",
                    style: TextStyle(fontFamily: 'FlamanteRoma', fontSize: 16.0),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.blue[400],
                ),
                SizedBox(width: 20.0,),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Eaten", style: TextStyle(fontFamily: 'FlamanteRoma', fontSize: 16.0, color: Colors.grey),),
                        Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                          Icon(MdiIcons.ticketAccount, color: Colors.pink, size: 20.0,),
                          SizedBox(width: 8.0,),
                          Text("150", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),),
                          SizedBox(width: 5.0,),
                          Text("Voucher", style: TextStyle(color: Colors.grey),),
                        ],),
                      ],
                    ),
                    SizedBox(height: 12.0,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Burned", style: TextStyle(fontFamily: 'FlamanteRoma', fontSize: 16.0, color: Colors.grey),),
                        Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                          Icon(MdiIcons.tagMultiple, color: Colors.blueAccent, size: 20.0,),
                          SizedBox(width: 8.0,),
                          Text("120", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),),
                          SizedBox(width: 5.0,),
                          Text("Promo", style: TextStyle(color: Colors.grey),),
                        ],),
                      ],
                    ),
                  ],),
                ),
              ],),),
            ],),
          ],),
        ),);
      },
    );
  }
}

class CardItem extends StatefulWidget {
  CardItem({Key key, this.tag, this.status, this.child, this.warna}) : super(key: key);
  final String tag;
  final ItemStatus status;
  final Widget child;
  final Color warna;

  @override
  _CardItemState createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (widget.status) {
      case ItemStatus.GOOD: statusColor = Colors.green; break;
      case ItemStatus.WARNING: statusColor = Colors.orange; break;
      case ItemStatus.DANGER: statusColor = Colors.red; break;
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CARD_RADIUS)),
      clipBehavior: Clip.antiAlias,
      elevation: CARD_ELEVATION,
      margin: EdgeInsets.only(bottom: 10.0),
      color: Colors.white,
      child: Material(
        color: widget.status == null ? Colors.white : statusColor.withOpacity(0.1),
        child: InkWell(
          splashColor: widget.warna?.withOpacity(0.1),
          highlightColor: widget.warna?.withOpacity(0.1),
          onTap: () {
            print("KLIK CARD = ${widget.tag}");
          },
          child: Padding(
            padding: EdgeInsets.all(CARD_PADDING),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class CardSale extends StatefulWidget {
  @override
  _CardSaleState createState() => _CardSaleState();
}

class _CardSaleState extends State<CardSale> {
  List<String> _listJangkaWaktu = ['Bulan ini','Minggu ini','Hari ini'];
  String _jangkaWaktu = 'Bulan ini';

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      child: ScrollOnExpand(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CARD_RADIUS)),
          clipBehavior: Clip.antiAlias,
          elevation: CARD_ELEVATION,
          margin: EdgeInsets.only(bottom: 10.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(18.0),
                child: Row(children: <Widget>[
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Text("Total Penjualan", style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
                    Text("265K", style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),),
                  ],),
                  SizedBox(width: 20.0,),
                  Expanded(child: DropdownButton(
                    value: _jangkaWaktu,
                    hint: Text("Jangka waktu", style: TextStyle(fontSize: 14.0),),
                    style: TextStyle(fontSize: 14.0, color: Colors.black87),
                    onChanged: (String newValue) {
                      setState(() {
                        _jangkaWaktu = newValue;
                        //TODO recalculate sale
                      });
                    },
                    items: _listJangkaWaktu.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),),
                  SizedBox(width: 10.0,),
                  Material(
                    color: Colors.pink[400],
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(25.0),
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(MdiIcons.chartLineVariant, color: Colors.white, size: 36.0,),
                    ),
                  ),
                ],),
              ),
              Expandable(
                collapsed: Container(),
                expanded: Container(height: 200, color: Colors.pink,),
              ),
              Divider(height: 1,),
              Builder(
                builder: (context) {
                  ExpandableController controller = ExpandableController.of(context);
                  return SizedBox(
                    height: 50.0,
                    child: FlatButton(
                      child: Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                        Icon(controller.expanded ? MdiIcons.chevronUp : MdiIcons.chevronDown, color: Colors.blue,),
                        SizedBox(width: 4.0,),
                        Text(controller.expanded ? "TUTUP GRAFIK": "LIHAT GRAFIK",
                          style: Theme.of(context).textTheme.button.copyWith(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12.0),
                        ),
                      ],),
                      onPressed: () {
                        controller.toggle();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    _animationController = AnimationController(duration: Duration(seconds: 2), vsync: this)..repeat();
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Column(children: <Widget>[
            Icon(MdiIcons.chartLineVariant, color: Colors.grey, size: 100.0,),
            SizedBox(height: 10.0,),
            Text("Mempersiapkan ...", style: TextStyle(color: Colors.grey),),
          ],),
        );
      },
    );
  }
}