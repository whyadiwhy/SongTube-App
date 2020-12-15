import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songtube/provider/mediaProvider.dart';

class MusicPlayerCurrentPlaylist extends StatefulWidget {
  final bool blurUIEnabled;
  MusicPlayerCurrentPlaylist({
    this.blurUIEnabled
  });

  @override
  _MusicPlayerCurrentPlaylistState createState() => _MusicPlayerCurrentPlaylistState();
}

class _MusicPlayerCurrentPlaylistState extends State<MusicPlayerCurrentPlaylist> {

  ScrollController controller;
  double bodyOpacity = 1.0;

  @override
  void initState() {
    controller = ScrollController();
    super.initState();
    Future.delayed(Duration(milliseconds: 400), () {
      animateToCurrentPlaying();
    });
  }

  void animateToCurrentPlaying() {
    int index = AudioService.queue.indexOf(AudioService.currentMediaItem);
    double offset = index.toDouble()*75;
    controller.animateTo(
      offset,
      curve: Curves.fastLinearToSlowEaseIn,
      duration: Duration(milliseconds: 600)
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaProvider mediaProvider = Provider.of<MediaProvider>(context);
    Color dominantColor = widget.blurUIEnabled
      ? mediaProvider.dominantColor == null ? Colors.white : mediaProvider.dominantColor
      : Theme.of(context).accentColor;
    Color textColor = widget.blurUIEnabled
      ? dominantColor.computeLuminance() > 0.5 ? Colors.black : Colors.white
      : Theme.of(context).textTheme.bodyText1.color;
    Color vibrantColor = widget.blurUIEnabled
      ? mediaProvider.vibrantColor == null ? Colors.white : mediaProvider.vibrantColor
      : Theme.of(context).accentColor;
    return WillPopScope(
      onWillPop: () {
        setState(() => bodyOpacity = 0.0);
        Future.delayed(Duration(milliseconds: 200), () {
          Navigator.pop(context);
        });
      },
      child: Scaffold(
        backgroundColor: widget.blurUIEnabled
          ? dominantColor.withOpacity(0.4)
          : Theme.of(context).scaffoldBackgroundColor
            .withOpacity(0.96),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: widget.blurUIEnabled
            ? dominantColor.withOpacity(0.2)
            : Theme.of(context).scaffoldBackgroundColor
              .withOpacity(0.96),
          title: AnimatedOpacity(
            duration: Duration(milliseconds: 200),
            opacity: bodyOpacity,
            child: Text(
              "Now Playing",
              style: TextStyle(
                fontFamily: 'Product Sans',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: textColor
              ),
            ),
          ),
          leading: AnimatedOpacity(
            duration: Duration(milliseconds: 200),
            opacity: bodyOpacity,
            child: IconButton(
              icon: Icon(EvaIcons.arrowBackOutline),
              color: Theme.of(context).iconTheme.color,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          iconTheme: IconThemeData(
            color: textColor
          ),
        ),
        body: AnimatedOpacity(
          duration: Duration(milliseconds: 200),
          opacity: bodyOpacity,
          child: ListView.builder(
            controller: controller,
            physics: BouncingScrollPhysics(),
            itemExtent: 75,
            padding: EdgeInsets.only(top: 12, left: 12, right: 12),
            itemCount: AudioService.queue.length,
            itemBuilder: (context, index) {
              MediaItem song = AudioService.queue[index];
              return ListTile(
                title: Text(
                  song.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    fontFamily: "Product Sans",
                    fontWeight: FontWeight.w600
                  ),
                ),
                subtitle: Text(
                  song.artist,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                    fontFamily: "Product Sans",
                    fontWeight: FontWeight.w400
                  ),
                ),
                trailing: song == AudioService.currentMediaItem
                  ? Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: vibrantColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(50)
                      ),
                      child: Icon(
                        EvaIcons.musicOutline,
                        color: textColor,
                      ),
                    )
                  : Container(
                      height: 10, width: 10,
                    ),
                onTap: () async {
                  await AudioService.playMediaItem(song);
                  animateToCurrentPlaying();
                  setState(() {});
                },
              );
            },
          ),
        ),
      ),
    );
  }
}