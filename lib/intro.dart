import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'animation/page_dragger.dart';
import 'animation/page_reveal.dart';
import 'ui/pager_indicator.dart';
import 'ui/pages.dart';

final pages = [
  PageViewModel(
    color: Colors.pink[400],
    hero: 'images/onboarding/inventory.png',
    heroHeight: 180,
    icon: MdiIcons.tagMultiple,
    title: 'Inventori',
    body: 'Kelola produk, katgeori produk, harga, promo, dan jumlah persediaan dengan praktis!',
  ),
  PageViewModel(
    color: Colors.blue[400],
    hero: 'images/onboarding/pos.png',
    heroHeight: 200,
    icon: MdiIcons.cellphoneWireless,
    title: 'Point of Sale',
    body: 'Gunakan ponsel sebagai mesin kasir pintar yang mencatat segara laporan secara otomatis!',
  ),
  PageViewModel(
    color: Colors.green[400],
    hero: 'images/onboarding/cloud.png',
    heroHeight: 230,
    icon: MdiIcons.cloudCheck,
    title: 'Berbasis Cloud',
    body: 'Seluruh data tersimpan pada cloud sehingga dapat dipantau di manapun dan kapanpun!',
  ),
];

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> with TickerProviderStateMixin {
  StreamController<SlideUpdate> slideUpdateStream;
  AnimatedPageDragger animatedPageDragger;

  int activeIndex = 0;
  SlideDirection slideDirection = SlideDirection.none;
  int nextPageIndex = 0;
  double slidePercent = 0.0;

  _IntroState() {
    slideUpdateStream = StreamController<SlideUpdate>();

    slideUpdateStream.stream.listen((SlideUpdate event) {
      setState(() {
        if (event.updateType == UpdateType.dragging) {
          slideDirection = event.direction;
          slidePercent = event.slidePercent;

          if (slideDirection == SlideDirection.leftToRight) {
            nextPageIndex = activeIndex - 1;
          } else if (slideDirection == SlideDirection.rightToLeft) {
            nextPageIndex = activeIndex + 1;
          } else {
            nextPageIndex = activeIndex;
          }
        } else if (event.updateType == UpdateType.doneDragging) {
          if (slidePercent > 0.5) {
            animatedPageDragger = AnimatedPageDragger(
              slideDirection: slideDirection,
              transitionGoal: TransitionGoal.open,
              slidePercent: slidePercent,
              slideUpdateStream: slideUpdateStream,
              vsync: this,
            );
          } else {
            animatedPageDragger = AnimatedPageDragger(
              slideDirection: slideDirection,
              transitionGoal: TransitionGoal.close,
              slidePercent: slidePercent,
              slideUpdateStream: slideUpdateStream,
              vsync: this,
            );

            nextPageIndex = activeIndex;
          }

          animatedPageDragger.run();
        } else if (event.updateType == UpdateType.animating) {
          slideDirection = event.direction;
          slidePercent = event.slidePercent;
        } else if (event.updateType == UpdateType.doneAnimating) {
          activeIndex = nextPageIndex;

          slideDirection = SlideDirection.none;
          slidePercent = 0.0;

          animatedPageDragger.dispose();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              print("HALAMAN SLIDE: $activeIndex");
              if (activeIndex < pages.length - 1) setState(() {
                animatedPageDragger = AnimatedPageDragger(
                  slideDirection: SlideDirection.rightToLeft,
                  transitionGoal: TransitionGoal.close,
                  slidePercent: 0.0,
                  slideUpdateStream: slideUpdateStream,
                  vsync: this,
                );
                nextPageIndex = activeIndex + 1;
                animatedPageDragger.run();
              }); else Navigator.of(context).pop();
            },
            child: Page(
              viewModel: pages[activeIndex],
              percentVisible: 1.0,
            ),
          ),
          PageReveal(
            revealPercent: slidePercent,
            child: Page(
              viewModel: pages[nextPageIndex],
              percentVisible: slidePercent,
            ),
          ),
          PagerIndicator(
            viewModel: PagerIndicatorViewModel(
              pages,
              activeIndex,
              slideDirection,
              slidePercent,
            ),
          ),
          PageDragger(
            canDragLeftToRight: activeIndex > 0,
            canDragRightToLeft: activeIndex < pages.length - 1,
            slideUpdateStream: this.slideUpdateStream,
          )
        ],
      ),
    );
  }
}
