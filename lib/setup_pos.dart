import 'package:flutter/material.dart';
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:numberpicker/numberpicker.dart';
import 'models/company.dart';
import 'utils/utils.dart';
import 'utils/widgets.dart';

const PAGE_TITLE = "Setup POS";
const STRUK_LOGO_SIZE = 15;
const STRUK_FONT_FAMILY = 'FiraMono';
const STRUK_FONT_SIZE = 13.0;
const STRUK_FONT_SIZE_MIN = 11.0;
const STRUK_FONT_SIZE_MAX = 16.0;
const STRUK_FLEX_COLUMNS = [4, 2, 3, 3];
const STRUK_FONT_LIST = [
  'FiraMono',
  'NovaMono',
  'OxygenMono',
  'saxMono',
  'ShareTechMono',
];

enum PosisiLogo {
  ATAS,
  KIRI,
  KANAN,
}

Map<PosisiLogo, String> posisiLogoLabel = {
  PosisiLogo.ATAS: 'Atas',
  PosisiLogo.KIRI: 'Kiri',
  PosisiLogo.KANAN: 'Kanan',
};

class SetupPOS extends StatefulWidget {
  SetupPOS({Key key, this.company, this.outlet}) : super(key: key);
  final CompanyApi company;
  final OutletApi outlet;

  @override
  _SetupPOSState createState() => _SetupPOSState();
}

class _SetupPOSState extends State<SetupPOS> with SingleTickerProviderStateMixin {
  PosisiLogo _strukPosisiLogo = PosisiLogo.ATAS;
  String _fontFamilyBefore = STRUK_FONT_FAMILY;
  String _fontFamily = STRUK_FONT_FAMILY;
  double _fontSizeBefore = STRUK_FONT_SIZE;
  double _fontSize = STRUK_FONT_SIZE;
  bool _tampilLogoUsaha = true;
  bool _tampilNamaOutlet = false;
  bool _tampilCatatan = false;
  int _ukuranLogo = STRUK_LOGO_SIZE;
  String _catatan = "";

  TextEditingController _catatanController;
  FocusNode _catatanFocusNode;

  TabController _tabController;

