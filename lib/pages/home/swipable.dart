import 'dart:math';

import 'package:eng/providers/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainSwipe extends StatefulWidget {
  final String urlImage;
  final bool inFront;
  const MainSwipe({
    Key? key,
    required this.urlImage,
    required this.inFront,
  }) : super(key: key);

  @override
  State<MainSwipe> createState() => _MainSwipeState();
}

class _MainSwipeState extends State<MainSwipe> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;

      final provider = Provider.of<CardProvider>(context, listen: false);
      provider.setScreenSize(size);
    });
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: widget.inFront ? buildFrontCard() : buildCard(),
      );
  Widget buildFrontCard() => GestureDetector(
        child: LayoutBuilder(
          builder: (context, constrains) {
            final provider = Provider.of<CardProvider>(context);
            final position = provider.position;
            final milliseconds = provider.isDragging ? 0 : 400;

            final center = constrains.smallest.center(Offset.zero);
            final angle = provider.angle * pi / 180;
            final rotateMatrix = Matrix4.identity()
              ..translate(center.dx, center.dy)
              ..rotateZ(angle)
              ..translate(-center.dx, -center.dy);
            return AnimatedContainer(
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: milliseconds),
              transform: rotateMatrix..translate(position.dx, position.dy),
              child: buildCard(),
            );
          },
        ),
        onPanStart: (details) {
          final provider = Provider.of<CardProvider>(context, listen: false);
          provider.startPosition(details);
        },
        onPanUpdate: (details) {
          final provider = Provider.of<CardProvider>(context, listen: false);
          provider.updatePosition(details);
        },
        onPanEnd: (details) {
          final provider = Provider.of<CardProvider>(context, listen: false);
          provider.endPosition();
        },
      );

  Widget buildCard() => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(widget.urlImage),
              fit: BoxFit.cover,
              alignment: Alignment(-0.3, 0),
            ),
          ),
        ),
      );
}
