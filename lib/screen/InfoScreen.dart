import 'package:colyakapp/viewmodel/PagesViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:introduction_screen/introduction_screen.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PagesViewModel>(
      create: (context) => PagesViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Bilgi Ekranı"),
        ),
        body: Consumer<PagesViewModel>(
          builder: (context, model, child) {
            return IntroductionScreen(
              globalBackgroundColor: Colors.white,
              allowImplicitScrolling: true,
              pages: model.pages.map((page) {
                return PageViewModel(
                  title: page.title,
                  decoration: const PageDecoration(
                    titleTextStyle:
                        TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
                    bodyTextStyle: TextStyle(fontSize: 19.0),
                    bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                    pageColor: Colors.white,
                    imagePadding: EdgeInsets.zero,
                  ).copyWith(
                    contentMargin: const EdgeInsets.symmetric(horizontal: 16),
                    fullScreen: page.fullScreen,
                    bodyFlex: page.fullScreen ? 2 : 6,
                    imageFlex: page.fullScreen ? 3 : 6,
                    safeArea: page.fullScreen ? 100 : 80,
                  ),
                  bodyWidget: Column(
                    children: [
                      SizedBox(
                        child: page.isNetworkImage
                            ? Image.network(page.imageAsset!)
                            : page.imageAsset != null
                                ? Image.asset(
                                    page.imageAsset!,
                                    width:
                                        MediaQuery.of(context).size.width / 1.5,
                                  )
                                : null,
                      ),
                      Text(page.body,
                          softWrap: true, textAlign: TextAlign.center)
                    ],
                  ),
                );
              }).toList(),
              onDone: () => Navigator.of(context).pop(),
              onSkip: () => Navigator.of(context).pop(),
              showSkipButton: true,
              skipOrBackFlex: 0,
              nextFlex: 0,
              showBackButton: false,
              back: const Icon(Icons.arrow_back),
              skip: const Text('Geri Dön',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              next: const Icon(Icons.arrow_forward),
              done: const Text('Çık',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              curve: Curves.fastLinearToSlowEaseIn,
              controlsMargin: const EdgeInsets.only(bottom: 40, left: 10, right: 10),
              controlsPadding: const EdgeInsets.all(5),
              dotsDecorator: const DotsDecorator(
                size: Size(7.0, 7.0),
                color: Color(0xFFBDBDBD),
                activeSize: Size(22.0, 10.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
              dotsContainerDecorator: const ShapeDecoration(
                color: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
