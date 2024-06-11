import 'package:colyakapp/viewmodel/SettingsViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: Consumer<SettingsViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Ayarlar"),
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/colyak.png",
                        height: MediaQuery.of(context).size.width / 2.5,
                        width: MediaQuery.of(context).size.width / 2.5,
                      )
                    ],
                  ),
                ),
                ListTile(
                  title: const Text("Önbelleği Temizle: "),
                  trailing: ElevatedButton(
                    onPressed: viewModel.isClearingCache
                        ? null
                        : () async {
                            await viewModel.clearCache();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Önbellek temizlendi!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                    child: viewModel.isClearingCache
                        ? CircularProgressIndicator()
                        : const Text("Temizle"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
