import 'dart:async';
import 'dart:wasm';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttervideodemo/chewiePlayer/chewie_player.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:quiver/async.dart';

class VideoModel extends StatefulWidget {

  final type;

  const VideoModel({Key key, this.type}) : super(key: key);

  @override
  _VideoModelState createState() => _VideoModelState();
}


class _VideoModelState extends State<VideoModel> {

  VideoPlayerController videoPlayerController;
  ChewieController _chewieController;
  var listener;
  Timer timer;
  int seconds = 0;
  int duration = 0;
  bool isPlay = false;
  bool _visible = false;
  var sub;
  int _start = 0;
  int _current = 0;
  var _percentValue = 0.0;

  bool appBarAvailable = true;

  @override
  void initState() {
    super.initState();

    videoPlayerController = VideoPlayerController.asset('assets/videoplayback.mp4')
    ..initialize().then((value){
      setState(() {
        _start = videoPlayerController.value.duration.inSeconds;
        _current = videoPlayerController.value.duration.inSeconds;
        duration = videoPlayerController.value.duration.inSeconds;
      });
      startTimer();
      videoPlayerController.play();
    });

    videoPlayerController.addListener(() {
      print("seconds $seconds");
      setState(() {
        if(seconds == 9 || seconds == 10 || seconds == 11){
          _visible = true;
        } else{
          _visible = false;
        }
        seconds = videoPlayerController.value.position.inSeconds;

        var percent = (seconds * 100) ~/ duration;
        _percentValue = (percent / 100);
      });
    });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  void startTimer() {
    CountdownTimer countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    sub = countDownTimer.listen(null);
    sub.onData((duration) {
      if (mounted) {
        setState(() {
          _current = _start - duration.elapsed.inSeconds;
          debugPrint('Current time : $_current');
        });
      }
    });
//
    sub.onDone(() {
      sub.cancel();
      print("Done on question page");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarAvailable
        ? AppBar(
            leading: const BackButton(),
            title: Text('Question Video'),
          )
        : null,
        body: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
//                    margin: const EdgeInsets.symmetric(vertical: 20.0),
                    child: AspectRatio(
                      aspectRatio: videoPlayerController?.value?.aspectRatio,
                      child: VideoPlayer(
                        videoPlayerController
                      ),
                    )
                ),
                Positioned(
                  bottom: 0.0,
                  right: 0.0,
                  left: 0.0,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: (){
                          setState(() {
                            if(videoPlayerController.value.isPlaying){
                              videoPlayerController.pause();
                              sub.pause();
                            } else if(seconds == duration){
                              videoPlayerController.seekTo(Duration(seconds: 0));
                              seconds = videoPlayerController.value.position.inSeconds;
                              duration = videoPlayerController.value.duration.inSeconds;
                              _start = duration;
                              _current = duration;
                              _percentValue = 0.0;
                              sub.cancel();
                              startTimer();
                              videoPlayerController.play();
                            } else {
                              _start = duration - seconds;
                              _current = duration - seconds;
                              sub.cancel();
                              startTimer();
                              videoPlayerController.play();
                            }
                          });
                        },
                        icon: Icon(
                          videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                      Expanded(
                        child: LinearPercentIndicator(
//                          width: MediaQuery.of(context).size.width - 150,
                          lineHeight: 3.0,
                          percent: _percentValue,
                          backgroundColor: Colors.grey,
                          progressColor: Colors.blue,
                        ),
                      ),
                      Text(
                        '${formatHHMMSS(_current)}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: Icon(
                          appBarAvailable ? Icons.fullscreen : Icons.fullscreen_exit,
                          size: 24.0,
                          color: Colors.white,
                        ),
                        onPressed: (){
//                          videoPlayerController?.pause();
//                          print("Value of seconds $seconds");
//                          Navigator.push(context,
//                              MaterialPageRoute(builder: (context)=> VideoModelFullScreen(
//                                  sec: seconds
//                              ))
//                          ).then((value){
//                            if(value != null){
//                              if(value['sec'] != null){
//                                setState(() {
//                                  _start = duration - value['sec'];
//                                  _current = duration - value['sec'];
//                                });
//                                sub.cancel();
//                                startTimer();
//                                videoPlayerController.seekTo(Duration(seconds: value['sec']));
//                                videoPlayerController.play();
//                              }
//                            }
//                          });
                          setState(() {
                            if(appBarAvailable){
                              SystemChrome.setPreferredOrientations([
                                DeviceOrientation.landscapeRight,
                                DeviceOrientation.landscapeLeft,
                              ]);
                              SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
                              //    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                              //      statusBarColor: Colors.transparent,
                              //    ));
                            } else {
                              SystemChrome.setPreferredOrientations([
                                DeviceOrientation.landscapeRight,
                                DeviceOrientation.landscapeLeft,
                                DeviceOrientation.portraitUp,
                                DeviceOrientation.portraitDown,
                              ]);
                            }
                            appBarAvailable = !appBarAvailable;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16.0,
                  bottom: 30.0,
                  child: Visibility(
                    visible: _visible ,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 10.0),
                      decoration: BoxDecoration(
                          color: Colors.grey[500]
                      ),
                      child: Text(
                        'some answer available at this time',
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        )
    );
  }

  void displayDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) => Theme(
          data: Theme.of(context).copyWith(
              cupertinoOverrideTheme: CupertinoThemeData(
                  brightness: Brightness.light
              )
          ),
          child: CupertinoAlertDialog(
            content: Text(
              message,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: const Text('Play Again'),
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
                    videoPlayerController.play();
                  }),
            ],
          ),
        ),
        barrierDismissible: false);
  }

  String formatHHMMSS(int seconds) {
    int hours = (seconds / 3600).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();

    String hoursStr = (hours).toString().padLeft(2, '0');
    String minutesStr = (minutes).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    if (hours == 0) {
      return "$minutesStr:$secondsStr";
    }

    return "$hoursStr:$minutesStr:$secondsStr";
  }
}
