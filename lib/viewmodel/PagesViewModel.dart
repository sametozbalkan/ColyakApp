import 'package:colyakapp/model/PageModel.dart';
import 'package:flutter/material.dart';

class PagesViewModel extends ChangeNotifier {
  final List<PageModel> _pages = [
    PageModel(
      title: "31 Çeken Maymun",
      body: "Kifoz",
      imageAsset: "https://images.rawpixel.com/image_png_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIzLTA5L3Jhd3BpeGVsX29mZmljZV8yOF9mZW1hbGVfbWluaW1hbF9yb2JvdF9mYWNlX29uX2RhcmtfYmFja2dyb3VuZF81ZDM3YjhlNy04MjRkLTQ0NWUtYjZjYy1hZmJkMDI3ZTE1NmYucG5n.png",
      isNetworkImage: true,
    ),
    PageModel(
      title: "Learn as you go",
      body: "Download the Stockpile app and master the market with our mini-lesson.",
    ),
    PageModel(
      title: "Kids and teens",
      body: "Kids and teens can track their stocks 24/7 and place trades that you approve.",
    ),
    PageModel(
      title: "Full Screen Page",
      body: "Pages can be full screen as well.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc id euismod lectus, non tempor felis. Nam rutrum rhoncus est ac venenatis.",
      fullScreen: true,
    ),
    PageModel(
      title: "Another title page",
      body: "Another beautiful body text for this example onboarding",
    ),
    PageModel(
      title: "Title of last page - reversed",
      body: "Click on to edit a post",
    ),
  ];

  List<PageModel> get pages => _pages;
}
