import 'package:flutter/material.dart';

class ScrollButton extends StatefulWidget {
  final ScrollController controller;
  const ScrollButton({super.key, required this.controller});

  @override
  State<ScrollButton> createState() => _ScrollButtonState();
}

class _ScrollButtonState extends State<ScrollButton> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      final maxScroll = widget.controller.position.maxScrollExtent;
      final currentScroll = widget.controller.offset;

      final shouldShow = (maxScroll - currentScroll) > 100;
      if (_visible != shouldShow) {
        setState(() {
          _visible = shouldShow;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _visible,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.045),
        child: Opacity(
          opacity: 0.8,
          child: IconButton(
            onPressed: (){
              widget.controller.animateTo(
                  widget.controller.position.extentTotal,
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.fastOutSlowIn
              );
            },
            icon: Icon(Icons.expand_circle_down,size: 30),
          ),
        ),
      ),
    );
  }
}
