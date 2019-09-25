import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:theme_provider/theme_provider.dart';
import 'constants.dart';

class LoadingCircle extends StatelessWidget {
  LoadingCircle({this.teks, this.absorb = false, this.noCard = false});
  final String teks;
  final bool absorb;
  final bool noCard;

  @override
  Widget build(BuildContext context) {
    Widget _isi = Padding(
      padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        SizedBox(height: 6.0,),
        CircularProgressIndicator(),
        SizedBox(height: 12.0,),
        Text(teks ?? "Harap tunggu ..."),
      ],),
    );

    return noCard ? _isi : AbsorbPointer(
      absorbing: absorb,
      child: Center(
        child: Opacity(
          opacity: 0.8,
          child: Card(
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Colors.white,
            elevation: 20.0,
            child: _isi,
          ),
        ),
      ),
    );
  }
}

enum CardInputType {
  TEXT,
  PASSWORD,
  DATE_OF_BIRTH,
  PHONE,
  PIN,
}

class CardInput extends StatefulWidget {
  CardInput({Key key, this.icon, this.placeholder, this.showLabel = true, this.info, this.prefiks, this.height = 45.0, this.radius = 30.0, this.borderColor, this.borderWidth = 1.0, this.jenis = CardInputType.TEXT, this.tipe, this.caps, this.controller, this.focusNode, this.initialValue = '', this.aksi, this.klik, this.onChanged, this.marginBottom = 8.0}) : super(key: key);
  final IconData icon;
  final String placeholder;
  final String info;
  final String prefiks;
  final bool showLabel;
  final double height;
  final double radius;
  final Color borderColor;
  final double borderWidth;
  final CardInputType jenis;
  final TextInputType tipe;
  final TextCapitalization caps;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String initialValue;
  final void Function(String) aksi;
  final void Function() klik;
  final void Function(dynamic) onChanged;
  final double marginBottom;

  @override
  _CardInputState createState() => _CardInputState();
}

class _CardInputState extends State<CardInput> {
  EdgeInsetsGeometry _contentPadding = EdgeInsets.symmetric(vertical: 14.0);

  double _fontSize = 15.0;
  bool _viewText;
  Widget _input;

  @override
  void initState() {
    super.initState();
    _viewText = widget.jenis != CardInputType.PASSWORD && widget.jenis != CardInputType.PIN;
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.jenis) {
      case CardInputType.TEXT:
        _input = Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: TextFormField(
            keyboardType: widget.tipe,
            textCapitalization: widget.caps ?? TextCapitalization.none,
            obscureText: !_viewText,
            style: TextStyle(fontSize: _fontSize),
            decoration: InputDecoration(contentPadding: _contentPadding, hintText: widget.placeholder, prefixIcon: Icon(widget.icon, size: _fontSize,), border: InputBorder.none),
            textInputAction: TextInputAction.go,
            controller: widget.controller,
            focusNode: widget.focusNode,
            enableInteractiveSelection: widget.klik == null,
            onTap: widget.klik == null ? null : () {
              FocusScope.of(context).requestFocus(FocusNode());
              widget.klik();
            },
            //onSubmitted: widget.aksi,
            validator: (String value) {
              //return value.contains('@') ? 'Do not use the @ char.' : null;
              return null;
            },
          ),
        );
        break;
      case CardInputType.PHONE:
        _input = Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: TextFormField(
            keyboardType: TextInputType.phone,
            style: TextStyle(fontSize: _fontSize),
            decoration: InputDecoration(contentPadding: _contentPadding, prefixStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: _fontSize), prefix: Text(widget.prefiks ?? "+62  "), hintText: widget.placeholder, prefixIcon: Icon(widget.icon, size: _fontSize,), border: InputBorder.none),
            textInputAction: TextInputAction.go,
            controller: widget.controller,
            focusNode: widget.focusNode,
            //onSubmitted: widget.aksi,
            validator: (String value) {
              //return value.contains('@') ? 'Do not use the @ char.' : null;
              return null;
            },
          ),
        );
        break;
      case CardInputType.PASSWORD:
      case CardInputType.PIN:
        _input = Stack(children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 40.0),
            child: TextFormField(
              obscureText: !_viewText,
              enableInteractiveSelection: false,
              keyboardType: widget.jenis == CardInputType.PIN ? TextInputType.number : null,
              inputFormatters: widget.jenis == CardInputType.PIN ? <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ] : null,
              //maxLength: widget.jenis == CardInputType.PIN ? 6 : null,
              maxLines: 1,
              style: TextStyle(fontSize: _fontSize),
              decoration: InputDecoration(contentPadding: _contentPadding, hintText: widget.placeholder, prefixIcon: Icon(widget.icon, size: _fontSize,), border: InputBorder.none),
              textInputAction: TextInputAction.go,
              controller: widget.controller,
              focusNode: widget.focusNode,
              validator: (String value) {
                return null;
              },
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(icon: Icon(_viewText ? Icons.visibility_off : Icons.visibility), iconSize: _fontSize, color: Colors.grey, onPressed: () {
              setState(() { _viewText = !_viewText; });
            },),
          ),
        ],);
        break;
      case CardInputType.DATE_OF_BIRTH:
        final format = DateFormat("dd/MM/yyyy");
        List<String> date = widget.initialValue.split("-");
        _input = DateTimeField(
          format: format,
          initialValue: date.length == 3 ? DateTime(int.parse(date[0]), int.parse(date[1]), int.parse(date[2])) : null,
          style: TextStyle(fontSize: _fontSize),
          decoration: InputDecoration(contentPadding: _contentPadding, hintText: "${widget.placeholder} (DD/MM/YYYY)", prefixIcon: Icon(MdiIcons.calendar, size: _fontSize,), border: InputBorder.none),
          resetIcon: Icon(MdiIcons.closeCircle, size: _fontSize,),
          onShowPicker: (context, currentValue) {
            DateTime now = DateTime.now();
            DateTime min = now.subtract(Duration(days: 100 * 365));
            DateTime max = now.subtract(Duration(days: 10 * 365));
            return showDatePicker(
              context: context,
              initialDate: currentValue ?? max,
              firstDate: min,
              lastDate: max,
            );
          },
          onChanged: widget.onChanged,
        );
        break;
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          widget.showLabel
            ? Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text(widget.placeholder + ((widget.info ?? "").isEmpty ? ":" : " (${widget.info}):"), style: TextStyle(fontSize: 14.0, color: Colors.grey),),)
            : SizedBox(),
          Card(
            shape: ContinuousRectangleBorder(
              side: BorderSide(color: widget.borderColor ?? Colors.grey[350], width: 1.0,),
              borderRadius: BorderRadius.circular(30.0),
            ),
            elevation: 0.0,
            margin: EdgeInsets.zero,
            child: widget.height == null ? _input : SizedBox(height: widget.height, child: Center(child: _input,),),
          ),
        ],
      ),
    );
  }
}

