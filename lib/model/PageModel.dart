class PageModel {
  final String title;
  final String body;
  final String? imageAsset;
  final bool isNetworkImage;
  final bool fullScreen;

  PageModel({
    required this.title,
    required this.body,
    this.imageAsset,
    this.isNetworkImage = false,
    this.fullScreen = false,
  });
}
