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
          return WillPopScope(
            onWillPop: () async {
              if (viewModel.selectedIndex != 0) {
                viewModel.onItemTapped(0);
                return false;
              }
              return true;
            },
            child: Scaffold(
              body: IndexedStack(
                index: viewModel.selectedIndex,
                children: const [
                  HomeScreen(),
                  ReceiptScreen(),
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
                ],
                currentIndex: viewModel.selectedIndex,
                onTap: viewModel.onItemTapped,
              ),
            ),
          );
        },
      ),
    );
  }
}
