import 'package:flutter/material.dart';

class ContainerWithAnimatedBorderOpacity extends StatefulWidget {
  final double? width;
  final double? height;
  final BoxShape? shape;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;
  final Color? borderColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Widget? child;
  final double from;
  final double to;

  const ContainerWithAnimatedBorderOpacity({
    Key? key,
    this.width,
    this.height,
    this.shape,
    this.color,
    this.borderRadius,
    this.borderColor,
    this.padding,
    this.margin,
    this.child,
    this.from = 0.0,
    this.to = 1.0,
  }) : super(key: key);

  @override
  State<ContainerWithAnimatedBorderOpacity> createState() =>
      _ContainerWithAnimatedBorderOpacityState();
}

class _ContainerWithAnimatedBorderOpacityState
    extends State<ContainerWithAnimatedBorderOpacity>
    with TickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _controller?.addListener(() {
      setState(() {});
    });
    _controller?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller?.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller?.forward();
      }
    });
    _controller?.forward();
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = widget.borderColor ?? Colors.grey;
    if (_controller != null) {
      double value = Tween(begin: widget.from, end: widget.to).evaluate(
          CurvedAnimation(parent: _controller!, curve: Curves.easeInOutQuad));
      borderColor = borderColor.withOpacity(value);
    } else {
      borderColor = borderColor.withOpacity(widget.from);
    }
    return Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      margin: widget.margin,
      decoration: BoxDecoration(
        shape: widget.shape ?? BoxShape.rectangle,
        color: widget.color,
        border: Border.all(color: borderColor),
        borderRadius: widget.borderRadius,
      ),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
