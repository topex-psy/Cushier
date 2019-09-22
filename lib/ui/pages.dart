import 'package:flutter/material.dart';

class Page extends StatelessWidget {
  final PageViewModel viewModel;
  final double percentVisible;

  Page({this.viewModel, this.percentVisible = 1.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: viewModel.color,
      padding: EdgeInsets.all(30.0),
      child: Opacity(
        opacity: percentVisible,
        child: OrientationBuilder(builder: (context, orientation) {
          return Flex(
            direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform(
                transform: Matrix4.translationValues(0.0, 50.0 * (1.0 - percentVisible), 0.0),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 25.0),
                  child: Image.asset(viewModel.hero, width: viewModel.heroWidth, height: viewModel.heroHeight ?? 200.0, fit: BoxFit.contain,),
                ),
              ),
              Expanded(
                flex: orientation == Orientation.portrait ? 0 : 1,
                child: Padding(
                  padding: orientation == Orientation.portrait ? EdgeInsets.zero : EdgeInsets.only(left: 50.0, top: 50.0),
                  child: Column(crossAxisAlignment: orientation == Orientation.portrait ? CrossAxisAlignment.center : CrossAxisAlignment.start, children: <Widget>[
                    Transform(
                      transform: Matrix4.translationValues(0.0, 30.0 * (1.0 - percentVisible), 0.0),
                      child: Padding(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Text(
                          viewModel.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'FlamanteRoma',
                            fontSize: 25.0,
                          ),
                        ),
                      ),
                    ),
                    Transform(
                      transform: Matrix4.translationValues(0.0, 30.0 * (1.0 - percentVisible), 0.0),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 75.0),
                        child: Text(
                          viewModel.body,
                          textAlign: orientation == Orientation.portrait ? TextAlign.center :  TextAlign.start,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.0,
                          ),
                        ),
                      ),
                    ),
                  ],),
                ),
              ),
            ],
          );
          /* return orientation == Orientation.portrait
            ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [hero, teksP])
            : Row(children: <Widget>[hero, SizedBox(width: 50.0,), Expanded(child: teksL,)],); */
        },),
      ),
    );
  }
}

class PageViewModel {
  final Color color;
  final String hero;
  final double heroWidth;
  final double heroHeight;
  final String title;
  final String body;
  final IconData icon;

  PageViewModel({
    this.color,
    this.hero,
    this.heroWidth,
    this.heroHeight,
    this.title,
    this.body,
    this.icon,
  });
}
