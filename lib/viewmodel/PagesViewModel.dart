import 'package:colyakapp/model/PageModel.dart';
import 'package:flutter/material.dart';

class PagesViewModel extends ChangeNotifier {
  final List<PageModel> _pages = [
    PageModel(
      title: "Uygulama Ana Ekranı",
      body: "Uygulamaya giriş yapıldığında sizi karşılayacak olan ilk ekran.",
      imageAsset: "assets/images/mainscreen.png",
    ),
    PageModel(
      title: "Kolay Erişilebilir Menü",
      body: "Ana ekranın sol üstünden menüye kolayca erişebilir ve yapmak istediklerinizi seçebilirsiniz.",
      imageAsset: "assets/images/hamburger.png",
    ),
    PageModel(
      title: "Öğün Listeni Oluştur",
      body: "Öğün listeni oluşturarak bolus için karbonhidrat değerini kolayca belirleyebilirsin.",
      imageAsset: "assets/images/mealscreen.png",
    ),
    PageModel(
      title: "Yüzlerce Tarif ve Hazır Gıda",
      body: "Bu listeden özgürce seçim yapabilir ve kolayca listene ekleyebilirsin.",
      imageAsset: "assets/images/addmealscreen.png",
    ),
    PageModel(
      title: "Birbirinden Farklı Tarifler",
      body: "Diyetisyeninin özenle hazırladığı tüm tariflere kolayca erişebilirsin ve favorileyebilirsin.",
      imageAsset: "assets/images/receipts.png",
    ),
    PageModel(
      title: "Geniş Tarif Detayları",
      body: "İstediğin tarifin malzemelerine, yapılışına ve besin değerlerine kolayca ulaşabilirsin.",
      imageAsset: "assets/images/receiptdetails.png",
    ),
    PageModel(
      title: "Özgürce Yorum Yap",
      body: "İstediğin tarifin altına bu tarifle ilgili aklında ne geçerse yazabilirsin.",
      imageAsset: "assets/images/commentscreen.png",
    ),
    PageModel(
      title: "Yorumlar Altında Tartış",
      body: "İstediğin yoruma cevap verebilir ve yorum sahibiyle tarif hakkında konuşabilirsin.",
      imageAsset: "assets/images/replyscreen.png",
    ),
    PageModel(
      title: "Bolus Hesaplayıcı",
      body: "Öğün listeni oluşturduktan sonra alman gereken insulini buradan hesaplayabilirsin.",
      imageAsset: "assets/images/bolus.png",
    ),
    PageModel(
      title: "Bolus Raporların",
      body: "Dilediğin tarih aralığındaki bolus raporlarını inceleyebilirsin.",
      imageAsset: "assets/images/bolusreportdetails.png",
    ),
    PageModel(
      title: "Faydalı Bilgiler",
      body: "Buradan istediğin herhangi bir konuda bilgi alabilirsin.",
      imageAsset: "assets/images/pdfscreen.png",
    ),
    PageModel(
      title: "Eğitici ve Öğretici Quizler",
      body: "Birbirinden farklı eğitici ve öğretici quizleri çözüp bilgilerini test edebilirsin.",
      imageAsset: "assets/images/quiz.png",
    ),
  ];

  List<PageModel> get pages => _pages;
}
