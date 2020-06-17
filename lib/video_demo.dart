import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class VideoDemoPage extends StatefulWidget {
  @override
  _VideoDemoPageState createState() => _VideoDemoPageState();
}

class _VideoDemoPageState extends State<VideoDemoPage> {
  VideoPlayerController videoPlayerController;
  ChewieController _chewieController;
  var listener;
  int seconds = 0;
  int duration = 0;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.asset('assets/videoplayback.mp4')
      ..initialize().then((value){
//        videoPlayerController.play();
      });

    videoPlayerController.addListener(() {
      seconds = videoPlayerController.value.position.inSeconds;
      print("seconds $seconds");
      if(seconds == 5){
        setState(() {

        });
      }
    });

    _chewieController = ChewieController(
      autoPlay: false,
      videoPlayerController: videoPlayerController,
      aspectRatio: videoPlayerController.value.aspectRatio,
      looping: false,
      overlay: getWidget()
    );


//    _chewieController.addListener(() {
//      if(_chewieController.isFullScreen) {
//        var wid = _chewieController.overlay;
//        print("WidgetProgress ${wid.toString()}");
//        setState(() {
//
//        });
////        _chewieController.overlay;
//      }
//    });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Question Video'),
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Chewie(
              controller: _chewieController,
            ),

            Positioned(
              left: 50.0,
              top: 50.0,
              child: Visibility(
                visible: true,
                child: InkWell(
                  onTap: (){
                    setState(() {
                      _visible = true;
                      print("visible");
                    });
                  },
                  child: Container(
                    height: 80.0,
                    width: 150.0,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget getWidget(){
    return Visibility(
      visible: _visible,
      child: Container(
        height: 80.0,
        width: 150.0,
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
    );
  }
}
