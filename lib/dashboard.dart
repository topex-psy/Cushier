import 'dart:math';

import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bezier_chart/bezier_chart.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'models/company.dart';
import 'utils/constants.dart';
import 'utils/provider.dart';
import 'utils/utils.dart';
import 'utils/widgets.dart';
import 'setup_pos.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(
        builder: (context) => DashboardAdmin(),
      ),
    );
  }
}

class DashboardAdmin extends StatefulWidget {
  @override
  _DashboardAdminState createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> with TickerProviderStateMixin {
  GlobalKey _showCaseKey1 = GlobalKey();
  GlobalKey _showCaseKey2 = GlobalKey();
  List<CompanyApi> _listCompany = [];
  CompanyApi _company;

  bool _isLoading = true;
  AnimationController _animationController;
  Animation _animation;

  _getDataUsaha() {
    getListCompany(uid: currentPerson.uid).then((responseJson) {
      print("DATA LIST COMPANY RESPONSE:" + responseJson.toString());
      if (responseJson == null) {
        print("DATA LIST COMPANY EXCEPTION NULL!");
        h.failAlertInternet();
      } else {
        List<CompanyApi> listCompany = [];
        CompanyApi myCompany;

        for (Map res in responseJson["result"]) {
          CompanyApi company = CompanyApi.fromJson(res);
          listCompany.add(company);
          if (company.id == currentPerson.idUsaha) {
            print("ID USAHA SAYA = ${currentPerson.idUsaha}");
            /* if ((myCompany.logo ?? "").isEmpty) {
              Future.delayed(Duration(milliseconds: 1500), () {
                ShowCaseWidget.of(context).startShowCase([_showCaseKey1]);
              });
            } */
            myCompany = company;
          }
        }

        setState(() {
          _listCompany = listCompany;
          _company = myCompany;
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
        if ((_company?.logo ?? "").isEmpty) {
          Future.delayed(Duration(milliseconds: 1500), () {
            ShowCaseWidget.of(context).startShowCase([_showCaseKey1]);
          });
        }
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
    final appState = Provider.of<AppState>(context);

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
                      Text("Halo, ${currentPerson.namaLengkap}!", textAlign: TextAlign.start, style: TextStyle(fontSize: 16.0),),
                      _company == null ? SizedBox() : Transform.translate(offset: Offset(-10.0, 0.0), child: Card(
                        margin: EdgeInsets.only(top: 7.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0),),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<CompanyApi>(
                              isDense: true,
                              underline: null,
                              value: _company,
                              hint: Text("Pilih Usaha"),
                              style: TextStyle(fontSize: 14.0, color: Theme.of(context).textTheme.body1.color),
                              onChanged: (CompanyApi company) {
                                setState(() {
                                  _isLoading = true;
                                  _company = company;
                                });
                                //TODO muat data berdasarkan company
                                Future.delayed(Duration(milliseconds: 2000), () {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                });
                              },
                              items: _listCompany.map<DropdownMenuItem<CompanyApi>>((CompanyApi company) {
                                return DropdownMenuItem<CompanyApi>(
                                  value: company,
                                  child: Text(company.nama),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
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
                        (_company?.logo ?? "").isEmpty
                          ? Image.asset("images/dummy.png", width: 200.0, fit: BoxFit.contain,)
                          : Image.network(_company.logo, width: 200.0, fit: BoxFit.contain,),
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
              CardSale(company: _company,),
              Row(children: <Widget>[
                Expanded(child: CardItem(tag: "outlet", key: _showCaseKey2, warna: Colors.purple, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Icon(MdiIcons.store, color: Colors.purple[400], size: 40.0,),
                  Text("Outlet", style: TextStyle(fontSize: 18.0, fontFamily: 'FlamanteRoma',),),
                  AutoSizeText("${appState.jumlah[DataJumlah.OUTLET]} Lokasi, ${appState.jumlah[DataJumlah.OUTLET_POS]} POS", maxLines: 2, style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
                ],),),),
                SizedBox(width: 10.0,),
                Expanded(flex: 2, child: CardItem(tag: "product", warna: Colors.brown, status: ItemStatus.WARNING, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                      Icon(MdiIcons.widgets, color: Colors.brown[400], size: 40.0,),
                      Text("Inventori", style: TextStyle(fontSize: 18.0, fontFamily: 'FlamanteRoma',),),
                      AutoSizeText("100 Unit, 8 Kategori", maxLines: 2, style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
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
              Row(children: <Widget>[
                Expanded(child: CardItem(tag: "employee", warna: Colors.blue, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Icon(MdiIcons.briefcaseAccount, color: Colors.blue[400], size: 40.0,),
                  Text("Karyawan", style: TextStyle(fontSize: 18.0, fontFamily: 'FlamanteRoma',),),
                  AutoSizeText("10 Operator, 20 Kasir", maxLines: 2, style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
                ],),),),
                SizedBox(width: 10.0,),
                Expanded(child: CardItem(tag: "customer", warna: Colors.orange, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  Icon(MdiIcons.accountMultiple, color: Colors.orange[400], size: 40.0,),
                  Text("Konsumen", style: TextStyle(fontSize: 18.0, fontFamily: 'FlamanteRoma',),),
                  AutoSizeText("200 Terdaftar, 5 Baru", maxLines: 2, style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
                ],),),),
              ],),
              CardItem(tag: "promo", warna: Colors.blue, child: PromoStat(),),
            ],),
          ],),
        ),);
      },
    );
  }
}

class PromoStatItem {
  PromoStatItem({this.nama, this.jumlah, this.jumlahKlaim, this.persenKlaim, this.icon, this.warna});
  final String nama;
  final int jumlah;
  final int jumlahKlaim;
  final double persenKlaim;
  final IconData icon;
  final Color warna;
}

class PromoStat extends StatefulWidget {
  @override
  _PromoStatState createState() => _PromoStatState();
}

class _PromoStatState extends State<PromoStat> {
  final _chartKey = GlobalKey<AnimatedCircularChartState>();
  List<PromoStatItem> _listPromoStats = [];
  bool _isLoaded = false;

  _getListPromoStats() {
    //TODO load _listPromoStats
    setState(() {
      _isLoaded = true;
      _listPromoStats = [
        PromoStatItem(
          warna: Colors.pink,
          icon: MdiIcons.ticketAccount,
          nama: 'Voucher',
          jumlah: 150,
          jumlahKlaim: 150,
          persenKlaim: 75.0,
        ),
        PromoStatItem(
          warna: Colors.blueAccent,
          icon: MdiIcons.tagMultiple,
          nama: 'Promo',
          jumlah: 120,
          jumlahKlaim: 120,
          persenKlaim: 60.0,
        ),
        PromoStatItem(
          warna: Colors.greenAccent[700],
          icon: MdiIcons.cards,
          nama: 'Undian',
          jumlah: 20,
          jumlahKlaim: 20,
          persenKlaim: 95.0,
        ),
        PromoStatItem(
          warna: Colors.purpleAccent,
          icon: MdiIcons.partyPopper,
          nama: 'Milestone',
          jumlah: 20,
          jumlahKlaim: 20,
          persenKlaim: 90.0,
        ),
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getListPromoStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    double _promoKlaimPersen = 0.0;
    return _isLoaded ? Container(
      child: _listPromoStats.isEmpty
      ? Column(
        children: <Widget>[
          Text("Buat kode voucher dan promo menarik untuk usaha Anda!"),
          SizedBox(height: 10.0,),
          UiButton(color: Colors.greenAccent[700], teks: "Kelola Promo", icon: MdiIcons.tagMultiple, aksi: () {},),
        ],
      )
      : Row(children: <Widget>[
        Column(
          children: <Widget>[
            Transform.scale(scale: 1.2, child: AnimatedCircularChart(
              key: _chartKey,
              size: Size(140.0, 140.0),
              initialChartData: <CircularStackEntry>[
                CircularStackEntry(
                  _listPromoStats.map((prm) {
                    double persen = prm.persenKlaim / _listPromoStats.length;
                    _promoKlaimPersen += persen;
                    return CircularSegmentEntry(
                      persen,
                      prm.warna,
                      rankKey: prm.nama,
                    );
                  }).toList()..add(
                    CircularSegmentEntry(
                      100.0 - _promoKlaimPersen,
                      Colors.grey[350],
                      rankKey: 'unclaimed',
                    )
                  ),
                  rankKey: 'progress',
                ),
              ],
              chartType: CircularChartType.Radial,
              percentageValues: true,
              holeLabel: '$_promoKlaimPersen%',
              labelStyle: TextStyle(
                color: Theme.of(context).textTheme.body1.color,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
              holeRadius: 32.0,
              edgeStyle: SegmentEdgeStyle.round,
            ),
            ),
            Text(
              "Jumlah Klaim",
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
        SizedBox(width: 10.0,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _listPromoStats.map((prm) {
              return Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                      Icon(prm.icon, color: prm.warna, size: 20.0,),
                      SizedBox(width: 8.0,),
                      Text("${prm.jumlah}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),),
                      SizedBox(width: 5.0,),
                      Text(prm.nama, style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
                    ],),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],),
    ) : Container();
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
    Color statusColor = {
      ItemStatus.GOOD: Colors.green,
      ItemStatus.WARNING: Colors.orange,
      ItemStatus.DANGER: Colors.red,
    }[widget.status];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CARD_RADIUS)),
      clipBehavior: Clip.antiAlias,
      elevation: CARD_ELEVATION,
      margin: EdgeInsets.only(bottom: 10.0),
      child: Material(
        color: widget.status == null ? Colors.transparent : statusColor.withOpacity(0.1),
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

enum SaleDuration {
  HARIAN,
  MINGGUAN,
  BULANAN,
}

class CardSale extends StatefulWidget {
  CardSale({Key key, @required this.company}) : super(key: key);
  final CompanyApi company;

  @override
  _CardSaleState createState() => _CardSaleState();
}

class _CardSaleState extends State<CardSale> {
  final Map<SaleDuration, String> _listJangkaWaktu = {
    SaleDuration.HARIAN: 'Hari ini',
    SaleDuration.MINGGUAN: 'Minggu ini',
    SaleDuration.BULANAN: 'Bulan ini',
  };

  List<OutletApi> _listOutlet = [];
  OutletApi _outlet;
  SaleDuration _jangkaWaktu = SaleDuration.HARIAN;
  bool _isPOSReady = false;
  double _nominal;

  Widget grafikPenjualan(BuildContext context) {
    final fromDate = DateTime(2019, 05, 22);
    final toDate = DateTime.now();

    final date1 = DateTime.now().subtract(Duration(days: 2));
    final date2 = DateTime.now().subtract(Duration(days: 3));

    return Center(
      child: Container(
        color: Colors.pink,
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width,
        child: BezierChart(
          fromDate: fromDate,
          bezierChartScale: BezierChartScale.WEEKLY,
          toDate: toDate,
          selectedDate: toDate,
          series: [
            BezierLine(
              label: "Transaksi",
              onMissingValue: (dateTime) {
                if (dateTime.day.isEven) {
                  return 10.0;
                }
                return 5.0;
              },
              data: [
                DataPoint<DateTime>(value: 10, xAxis: date1),
                DataPoint<DateTime>(value: 50, xAxis: date2),
              ],
            ),
          ],
          config: BezierChartConfig(
            verticalIndicatorStrokeWidth: 3.0,
            verticalIndicatorColor: Colors.black26,
            showVerticalIndicator: true,
            verticalIndicatorFixedPosition: false,
            backgroundColor: Colors.pink,
            footerHeight: 50.0,
          ),
        ),
      ),
    );
  }

  _getListOutlet() {
    final appState = Provider.of<AppState>(context);
    getListOutlet(idCompany: widget.company.id).then((responseJson) {
      print("DATA OUTLET RESPONSE:" + responseJson.toString());
      if (responseJson == null) {
        h.failAlertInternet();
      } else {
        var result = responseJson["result"];
        List<OutletApi> listOutlet = [];
        for (Map res in result) { listOutlet.add(OutletApi.fromJson(res)); }
        appState.updateJumlah(DataJumlah.OUTLET, listOutlet.length);
        setState(() {
          _listOutlet = listOutlet;
          _outlet = listOutlet[0];
          _getSaleData();
        });
        print("DATA OUTLET BERHASIL DIMUAT!");
      }
    }).catchError((e) {
      print("DATA OUTLET ERROOOOOOOOOOOOR: $e");
      h.failAlertInternet();
    }).whenComplete(() {
      print("DATA OUTLET DONEEEEEEEEEEEEE!");
    });
  }

  _getSaleData() {
    //TODO muat data berdasarkan widget.company, _outlet & _jangkaWaktu
    setState(() {
      _nominal = null;
    });
    Future.delayed(Duration(milliseconds: 2500), () {
      setState(() {
        _nominal = 265000.0;
        _isPOSReady = true; //TODO check jumlah outlet, pos & produk
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getListOutlet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.company == null ? Container() : ExpandableNotifier(
      child: ScrollOnExpand(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CARD_RADIUS)),
          clipBehavior: Clip.antiAlias,
          elevation: CARD_ELEVATION,
          margin: EdgeInsets.only(bottom: 10.0),
          child: _isPOSReady ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(18.0),
                child: Row(children: <Widget>[
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Text("Total Penjualan", style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
                    _nominal == null ? Padding(padding: EdgeInsets.only(top: 6.0), child: Transform.scale(scale: 0.7, child: CircularProgressIndicator(),),) : Text(h.singkatNominal(_nominal), style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),),
                  ],),
                  SizedBox(width: 15.0,),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0),),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<OutletApi>(
                            isDense: true,
                            underline: null,
                            value: _outlet,
                            hint: Text("Pilih Outlet"),
                            style: TextStyle(fontSize: 14.0, color: Theme.of(context).textTheme.body1.color),
                            onChanged: (OutletApi outlet) {
                              setState(() {
                                _outlet = outlet;
                                _getSaleData();
                              });
                            },
                            items: _listOutlet.map<DropdownMenuItem<OutletApi>>((OutletApi outlet) {
                              return DropdownMenuItem<OutletApi>(
                                value: outlet,
                                child: Text(outlet.nama, style: TextStyle(fontWeight: FontWeight.bold),),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                      Icon(MdiIcons.calendar, size: 14.0, color: Colors.grey,),
                      SizedBox(width: 6.0,),
                      DropdownButton(
                        value: _jangkaWaktu,
                        hint: Text("Jangka waktu", style: TextStyle(fontSize: 14.0),),
                        style: TextStyle(fontSize: 14.0, color: Theme.of(context).textTheme.body1.color),
                        onChanged: (SaleDuration newValue) {
                          setState(() {
                            _jangkaWaktu = newValue;
                            _getSaleData();
                          });
                        },
                        items: _listJangkaWaktu.keys.map<DropdownMenuItem<SaleDuration>>((SaleDuration value) {
                          return DropdownMenuItem<SaleDuration>(
                            value: value,
                            child: Text(_listJangkaWaktu[value]),
                          );
                        }).toList(),
                      ),
                    ],),
                  ],),),
                  /* SizedBox(width: 10.0,),
                  Material(
                    color: Colors.pink[400],
                    elevation: 0.0,
                    borderRadius: BorderRadius.circular(25.0),
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(MdiIcons.chartTimelineVariant, color: Colors.white, size: 36.0,),
                    ),
                  ), */
                ],),
              ),
              Expandable(
                collapsed: Container(),
                expanded: Container(height: min(300.0, MediaQuery.of(context).size.height / 2), color: Colors.pink, child: grafikPenjualan(context),),
              ),
              Divider(height: 1,),
              Builder(
                builder: (context) {
                  ExpandableController controller = ExpandableController.of(context);
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: SizedBox(
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
                        ),
                      ),
                      SizedBox(
                        height: 50.0,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(),
                          color: Colors.pink,
                          child: Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                            Icon(MdiIcons.cashRegister, color: Colors.white,),
                            SizedBox(width: 4.0,),
                            Text("MULAI SESI",
                              style: Theme.of(context).textTheme.button.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.0),
                            ),
                          ],),
                          onPressed: () {
                            h.showAlert(
                              contentPadding: EdgeInsets.zero,
                              showButton: false,
                              listView: ListOutlet(company: widget.company, onSelect: (OutletPOSApi pos) {
                                print("OUTLET POS SELECTION = ${pos.nama}");
                                Future.delayed(Duration(milliseconds: 500), () => a.startPOSSession(pos));
                              },),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(),
                          padding: EdgeInsets.zero,
                          color: Colors.pink,
                          child: Icon(MdiIcons.settings, color: Colors.white,),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => SetupPOS(company: widget.company, outlet: _outlet)));
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ) : Padding(padding: EdgeInsets.all(8.0), child: Stack(children: <Widget>[
            Positioned.fill(child: Divider(height: 8.0, color: Colors.blue[200],),),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
              SizedBox(
                width: 60.0,
                height: 60.0,
                child: Material(color: Colors.blue[200], shape: CircleBorder(),),
              ),
              SizedBox(
                width: 60.0,
                height: 60.0,
                child: Material(color: Colors.blue[200], shape: CircleBorder(),),
              ),
              SizedBox(
                width: 60.0,
                height: 60.0,
                child: Material(color: Colors.blue[200], shape: CircleBorder(),),
              ),
            ],),
          ],),),
        ),
      ),
    );
  }
}

class ListOutlet extends StatefulWidget {
  ListOutlet({Key key, @required this.company, @required this.onSelect}) : super(key: key);
  final void Function(OutletPOSApi) onSelect;
  final CompanyApi company;

  @override
  _ListOutletState createState() => _ListOutletState();
}

class _ListOutletState extends State<ListOutlet> {
  Widget _child;
  List<OutletApi> _listOutlet = [];
  List<OutletApi> _listOutletFiltered = [];
  List<OutletPOSApi> _listOutletPOS = [];
  List<OutletPOSApi> _listOutletPOSFiltered = [];
  OutletApi _outlet;
  String _keyword = '';
  int _tahap = 1;

  _onSearchTextChanged(keyword) async {
    Function() filter = {
      1 : _getListOutlet,
      2 : _getListOutletPOS,
    }[_tahap];
    _keyword = keyword;
    filter();
  }

  _getListOutlet() {
    // final appState = Provider.of<AppState>(context);
    setState(() { _child = null; });
    getListOutlet(idCompany: widget.company.id).then((responseJson) {
      print("DATA OUTLET RESPONSE:" + responseJson.toString());
      if (responseJson == null) {
        h.failAlertInternet();
      } else {
        var result = responseJson["result"];
        List<OutletApi> listOutlet = [];
        List<OutletApi> listOutletFound = [];
        for (Map res in result) { listOutlet.add(OutletApi.fromJson(res)); }
          listOutlet.forEach((OutletApi outlet) {
          if (h.filterData([outlet.nama, outlet.alamat], _keyword)) {
            listOutletFound.add(outlet);
          }
        });
        // appState.updateJumlah(DataJumlah.OUTLET, listOutlet.length);
        setState(() {
          _listOutlet = listOutlet;
          _listOutletFiltered = listOutletFound;
          _child = Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            CardInput(initialValue: _keyword, icon: MdiIcons.magnify, placeholder: "Cari outlet", showLabel: false, borderColor: Colors.white, height: 60.0, onChanged: _onSearchTextChanged,),
            Flexible(child: ListView.separated(
              itemCount: _listOutletFiltered.length + 1,
              separatorBuilder: (context, index) => Divider(height: 1.0, color: Colors.grey[400],),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (index >= _listOutletFiltered.length) {
                  return InkWell(
                    onTap: () {
                      //TODO tambah outlet baru untuk widget.company
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      child: Row(children: <Widget>[
                        Icon(MdiIcons.plus, color: Colors.blueAccent,),
                        SizedBox(width: 10.0),
                        Expanded(child: Text("Tambah baru", style: TextStyle(fontSize: 15.0, height: 1.0, color: Colors.blueAccent,),),),
                      ],),
                    ),
                  );
                }
                OutletApi outlet = _listOutlet[index];
                return InkWell(
                  onTap: () {
                    // h.closeAlert();
                    // widget.onSelect(outlet);
                    setState(() {
                      _tahap = 2;
                      _outlet = outlet;
                      _onSearchTextChanged('');
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: Row(children: <Widget>[
                      Expanded(child: Text(outlet.nama, style: TextStyle(fontSize: 15.0, height: 1.0, fontWeight: FontWeight.w600),),),
                      SizedBox(width: 10.0),
                      Icon(MdiIcons.chevronRight, color: Colors.grey,),
                    ],),
                  ),
                );
              },
            ),),
            SizedBox(height: 20.0,),
          ],);
        });
        print("DATA OUTLET BERHASIL DIMUAT!");
      }
    }).catchError((e) {
      print("DATA OUTLET ERROOOOOOOOOOOOR: $e");
      h.failAlertInternet();
    }).whenComplete(() {
      print("DATA OUTLET DONEEEEEEEEEEEEE!");
    });
  }

  _getListOutletPOS() {
    setState(() { _child = null; });
    getListOutletPOS(idOutlet: _outlet.id).then((responseJson) {
      print("DATA POS RESPONSE:" + responseJson.toString());
      if (responseJson == null) {
        h.failAlertInternet();
      } else {
        var result = responseJson["result"];
        List<OutletPOSApi> listOutletPOS = [];
        List<OutletPOSApi> listOutletPOSFound = [];
        for (Map res in result) { listOutletPOS.add(OutletPOSApi.fromJson(res)); }
          listOutletPOS.forEach((OutletPOSApi pos) {
          if (h.filterData([pos.nama], _keyword)) {
            listOutletPOSFound.add(pos);
          }
        });
        setState(() {
          _listOutletPOS = listOutletPOS;
          _listOutletPOSFiltered = listOutletPOSFound;
          _child = Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            CardInput(initialValue: _keyword, icon: MdiIcons.magnify, placeholder: "Cari POS", showLabel: false, borderColor: Colors.white, height: 60.0, onChanged: _onSearchTextChanged,),
            Flexible(child: ListView.separated(
              itemCount: _listOutletPOSFiltered.length + 1,
              separatorBuilder: (context, index) => Divider(height: 1.0, color: Colors.grey[400],),
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (index >= _listOutletPOSFiltered.length) {
                  return InkWell(
                    onTap: () {
                      //TODO tambah POS baru untuk _outlet
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      child: Row(children: <Widget>[
                        Icon(MdiIcons.plus, color: Colors.blueAccent,),
                        SizedBox(width: 10.0),
                        Expanded(child: Text("Tambah baru", style: TextStyle(fontSize: 15.0, height: 1.0, color: Colors.blueAccent,),),),
                      ],),
                    ),
                  );
                }
                OutletPOSApi pos = _listOutletPOS[index];
                return InkWell(
                  onTap: () {
                    h.closeAlert();
                    widget.onSelect(pos);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: Row(children: <Widget>[
                      Expanded(child: Text(pos.nama, style: TextStyle(fontSize: 15.0, height: 1.0, fontWeight: FontWeight.w600),),),
                      SizedBox(width: 10.0),
                      Icon(MdiIcons.chevronRight, color: Colors.grey,),
                    ],),
                  ),
                );
              },
            ),),
            SizedBox(height: 20.0,),
          ],);
        });
        print("DATA POS BERHASIL DIMUAT!");
      }
    }).catchError((e) {
      print("DATA POS ERROOOOOOOOOOOOR: $e");
      h.failAlertInternet();
    }).whenComplete(() {
      print("DATA POS DONEEEEEEEEEEEEE!");
    });
  }
  
  @override
  void initState() {
    _getListOutlet();
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

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    _animationController = AnimationController(duration: Duration(seconds: 2), vsync: this)..repeat(reverse: true);
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
            Icon(MdiIcons.chartBubble, color: Colors.grey, size: 100.0,),
            SizedBox(height: 10.0,),
            Text("Mempersiapkan ...", style: TextStyle(color: Colors.grey),),
          ],),
        );
      },
    );
  }
}