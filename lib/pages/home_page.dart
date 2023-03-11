import 'package:alafasynasheed/pages/player_page.dart';
import 'package:alafasynasheed/pages/player_tools.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../notifier.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerNotifier>(builder: (_, notifier, __) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('Alafasy\'s '),
              Text(
                'nasheed',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        body: SafeArea(
            child: ListView.builder(
                itemCount: notifier.songNames.length,
                itemBuilder: (_, index) {
                  String name = notifier.songNames[index].trim();
                  String url = notifier.songLists[index];
                  return GestureDetector(
                    onTap: (){
                      notifier.getSongs(index);
                      Navigator.push(context, MaterialPageRoute(builder: (_)=>const PlayerPage()));
                      // notifier.playFirst(name);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.blue,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(name,style: TextStyle(color: Colors.white),),
                            DownloadButton(name: name, notifier: notifier, url: url),
                          ],
                        ),
                      ),
                    ),
                  );
                })),
      );
    });
  }
}
