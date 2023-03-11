import 'package:alafasynasheed/pages/player_tools.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../notifier.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<PlayerNotifier>(builder: (_, notifier, __) {
      notifier.initSize(size: size);
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(notifier.dataName2),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(CupertinoIcons.back)),
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('asset/alafasy.jpg'),fit: BoxFit.cover,opacity: .2),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 15),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    height: notifier.height * .4,
                    child: Image.asset('asset/alafasy.jpg',fit: BoxFit.cover,),
                  ),
                ),
                Center(child: Text(notifier.dataName1)),
                Text(notifier.dataName2),
                SeekBar(notifier: notifier),
                PlayerTools(notifier: notifier)
              ],
            ),
          ),
        ),
      );
    });
  }
}
