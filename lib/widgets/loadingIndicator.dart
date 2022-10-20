import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
    required this.loadingNotifier,
    required this.loadingProgressNotifier,
  }) : super(key: key);

  final ValueNotifier<bool> loadingNotifier;
  final ValueNotifier<double?> loadingProgressNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: loadingNotifier,
      builder: (context, loading, _) {
        print('loading: $loading');
        return Visibility(
          visible: loading,
          child: ValueListenableBuilder<double?>(
            valueListenable: loadingProgressNotifier,
            builder: (context, progress, _) {
              print('progres: $progress');
              return Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color:
                          Theme.of(context).primaryColorDark.withOpacity(0.2),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                            style: BorderStyle.solid,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            value: progress,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
