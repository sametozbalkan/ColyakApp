import 'package:colyakapp/screen/BolusScreen.dart';
import 'package:colyakapp/screen/HomeScreen.dart';
import 'package:colyakapp/screen/ReceiptScreen.dart';
import 'package:colyakapp/viewmodel/HomePageViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomePageViewModel(),
      child: Consumer<HomePageViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: IndexedStack(
              index: viewModel.selectedIndex,
              children: const [
                HomeScreen(),
                ReceiptScreen(),
                BolusScreen(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Ana Sayfa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant),
                  label: 'Tarifler',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.medical_information),
                  label: 'Bolus',
                ),
              ],
              currentIndex: viewModel.selectedIndex,
              onTap: viewModel.onItemTapped,
            ),
          );
        },
      ),
    );
  }
}
