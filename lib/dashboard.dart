import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'models/person.dart';

enum ItemStatus {
  GOOD,
  WARNING,
  DANGER,
}

class Dashboard extends StatefulWidget {
  Dashboard({Key key, this.me}) : super(key: key);
  final PersonApi me;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: Column(children: <Widget>[
        SizedBox(height: 15.0,),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text("Halo, ${widget.me.namaLengkap}!", textAlign: TextAlign.start, style: TextStyle(fontSize: 16.0),),
        ),
        SizedBox(height: 30.0,),
        Column(children: <Widget>[
          CardItem(tag: "sale", status: ItemStatus.GOOD, child:  Row(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Text("Total Penjualan", style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
              Text("265K", style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),),
            ],),
            SizedBox(width: 20.0,),
            Expanded(child: Container(
              child: DropdownButton(hint: Text("Hari Ini"), style: TextStyle(fontSize: 14.0),),
            ),),
            SizedBox(width: 10.0,),
            Material(
              color: Colors.pink[400],
              elevation: 0.0,
              borderRadius: BorderRadius.circular(25.0),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(MdiIcons.chartLineVariant, color: Colors.white, size: 36.0,),
              ),),
          ],),),
          Row(children: <Widget>[
            Expanded(child: CardItem(tag: "employee", child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Icon(MdiIcons.briefcaseAccount, color: Colors.blue[400], size: 40.0,),
              Text("Karyawan", style: TextStyle(fontSize: 18.0, fontFamily: 'FlamanteRoma',),),
              Text("10 Operator, 20 Kasir", style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
            ],),),),
            SizedBox(width: 15.0,),
            Expanded(child: CardItem(tag: "customer", child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Icon(MdiIcons.accountMultiple, color: Colors.orange[400], size: 40.0,),
              Text("Konsumen", style: TextStyle(fontSize: 18.0, fontFamily: 'FlamanteRoma',),),
              Text("200 Terdaftar, 5 Baru", style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
            ],),),),
          ],),
          Row(children: <Widget>[
            Expanded(child: CardItem(tag: "outlet", child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Icon(MdiIcons.store, color: Colors.purple[400], size: 40.0,),
              Text("Outlet", style: TextStyle(fontSize: 18.0, fontFamily: 'FlamanteRoma',),),
              Text("175", style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
            ],),),),
            SizedBox(width: 15.0,),
            Expanded(flex: 2, child: CardItem(tag: "product", status: ItemStatus.DANGER, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Icon(MdiIcons.widgets, color: Colors.brown[400], size: 40.0,),
                Text("Produk", style: TextStyle(fontSize: 18.0, fontFamily: 'FlamanteRoma',),),
                Text("20K", style: TextStyle(fontSize: 14.0, color: Colors.blueGrey),),
              ],),
              SizedBox(width: 10.0,),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                  Material(
                    borderRadius: BorderRadius.circular(30.0),
                    elevation: 2.0,
                    color: Colors.redAccent[400],
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(MdiIcons.alertBox, size: 15.0, color: Colors.white,),
                    ),
                  ),
                  SizedBox(height: 8.0,),
                  Text("5K Produk kosong", style: TextStyle(fontSize: 13.0, color: Colors.blueGrey, height: 1.1), textAlign: TextAlign.end,)
                ],),
              )
            ],),),),
          ],),
          Row(children: <Widget>[
            CardItem(tag: "stock", status: ItemStatus.WARNING, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              CircularPercentIndicator(
                radius: 120.0,
                lineWidth: 13.0,
                animation: true,
                percent: 0.7,
                center: Text(
                  "70.0%",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                ),
                footer: Text(
                  "Persediaan produk",
                  style: TextStyle(fontFamily: 'FlamanteRoma', fontSize: 17.0),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.green[400],
              ),
            ],),),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: <Widget>[
                Icon(MdiIcons.tagMultiple, size: 40.0, color: Colors.blueAccent[400],),
                SizedBox(height: 8.0,),
                //Text("12 Promo berlangsung", style: TextStyle(fontSize: 15.0, color: Colors.blueGrey, height: 1.1), textAlign: TextAlign.end,),
                RichText(
                  textAlign: TextAlign.end,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.blueGrey,
                      height: 1.1,
                    ),
                    children: <TextSpan>[
                      TextSpan(text: '12', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                      TextSpan(text: ' Promo', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' berlangsung'),
                    ],
                  ),
                ),
                SizedBox(height: 8.0,),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                  Text("Cek promo", style: TextStyle(fontSize: 15.0, fontFamily: 'FlamanteRoma', color: Colors.blueAccent), textAlign: TextAlign.end,),
                  SizedBox(height: 4.0,),
                  Icon(MdiIcons.chevronRight, color: Colors.blueAccent,),
                ],),
              ],),
            ),
          ],),
        ],),
      ],),
    );
  }
}

class CardItem extends StatefulWidget {
  CardItem({Key key, this.tag, this.status, this.child}) : super(key: key);
  final String tag;
  final ItemStatus status;
  final Widget child;

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
      elevation: 12.0,
      margin: EdgeInsets.only(bottom: 15.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: Colors.white,
      child: Material(
        color: widget.status == null ? Colors.white : statusColor.withOpacity(0.1),
        child: InkWell(
          onTap: () {
            print("KLIK CARD = ${widget.tag}");
          },
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}