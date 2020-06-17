import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:quiver/async.dart';


class VideoModelFullScreen extends StatefulWidget {

  final sec;
  const VideoModelFullScreen({Key key, this.sec}) : super(key: key);

  @override
  _VideoModelFullScreenState createState() => _VideoModelFullScreenState();
}


class _VideoModelFullScreenState extends State<VideoModelFullScreen> {

  VideoPlayerController videoPlayerController;
  ChewieController _chewieController;
  var listener;
  Timer timer;
  int seconds = 0;
  int duration = 0;
  bool isPlay = false;
  bool _visible = false;
  bool _rowVisible = true;
  var sub;
  int _start = 0;
  int _current = 0;
  var _percentValue = 0.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
//    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//      statusBarColor: Colors.transparent,
//    ));
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    videoPlayerController = VideoPlayerController.asset('assets/videoplayback.mp4')
      ..initialize().then((value){
        setState(() {
          _start = videoPlayerController.value.duration.inSeconds - (widget.sec);
          _current = videoPlayerController.value.duration.inSeconds - (widget.sec);
        });
        startTimer();
        videoPlayerController.seekTo(Duration(seconds: widget.sec));
        videoPlayerController.play();
      });

    videoPlayerController.addListener(() {
      seconds = videoPlayerController.value.position.inSeconds;
      print("seconds $seconds");
      setState(() {
        if(seconds == 15 || seconds == 16 || seconds == 17){
          _visible = true;
        } else{
          _visible = false;
        }
        seconds = videoPlayerController.value.position.inSeconds;
        duration = videoPlayerController.value.duration.inSeconds;
        var percent = (seconds * 100) ~/ duration;
        _percentValue = (percent / 100);
      });
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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

  Widget getVideo(link)
  {
//    link = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
    if(link!='')
    {

      videoPlayerController = VideoPlayerController.asset(link);
      _chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: videoPlayerController.value.aspectRatio,
      );
      return VideoPlayer(
        videoPlayerController
      );
    }
    else
    {
      print("no else");
      return Container(
        height: 0.0,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WillPopScope(
          onWillPop: () async {
            videoPlayerController.pause();
            Navigator.of(context).pop({"sec":seconds});
            return true;
          },
          child: Stack(
            children: <Widget>[
              Container(
                  child: VideoPlayer(
                      videoPlayerController
                  )
              ),

              Positioned(
                bottom: 0.0,
                right: 0.0,
                left: 0.0,
                child: Visibility(
                  visible: _rowVisible,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: (){
                          setState(() {
                            if(videoPlayerController.value.isPlaying) {
                              sub.pause();
                              videoPlayerController.pause();
                            } else if(seconds == duration) {
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
                        icon: Icon(Icons.fullscreen,size: 24.0, color: Colors.white,),
                        onPressed: (){
                          setState(() {
                            _rowVisible = false;
                          });
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeRight,
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);
                          sub.cancel();
                          videoPlayerController.pause();
                          Navigator.of(context).pop({"sec":seconds});
                        },
                      ),
                    ],
                  ),
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
        )
    );
  }

  void displayDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) => /*Theme(
          data: Theme.of(context).copyWith(
              cupertinoOverrideTheme: CupertinoThemeData(
                  brightness: Brightness.light
              )
          ),
          child: */CupertinoAlertDialog(
            content: Text(
              message,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
              ),
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: const Text('Ok'),
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
//                    videoPlayerController.play();
                  }),
            ],
          ),
//        ),
        barrierDismissible: true);
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
