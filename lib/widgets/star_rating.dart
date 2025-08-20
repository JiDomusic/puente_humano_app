import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool allowHalfRating;
  final int starCount;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.allowHalfRating = true,
    this.starCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        double value = rating - index;
        IconData iconData;
        Color color;

        if (value >= 1) {
          iconData = Icons.star;
          color = activeColor;
        } else if (value >= 0.5 && allowHalfRating) {
          iconData = Icons.star_half;
          color = activeColor;
        } else {
          iconData = Icons.star_border;
          color = inactiveColor;
        }

        return Icon(
          iconData,
          color: color,
          size: size,
        );
      }),
    );
  }
}

class InteractiveStarRating extends StatefulWidget {
  final double initialRating;
  final Function(double) onRatingChanged;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final int starCount;

  const InteractiveStarRating({
    super.key,
    required this.initialRating,
    required this.onRatingChanged,
    this.size = 24,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.starCount = 5,
  });

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.starCount, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = index + 1.0;
            });
            widget.onRatingChanged(_currentRating);
          },
          child: Icon(
            index < _currentRating ? Icons.star : Icons.star_border,
            color: index < _currentRating ? widget.activeColor : widget.inactiveColor,
            size: widget.size,
          ),
        );
      }),
    );
  }
}