class PersonIcon extends StatefulWidget {
  PersonIcon({Key key, this.icon, this.teks, this.warna, this.aksi}) : super(key: key);
  final IconData icon;
  final String teks;
  final Color warna;
  final void Function() aksi;

  @override
  _PersonIconState createState() => _PersonIconState();
}

class _PersonIconState extends State<PersonIcon> {
  Color _warna;
  double _paddingLeft;
  double _paddingRight;
  double _paddingTop;
  double _paddingBottom;
  double _sizeVar;

  @override
  void initState() {
    _warna = widget.warna;
    _paddingLeft = 1.0 + Random().nextDouble() * 9.0;
    _paddingRight = 1.0 + Random().nextDouble() * 9.0;
    _paddingTop = 1.0 + Random().nextDouble() * 9.0;
    _paddingBottom = 1.0 + Random().nextDouble() * 9.0;
    _sizeVar = 0.8 + Random().nextDouble() * 0.4;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(left: _paddingLeft, right: _paddingRight, top: _paddingTop, bottom: _paddingBottom),
      child: GestureDetector(
        onTap: widget.aksi,
        child: Column(children: <Widget>[
          Icon(widget.icon, color: _warna, size: 25.0 * _sizeVar,),
          Text(widget.teks, style: TextStyle(color: _warna, fontSize: 12.0 * _sizeVar),),
        ],),
      ),
    );
  }
}

class UiButton extends StatelessWidget {
  UiButton({this.btnKey, this.color, this.icon, this.ukuranIcon, this.teks, this.aksi, this.radius = 30.0, this.elevation = 2.0, this.ukuranTeks = 0.0, this.posisiTeks});
  final Color color;
  final IconData icon;
  final String teks;
  final double ukuranTeks;
  final double ukuranIcon;
  final double radius;
  final double elevation;
  final Key btnKey;
  final MainAxisAlignment posisiTeks;
  final void Function() aksi;

  @override
  Widget build(BuildContext context) {
    double ukuranFont = ukuranTeks == 0.0 ? Theme.of(context).textTheme.button.fontSize : ukuranTeks;
    //HSLColor warnaHSL = HSLColor.fromColor(color);
    return RaisedButton(
      key: btnKey,
      color: color,
      elevation: elevation,
      hoverElevation: elevation,
      shape: RoundedRectangleBorder(
        //side: BorderSide(color: aksi == null ? Colors.grey : warnaHSL.withLightness(0.5).toColor(), width: 2),
        side: BorderSide(color: aksi == null ? Colors.grey : color, width: 2),
        borderRadius: BorderRadius.circular(radius)
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: posisiTeks ?? MainAxisAlignment.start, children: <Widget>[
        icon == null ? SizedBox() : Icon(icon, color: Colors.white, size: ukuranIcon ?? (ukuranFont * 1.2),),
        teks == null ? SizedBox() : Padding(padding: EdgeInsets.only(left: 8.0), child: Text(teks, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: ukuranFont),),),
      ],),
      onPressed: aksi,
    );
  }
}

class NavLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //if (!isDebugMode) return;
        showDialog(context: context, builder: (_) => ThemeConsumer(child: ThemeDialog(
          title: Text("Pilih Tema", style: TextStyle(fontSize: 20.0, fontFamily: 'FlamanteRoma'),),
          selectedThemeIcon: Icon(MdiIcons.check, color: Colors.white),
        )));
      },
      child: Hero(
        tag: "SplashLogo",
        child: Image.asset("images/logo.png", width: 88.0, height: 40.0, fit: BoxFit.contain,),
      ),
    );
  }
}

class TopGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(left: 0, right: 0, top: 0, child: IgnorePointer(child: Container(
      height: 20.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
          colors: [
            (ThemeProvider.themeOf(context).id == THEME_LIGHT ? Colors.white : Theme.of(context).primaryColor).withOpacity(1.0),
            (ThemeProvider.themeOf(context).id == THEME_LIGHT ? Colors.white : Theme.of(context).primaryColor).withOpacity(0.0),
          ],
          stops: [
            0.0,
            1.0,
          ]
        ),
      ),
    ),),);
  }
}