  _getSetupPOS() {
    //TODO get data setting awal
    _strukPosisiLogo = posisiLogoLabel.keys.toList()[0];
    _fontFamily = STRUK_FONT_LIST[0];
    _fontSize = STRUK_FONT_SIZE;
    _tampilLogoUsaha = true;
    _tampilNamaOutlet = true;
    _tampilCatatan = false;
    _ukuranLogo = STRUK_LOGO_SIZE;
    _catatanController = TextEditingController();
    _catatanFocusNode = FocusNode();
    _catatan = "Barang yang sudah dibeli tidak dapat dikembalikan";
    _catatanController.text = _catatan;
    _catatanController.addListener(() {
      setState(() {
        _catatan = _catatanController.text;
      });
    });
    _fontFamilyBefore = _fontFamily;
    _fontSizeBefore = _fontSize;
  }

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getSetupPOS();
    });
  }

  @override
  void dispose() {
    _catatanController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    h = MyHelper(context);
    a = MyAppHelper(context);

    TextStyle textStyle = TextStyle(fontFamily: _fontFamily, fontSize: _fontSize, color: Colors.black87);

    Widget strukLogo = _tampilLogoUsaha ? Padding(
      padding: {
        PosisiLogo.ATAS: EdgeInsets.only(bottom: _fontSize),
        PosisiLogo.KIRI: EdgeInsets.only(right: _fontSize),
        PosisiLogo.KANAN: EdgeInsets.only(left: _fontSize),
      }[_strukPosisiLogo],
      child: Container(
        foregroundDecoration: BoxDecoration(
          color: Colors.grey,
          backgroundBlendMode: BlendMode.saturation,
        ),
        child: (widget.company?.logo ?? "").isEmpty
          ? Image.asset("images/dummy.png", width: _ukuranLogo * 10.0, fit: BoxFit.contain,)
          : Image.network(widget.company.logo, width: _ukuranLogo * 10.0, fit: BoxFit.contain,),
      ),
    ) : Container();

    Widget strukInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(widget.company.nama + (_tampilNamaOutlet ? " (${widget.outlet.nama})" : "")),
        Text(widget.outlet.alamat),
        Text("Telp: ${widget.outlet.telp ?? '-'}"),
      ],
    );

    return WillPopScope(
      onWillPop: () async {
        h.showConfirm(
          pesan: "Apakah Anda yakin tidak perlu menyimpan perubahan?",
          aksi: Navigator.of(context).pop,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: a.uiAppBarColor(),
          elevation: 0.0,
          title: Row(children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: NavLogo(),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Text(PAGE_TITLE, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0, color: Theme.of(context).primaryColor), textAlign: TextAlign.end,),
              ),
            ),
          ],),
          titleSpacing: 0.0,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BubbleTabIndicator(
              indicatorHeight: 30.0,
              indicatorColor: Theme.of(context).primaryColor,
              tabBarIndicatorSize: TabBarIndicatorSize.tab,
            ),
            controller: _tabController,
            isScrollable: true,
            unselectedLabelColor: Colors.grey[600],
            tabs: <Widget>[
              Tab(text: "Format Struk",),
              Tab(text: "POS",),
            ],
          ),
        ),
        body: Stack(children: <Widget>[
          Positioned.fill(child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Format Font:", style: TextStyle(fontWeight: FontWeight.bold),),
                  Offstage(
                    offstage: currentPerson.premium > 0 || (_fontFamily == _fontFamilyBefore && _fontSize == _fontSizeBefore),
                    child: ChipPremium(),
                  ),
                ],
              ),
              SizedBox(height: 12.0,),
              Row(children: <Widget>[
                Text("Font: "),
                SizedBox(width: 4.0,),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0),),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isDense: true,
                        underline: null,
                        value: _fontFamily,
                        hint: Text("Pilih Font"),
                        style: TextStyle(fontSize: 14.0, color: Theme.of(context).textTheme.body1.color),
                        onChanged: (String font) {
                          setState(() {
                            _fontFamily = font;
                          });
                        },
                        items: STRUK_FONT_LIST.map<DropdownMenuItem<String>>((String font) {
                          return DropdownMenuItem<String>(
                            value: font,
                            child: Text(font),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0,),
                Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0),),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<double>(
                        isDense: true,
                        underline: null,
                        value: _fontSize,
                        hint: Text("Ukuran"),
                        style: TextStyle(fontSize: 14.0, color: Theme.of(context).textTheme.body1.color),
                        onChanged: (double size) {
                          setState(() {
                            _fontSize = size;
                          });
                        },
                        items: List<DropdownMenuItem<double>>.generate((STRUK_FONT_SIZE_MAX - STRUK_FONT_SIZE_MIN).toInt(), (i) => DropdownMenuItem<double>(
                          value: STRUK_FONT_SIZE_MIN + i,
                          child: Text("${STRUK_FONT_SIZE_MIN + i}"),
                        )),
                      ),
                    ),
                  ),
                ),
                Expanded(child: Container(),),
              ],),
              /* currentPerson.premium > 0 || (_fontFamily == _fontFamilyBefore && _fontSize == _fontSizeBefore) ? SizedBox() : Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: CardPremium(),
              ), */
              SizedBox(height: 20.0,),
              Container(constraints: BoxConstraints(minWidth: 150, maxWidth: 350), width: double.infinity, child: Theme(
                data: Theme.of(context).copyWith(textTheme: TextTheme(body1: textStyle)),
                child: Material(
                  elevation: 8.0,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(_fontSize),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Flex(direction: _strukPosisiLogo == PosisiLogo.ATAS ? Axis.vertical : Axis.horizontal, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: _strukPosisiLogo == PosisiLogo.KANAN ? <Widget>[
                          Expanded(child: strukInfo,),
                          strukLogo,
                        ] : <Widget>[
                          strukLogo,
                          _strukPosisiLogo == PosisiLogo.KIRI ? Expanded(child: strukInfo,) : strukInfo,
                        ],),
                        SizedBox(height: _fontSize),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("No: 00027"),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text("DD-MM-YY (HH:MM:SS)"),
                            Text("KASIR-1A"),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded( flex: STRUK_FLEX_COLUMNS[0], child: Text("DESKRIPSI"), ),
                            Expanded( flex: STRUK_FLEX_COLUMNS[1], child: Text("QTY", textAlign: TextAlign.end,), ),
                            Expanded( flex: STRUK_FLEX_COLUMNS[2], child: Text("HARGA", textAlign: TextAlign.end,), ),
                            Expanded( flex: STRUK_FLEX_COLUMNS[3], child: Text("TOTAL", textAlign: TextAlign.end,), ),
                          ],
                        ),
                        Text("=" * 200, maxLines: 1, overflow: TextOverflow.clip,),
                        Row(
                          children: <Widget>[
                            Expanded( flex: STRUK_FLEX_COLUMNS[0], child: Text("MENTEGA"), ),
                            Expanded( flex: STRUK_FLEX_COLUMNS[1], child: Text("5", textAlign: TextAlign.end,), ),
                            Expanded( flex: STRUK_FLEX_COLUMNS[2], child: Text("12.990", textAlign: TextAlign.end,), ),
                            Expanded( flex: STRUK_FLEX_COLUMNS[3], child: Text("64.950", textAlign: TextAlign.end,), ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded( flex: STRUK_FLEX_COLUMNS[0], child: Text("KEJU"), ),
                            Expanded( flex: STRUK_FLEX_COLUMNS[1], child: Text("20", textAlign: TextAlign.end,), ),
                            Expanded( flex: STRUK_FLEX_COLUMNS[2], child: Text("15.000", textAlign: TextAlign.end,), ),
                            Expanded( flex: STRUK_FLEX_COLUMNS[3], child: Text("300.000", textAlign: TextAlign.end,), ),
                          ],
                        ),
                        Text("-" * 200, maxLines: 1, overflow: TextOverflow.clip,),
                        Row(
                          children: <Widget>[
                            Expanded( flex: 8, child: Text("Sub Total (Termasuk PPN)"), ),
                            Expanded( flex: 1, child: Text(":"), ),
                            Expanded( flex: 3, child: Text("364.950", textAlign: TextAlign.end,), ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded( flex: 4, child: Container(), ),
                            Expanded( flex: 4, child: Text("Pembulatan"), ),
                            Expanded( flex: 1, child: Text(":"), ),
                            Expanded( flex: 3, child: Text("50", textAlign: TextAlign.end,), ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded( flex: 4, child: Container(), ),
                            Expanded( flex: 8, child: Text("-" * 200, maxLines: 1, overflow: TextOverflow.clip,), ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded( flex: 4, child: Container(), ),
                            Expanded( flex: 4, child: Text("Total"), ),
                            Expanded( flex: 1, child: Text(":"), ),
                            Expanded( flex: 3, child: Text("365.000", textAlign: TextAlign.end,), ),
                          ],
                        ),
                        SizedBox(height: _fontSize),
                        Row(
                          children: <Widget>[
                            Expanded( flex: 8, child: Text("TUNAI"), ),
                            Expanded( flex: 1, child: Text(":"), ),
                            Expanded( flex: 3, child: Text("370.000", textAlign: TextAlign.end,), ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded( flex: 8, child: Text("KEMBALI"), ),
                            Expanded( flex: 1, child: Text(":"), ),
                            Expanded( flex: 3, child: Text("5.000", textAlign: TextAlign.end,), ),
                          ],
                        ),
                        SizedBox(height: _fontSize),
                        Row(
                          children: <Widget>[
                            Expanded( flex: 8, child: Text("Item"), ),
                            Expanded( flex: 1, child: Text(":"), ),
                            Expanded( flex: 3, child: Text("2", textAlign: TextAlign.end,), ),
                          ],
                        ),
                        SizedBox(height: _fontSize),
                        Center(child: Text("** TERIMA KASIH **", textAlign: TextAlign.center,),),
                        Center(child: Text("LAYANAN KONSUMEN: ${widget.company.cs}", textAlign: TextAlign.center,),),
                        widget.company.email == null ? SizedBox() : Center(child: Text("Email: ${widget.company.email}", textAlign: TextAlign.center,),),
                        widget.company.website == null ? SizedBox() : Center(child: Text("${widget.company.website}", textAlign: TextAlign.center,),),
                        _tampilCatatan && (_catatan ?? "").isNotEmpty ? Center(child: Text(_catatan, textAlign: TextAlign.center,),) : SizedBox(),
                      ],
                    ),
                  ),
                ),
              ),),
              SizedBox(height: 20.0,),
              Text("Kustomisasi:", style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(height: 20.0,),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Row(children: <Widget>[
                  Checkbox(value: _tampilLogoUsaha, onChanged: (val) {
                    setState(() {
                      _tampilLogoUsaha = val;
                    });
                  },),
                  Text("Logo Usaha"),
                ],),
                _tampilLogoUsaha ? CustomRadioButton(
                  elevation: 1.0,
                  customShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0), side: BorderSide(style: BorderStyle.none)),
                  buttonColor: Theme.of(context).canvasColor,
                  buttonLables: posisiLogoLabel.values.toList(),
                  buttonValues:posisiLogoLabel.keys.toList(),
                  //TODO FIXME defaultSelected: posisiLogoLabel[_strukPosisiLogo],
                  horizontal: false,
                  width: 120.0,
                  selectedColor: Theme.of(context).accentColor,
                  enableShape: true,
                  radioButtonValue: (value) {
                    setState(() {
                      _strukPosisiLogo = value;
                    });
                  },
                ) : SizedBox(),
                _tampilLogoUsaha ? Row(children: <Widget>[
                  Text("Ukuran: "),
                  SizedBox(width: 4.0,),
                  Transform.scale(scale: 0.8, child: NumberPicker.integer(
                    initialValue: _ukuranLogo,
                    minValue: 5,
                    maxValue: 20,
                    onChanged: (val) {
                      setState(() => _ukuranLogo = val);
                    }
                  ),),
                ],) : SizedBox(),
                Row(children: <Widget>[
                  Checkbox(value: _tampilNamaOutlet, onChanged: (val) {
                    setState(() {
                      _tampilNamaOutlet = val;
                    });
                  },),
                  Text("Nama Outlet"),
                ],),
                Row(children: <Widget>[
                  Checkbox(value: _tampilCatatan, onChanged: (val) {
                    setState(() {
                      _tampilCatatan = val;
                    });
                  },),
                  Text("Catatan"),
                ],),
                _tampilCatatan
                  ? SizedBox(width: double.infinity, child: CardInput(showLabel: false, icon: MdiIcons.pencil, initialValue: _catatan, placeholder: "Catatan khusus", controller: _catatanController, focusNode: _catatanFocusNode),)
                  : SizedBox(),
              ],),
              SizedBox(height: 30.0,),
              Row(
                children: <Widget>[
                  Expanded(child: Container(),),
                  SizedBox(height: 46.0, child: UiButton(color: Colors.grey, teks: "Batal", ukuranTeks: 15.0, posisiTeks: MainAxisAlignment.center, icon: MdiIcons.chevronLeft, aksi: () {
                    Navigator.of(context).pop();
                  },),),
                  SizedBox(width: 8.0,),
                  SizedBox(height: 46.0, child: UiButton(color: Theme.of(context).primaryColor, teks: "Simpan", ukuranTeks: 15.0, posisiTeks: MainAxisAlignment.center, icon: MdiIcons.check, aksi: () {
                    //TODO simpan settings
                    print("simpan");
                  },),),
                ],
              ),
            ],),
          ),),
          TopGradient(),
        ],),
      ),
    );
  }
}