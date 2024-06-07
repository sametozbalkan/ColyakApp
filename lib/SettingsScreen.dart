import 'package:colyakapp/CacheManager.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
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
                  onPressed: () async {
                    await CacheManager().cleanDefaultCacheManager();
                  },
                  child: const Text("Temizle")))
        ],
      ),
    );
  }
}
