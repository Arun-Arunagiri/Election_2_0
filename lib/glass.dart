import "dart:ui";
import "package:flutter/material.dart";

class Glassmorph extends StatelessWidget {
  final double blur, opacity;
  final Widget child;
  const Glassmorph({
    Key? key,
    required this.blur,
    required this.opacity,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child:
          BackdropFilter(filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(opacity),
              borderRadius: BorderRadius.all(Radius.circular(20)),
              border: Border.all(width: 1.5,color: Colors.white.withOpacity(opacity))
            ),
            child: child,
          ),
          
          ),
          
    );
  }
}
