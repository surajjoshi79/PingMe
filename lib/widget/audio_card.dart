import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:chat_app/common/utils.dart';

class AudioCard extends StatefulWidget {
  final String audioUrl;
  const AudioCard({super.key,required this.audioUrl});

  @override
  State<AudioCard> createState() => _AudioCardState();
}

class _AudioCardState extends State<AudioCard> {
  final player=AudioPlayer();
  Duration position=Duration.zero;
  Duration duration=Duration.zero;

  void handleSeek(double values){
    player.seek(Duration(seconds: values.toInt()));
  }

  @override
  void initState() {
    super.initState();
    try {
      player.setUrl(widget.audioUrl);
      player.positionStream.listen((p){
        setState(() {
          position=p;
        });
      });
      player.durationStream.listen((d){
        setState(() {
          duration=d!;
        });
      });
      player.playerStateStream.listen((state){
        if(state.processingState==ProcessingState.completed){
          setState(() {
            position=Duration.zero;
          });
          player.pause();
          player.seek(position);
        }
      });
    }catch(e){
      Utils.showSnackBar(context, 'Unable to play');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: (){
            if(player.playing){
              player.pause();
            }else{
              player.play();
            }
          },
          icon: Icon(
            player.playing?Icons.pause_circle:Icons.play_circle,
            color: Colors.purple,
            size: 35,
          ),
        ),
        Slider(
          activeColor: Colors.purple,
          inactiveColor: Theme.of(context).colorScheme.primary,
          max: duration.inSeconds.toDouble(),
          value: position.inSeconds.toDouble(),
          onChanged: handleSeek,
        )
      ],
    );
  }
}
