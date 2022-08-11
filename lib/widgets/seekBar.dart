import 'dart:math';

import 'package:flutter/material.dart';

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    Key? key,
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
    this.onChangeEnd,
  }) : super(key: key);

  @override
  SeekBarState createState() => SeekBarState();
}

class SeekBarState extends State<SeekBar> {
  double? _dragValue;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Text(
            RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                    .firstMatch('${widget.position}')
                    ?.group(1) ??
                '${widget.position}',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
          Expanded(
            child: Stack(
              children: [
                SliderTheme(
                  data: _sliderThemeData.copyWith(
                    thumbShape: HiddenThumbComponentShape(),
                    activeTrackColor:
                        Theme.of(context).primaryColorDark.withOpacity(.3),
                    inactiveTrackColor: Colors.grey.shade500,
                  ),
                  child: ExcludeSemantics(
                    child: Slider(
                      min: 0.0,
                      max: widget.duration.inMilliseconds.toDouble(),
                      value: min(
                          widget.bufferedPosition.inMilliseconds.toDouble(),
                          widget.duration.inMilliseconds.toDouble()),
                      onChanged: (value) {
                        setState(() {
                          _dragValue = value;
                        });
                        if (widget.onChanged != null) {
                          widget.onChanged!(
                              Duration(milliseconds: value.round()));
                        }
                      },
                      onChangeEnd: (value) {
                        if (widget.onChangeEnd != null) {
                          widget.onChangeEnd!(
                              Duration(milliseconds: value.round()));
                        }
                        _dragValue = null;
                      },
                    ),
                  ),
                ),
                SliderTheme(
                  data: _sliderThemeData.copyWith(
                    inactiveTrackColor: Colors.transparent,
                  ),
                  child: Slider(
                    min: 0.0,
                    max: widget.duration.inMilliseconds.toDouble(),
                    value: min(
                        _dragValue ?? widget.position.inMilliseconds.toDouble(),
                        widget.duration.inMilliseconds.toDouble()),
                    thumbColor: Theme.of(context).primaryColorDark,
                    onChanged: (value) {
                      setState(() {
                        _dragValue = value;
                      });
                      if (widget.onChanged != null) {
                        widget
                            .onChanged!(Duration(milliseconds: value.round()));
                      }
                    },
                    onChangeEnd: (value) {
                      if (widget.onChangeEnd != null) {
                        widget.onChangeEnd!(
                            Duration(milliseconds: value.round()));
                      }
                      _dragValue = null;
                    },
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-${RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$').firstMatch('$_remaining')?.group(1) ?? '$_remaining'}',
            style: TextStyle(color: Theme.of(context).primaryColorDark),
          ),
        ],
      ),
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}
