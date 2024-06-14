import 'package:colyakapp/model/BolusJson.dart';
import 'package:colyakapp/model/ReceiptJson.dart';
import 'package:colyakapp/service/HttpBuild.dart';
import 'package:colyakapp/screen/QuizScreen.dart';
import 'package:colyakapp/viewmodel/BolusModel.dart';
import 'package:colyakapp/viewmodel/HomeScreenViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:colyakapp/screen/ReceiptDetailScreen.dart';
import 'package:colyakapp/screen/BarcodeScanner.dart';
import 'package:colyakapp/screen/MealScreen.dart';
import 'package:colyakapp/screen/UserGuidesScreen.dart';
import 'package:colyakapp/screen/BolusReportScreen.dart';
import 'package:colyakapp/screen/SettingsScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            drawer: _buildDrawer(context),
            appBar: AppBar(title: const Text("Çölyak Diyabet")),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _buildWelcomeMessage(context),
                  _buildActionsGrid(context, viewModel),
                  _buildTop5Receipts(viewModel, context),
                  _buildMealSection(context, viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                DrawerHeader(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: Image.asset("assets/images/colyak.png"))
                    ],
                  ),
                ),
                _buildDrawerItem(Icons.document_scanner, 'Bolus Raporları',
                    (context) => const BolusReportScreen(), context),
                _buildDrawerItem(Icons.quiz, 'Quizler',
                    (context) => const QuizScreen(), context),
                _buildDrawerItem(Icons.menu_book, 'Faydalı Bilgiler',
                    (context) => const UserGuides(), context),
                _buildDrawerItem(Icons.settings, 'Ayarlar',
                    (context) => const SettingsScreen(), context),
                _buildDrawerItem(Icons.logout, 'Çıkış Yap', (context) {
                  Navigator.pop(context);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        "/loginscreen", (Route<dynamic> route) => false);
                  });
                  return Container();
                }, context),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('© 2024 Çölyak Hastaları',
                style: TextStyle(fontSize: 12, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title,
      Widget Function(BuildContext) builder, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: builder));
        },
      ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 32),
            Text(" Hoş geldin, ${HttpBuildService.userName}",
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsGrid(BuildContext context, HomeViewModel viewModel) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 5, top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Neler yapılabilir?", style: TextStyle(fontSize: 18))
            ],
          ),
        ),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
          ),
          children: [
            GestureDetector(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScanner(),
                  ),
                ).then((onValue) {
                  if (onValue.isNotEmpty) {
                    viewModel.sendBarcode(context, onValue);
                  }
                });
              },
              child: const Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.barcode_reader, size: 32),
                    ListTile(
                        title: Text("Barkod Tarayıcı"),
                        subtitle: Text("Hazır gıdalar için barkod tarayıcı")),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                viewModel.showSuggestionModal(context);
              },
              child: const Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.tips_and_updates, size: 32),
                    ListTile(
                        title: Text("Öneri Yap"),
                        subtitle: Text("Diyetisyeninize öneri yapın")),
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildTop5Receipts(HomeViewModel viewModel, BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(10),
          child:
              Text("En Çok Beğenilen 5 Tarif", style: TextStyle(fontSize: 18)),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height / 3.7,
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1),
            itemCount: viewModel.receipts.length,
            itemBuilder: (context, index) {
              return _buildReceiptCard(
                  context, viewModel, viewModel.receipts[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptCard(
      BuildContext context, HomeViewModel viewModel, ReceiptJson receipt) {
    String imageUrl =
        "https://api.colyakdiyabet.com.tr/api/image/get/${receipt.imageId}";

    return GestureDetector(
      onTap: () {
        if (viewModel.imageBytesMap.containsKey(imageUrl)) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReceiptDetailScreen(
                receipt: receipt,
                imageUrl: imageUrl,
                isLiked: false,
              ),
            ),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (viewModel.imageBytesMap.containsKey(imageUrl))
              Expanded(
                flex: 7,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)),
                  child: Image.memory(
                    viewModel.imageBytesMap[imageUrl]!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              )
            else
              Expanded(
                flex: 7,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey.shade300,
                ),
              ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      receipt.receiptName!,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool areListsEqual(List<FoodListComplex> list1, List<FoodListComplex> list2) {
    if (list1.length != list2.length) {
      return false;
    }
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }
    return true;
  }

  Widget _buildMealSection(BuildContext context, HomeViewModel viewModel) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text("Öğün Ekle", style: TextStyle(fontSize: 18)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MealScreen(
                        foodListComplex: viewModel.foodListComplex,
                        barkodList: viewModel.barcodesMeal,
                        receiptList: viewModel.receiptsMeal))).then((value) {
              if (value != null &&
                  !areListsEqual(
                      value,
                      Provider.of<BolusModel>(context, listen: false)
                          .foodList)) {
                Provider.of<BolusModel>(context, listen: false)
                    .updateFoodList(value);
                Provider.of<BolusModel>(context, listen: false).updateTotalCarb(
                    value.fold(0, (sum, item) => sum + item.carbonhydrate!));
              }
            });
          },
          child: const Card(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: ListTile(
                title: Text("Öğün Listem"),
                subtitle: Text(
                    "Bolus hesaplamak için yediklerini seçip öğün listeni oluştur"),
                leading: Icon(Icons.fastfood),
                trailing: Icon(Icons.arrow_forward_sharp),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
