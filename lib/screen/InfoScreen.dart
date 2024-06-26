import 'package:colyakapp/model/PageData.dart';
import 'package:colyakapp/viewmodel/InfoViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  static const List<PageData> pages = [
    PageData(
      title: "Uygulama Ana Ekranı",
      description: "Uygulamaya giriş yapıldığında sizi karşılayacak olan ilk ekran.",
      imageAsset: "assets/images/mainscreen.png",
    ),
    PageData(
      title: "Kolay Erişilebilir Menü",
      description: "Ana ekranın sol üstünden menüye kolayca erişebilir ve yapmak istediklerinizi seçebilirsiniz.",
      imageAsset: "assets/images/hamburger.png",
    ),
    PageData(
      title: "Öğün Listeni Oluştur",
      description: "Öğün listeni oluşturarak bolus için karbonhidrat değerini kolayca belirleyebilirsin.",
      imageAsset: "assets/images/mealscreen.png",
    ),
    PageData(
      title: "Yüzlerce Yiyecek",
      description: "Bu listeden özgürce seçim yapabilir ve kolayca listene ekleyebilirsin.",
      imageAsset: "assets/images/addmealscreen.png",
    ),
    PageData(
      title: "Birbirinden Farklı Tarifler",
      description: "Diyetisyeninin özenle hazırladığı tüm tariflere kolayca erişebilirsin ve favorileyebilirsin.",
      imageAsset: "assets/images/receipts.png",
    ),
    PageData(
      title: "Geniş Tarif Detayları",
      description: "İstediğin tarifin malzemelerine, yapılışına ve besin değerlerine kolayca ulaşabilirsin.",
      imageAsset: "assets/images/receiptdetails.png",
    ),
    PageData(
      title: "Özgürce Yorum Yap",
      description: "İstediğin tarifin altına bu tarifle ilgili aklında ne geçerse yazabilirsin.",
      imageAsset: "assets/images/commentscreen.png",
    ),
    PageData(
      title: "Yorumlar Altında Tartış",
      description: "İstediğin yoruma cevap verebilir ve yorum sahibiyle tarif hakkında konuşabilirsin.",
      imageAsset: "assets/images/replyscreen.png",
    ),
    PageData(
      title: "Bolus Hesaplayıcı",
      description: "Öğün listeni oluşturduktan sonra alman gereken insulini buradan hesapla.",
      imageAsset: "assets/images/bolus.png",
    ),
    PageData(
      title: "Bolus Raporların",
      description: "Dilediğin tarih aralığındaki bolus raporlarını inceleyebilirsin.",
      imageAsset: "assets/images/bolusreportdetails.png",
    ),
    PageData(
      title: "Faydalı Bilgiler",
      description: "Buradan istediğin herhangi bir konuda bilgi alabilirsin.",
      imageAsset: "assets/images/pdfscreen.png",
    ),
    PageData(
      title: "Eğitici Quizler",
      description: "Birbirinden farklı eğitici ve öğretici quizleri çözüp bilgilerini test edebilirsin.",
      imageAsset: "assets/images/quiz.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InfoViewModel(),
      child: Consumer<InfoViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFF7A37),
                    Color.fromARGB(255, 255, 137, 78)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: PageView.builder(
                        controller: viewModel.pageController,
                        onPageChanged: viewModel.onPageChanged,
                        itemCount: pages.length,
                        itemBuilder: (context, index) {
                          return _buildPage(pages[index], context);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBackButton(context, viewModel),
                          ...List.generate(pages.length, (index) {
                            return _buildIndicator(
                                index == viewModel.currentPage);
                          }),
                          _buildForwardButton(context, viewModel)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPage(PageData pageData, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(pageData.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            softWrap: true,
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Text(
          pageData.description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Image.asset(
          pageData.imageAsset,
          width: MediaQuery.of(context).size.width / 1.5,
        ),
      ],
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 16.0 : 12.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, InfoViewModel viewModel) {
    if (viewModel.currentPage == 0) {
      return Container(width: 48);
    }
    return IconButton(
      onPressed: () {
        viewModel.goToPage(context, viewModel.currentPage - 1);
      },
      icon: const Icon(Icons.arrow_back, color: Colors.white),
    );
  }

  Widget _buildForwardButton(BuildContext context, InfoViewModel viewModel) {
    return IconButton(
      onPressed: () {
        viewModel.goToPage(context, viewModel.currentPage + 1);
      },
      icon: viewModel.currentPage == pages.length - 1
          ? const Icon(Icons.exit_to_app, color: Colors.white)
          : const Icon(Icons.arrow_forward, color: Colors.white),
    );
  }
}