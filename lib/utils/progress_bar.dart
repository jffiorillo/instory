import 'package:flutter/widgets.dart';

const NORMAL_ANIMATION = 600;

class ProgressBar extends StatefulWidget {
  final Color backgroundColor;
  final Color foregroundColor;
  final double value;
  final double strokeWidth;
  final int animationDuration;

  const ProgressBar({
    Key key,
    this.backgroundColor,
    @required this.foregroundColor,
    @required this.value,
    this.strokeWidth,
    animationDuration: NORMAL_ANIMATION,
  })  : this.animationDuration = animationDuration ?? NORMAL_ANIMATION,
        super(key: key);

  @override
  _ProgressBarState createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with SingleTickerProviderStateMixin {
  // Used in tweens where a backgroundColor isn't given.
  static const TRANSPARENT = Color(0x00000000);
  AnimationController _controller;
  Animation<double> curve;
  Tween<double> valueTween;
  Tween<Color> foregroundColorTween;
  Tween<Color> backgroundColorTween;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: AnimatedBuilder(
        animation: this.curve,
        child: Container(),
        builder: (context, child) {
          final foregroundColor =
              this.foregroundColorTween?.evaluate(this.curve) ??
                  this.widget.foregroundColor;
          final backgroundColor =
              this.backgroundColorTween?.evaluate(this.curve) ??
                  this.widget.backgroundColor;
          return CustomPaint(
            child: child,
            foregroundPainter: ProgressBarPainter(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              percentage: this.valueTween.evaluate(this._controller),
              strokeWidth: this.widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    this._controller = AnimationController(
      duration: Duration(milliseconds: this.widget.animationDuration),
      vsync: this,
    );
    this.curve = CurvedAnimation(
      parent: this._controller,
      curve: Curves.easeInOut,
    );
    this.valueTween = Tween<double>(
      begin: 0,
      end: this.widget.value,
    );
    this._controller.forward();
  }

  @override
  void didUpdateWidget(ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (this.widget.value != oldWidget.value) {
      // Try to start with the previous tween's end value. This ensures that we
      // have a smooth transition from where the previous animation reached.
      double beginValue =
          this.valueTween?.evaluate(this._controller) ?? oldWidget?.value ?? 0;

      // Update the value tween.
      this.valueTween = Tween<double>(
        begin: beginValue,
        end: this.widget.value ?? 1,
      );

      // Clear cached color Tweens when the foreground color hasn't changed.
      if (oldWidget.foregroundColor != this.widget.foregroundColor) {
        this.foregroundColorTween = ColorTween(
          begin: oldWidget?.foregroundColor,
          end: this.widget.foregroundColor,
        );
      } else {
        this.foregroundColorTween = null;
      }

      // Clear cached color Tweens when the background color hasn't changed.
      if (oldWidget.backgroundColor != this.widget.backgroundColor) {
        this.backgroundColorTween = ColorTween(
          begin: oldWidget?.backgroundColor ?? TRANSPARENT,
          end: this.widget.backgroundColor ?? TRANSPARENT,
        );
      } else {
        this.backgroundColorTween = null;
      }

      this._controller
        ..value = 0
        ..forward();
    }
  }

  @override
  void dispose() {
    this._controller.dispose();
    super.dispose();
  }
}

// Draws the progress bar.
class ProgressBarPainter extends CustomPainter {
  static const double _DEFAULT_STROKE_WIDTH = 6;
  final double percentage;
  final double strokeWidth;
  final Color backgroundColor;
  final Color foregroundColor;

  ProgressBarPainter({
    this.backgroundColor,
    @required this.foregroundColor,
    @required this.percentage,
    this.strokeWidth: _DEFAULT_STROKE_WIDTH,
  }) : assert(strokeWidth != null);

  @override
  void paint(Canvas canvas, Size size) {
    var middleOfSize = (size.height) / 2;
    var halfStrokeWidth = this.strokeWidth / 2;
    var startOffset = Offset(0, middleOfSize);
    var endOffset = Offset((size.width - halfStrokeWidth), middleOfSize);
    var percentage = this.percentage ?? 0;

    if (this.backgroundColor != null) {
      final backgroundPaint = Paint()
        ..color = this.backgroundColor
        ..strokeWidth = this.strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(startOffset, endOffset, backgroundPaint);
    }

    final foregroundPaint = Paint()
      ..color = this.foregroundColor
      ..strokeWidth = this.strokeWidth
      ..style = PaintingStyle.stroke;
    if (percentage > 0) foregroundPaint.strokeCap = StrokeCap.round;
    endOffset =
        Offset((size.width - halfStrokeWidth) * percentage, middleOfSize);
    canvas.drawLine(startOffset, endOffset, foregroundPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final oldPainter = (oldDelegate as ProgressBarPainter);
    return oldPainter.percentage != this.percentage ||
        oldPainter.backgroundColor != this.backgroundColor ||
        oldPainter.foregroundColor != this.foregroundColor ||
        oldPainter.strokeWidth != this.strokeWidth;
  }
}
