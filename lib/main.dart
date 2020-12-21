import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final StopWatchTimer stopWatchTimer = StopWatchTimer();

  int rate = 0;
  int lastTime = 0;

  List<int> rates = [];

  @override
  void dispose() async {
    super.dispose();
    await stopWatchTimer.dispose(); // Need to call dispose function.
  }

  @override
  Widget build(BuildContext context) {
    int sumOfRates = 0;
    rates.forEach((element) {
      sumOfRates += element;
    });
    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 3,
                width: double.infinity,
                child: InkWell(
                  onTap: () {
                    stopWatchTimer.isRunning
                        ? stopWatchTimer.onExecute.add(StopWatchExecute.stop)
                        : stopWatchTimer.onExecute.add(StopWatchExecute.start);
                  },
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Transform(
                            transform: Matrix4.skewX(-3.3),
                            child: OutlinedButton(
                              child: Text("RESET"),
                              onPressed: () {
                                stopWatchTimer.onExecute
                                    .add(StopWatchExecute.reset);
                                setState(() {
                                  rate = 0;
                                  lastTime = 0;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Colors.yellow[800], width: 1.5),
                                primary: Colors.yellow[800],
                              ),
                            ),
                          ),
                        ),
                        StreamBuilder(
                            stream: stopWatchTimer.rawTime,
                            builder: (context, snap) {
                              final value = snap.data;
                              final displayTime = StopWatchTimer.getDisplayTime(
                                value,
                              );
                              return Text(
                                displayTime,
                                style: TextStyle(
                                  fontSize: 50,
                                  fontFeatures: [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                  // decoration: BoxDecoration(
                  //   color: Colors.grey[100],
                  // ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        rate = (60 /
                                ((DateTime.now().millisecondsSinceEpoch -
                                        lastTime) /
                                    1000))
                            .round();
                        lastTime = DateTime.now().millisecondsSinceEpoch;
                        rate > 5 ? rates.add(rate) : false;
                      });
                    },
                    onLongPress: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        rates = [];
                        rate = 0;
                        lastTime = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            rate.toString(),
                            style: TextStyle(fontSize: 120),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Avg Rate: ",
                                style: TextStyle(
                                  color: Colors.yellow[700],
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              Text(
                                "${rates.length > 0 ? (sumOfRates / rates.length).round() : 0}",
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: 10,
            top: 10,
            child: IconButton(
              icon: Icon(Icons.info_outline),
              color: Colors.yellow[700],
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("How to use"),
                        content: Column(
                          children: [
                            Text("Stop watch:",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("Tap near the time to start/stop the watch"),
                            Container(height: 20),
                            Text("Rating watch:",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                "Tap the bottom half of the screen at the same point in the athletes stroke, every stroke to begin calculating rate."),
                            Container(height: 20),
                            Text(
                                "A long press on the bottom half of the screen resets the avg. rate"),
                          ],
                        ),
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}
