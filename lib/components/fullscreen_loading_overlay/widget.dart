import 'package:flutter/material.dart';

class FullscreenLoadingOverlay<T extends Object> extends StatefulWidget {
  final Future<T> Function() callback;
  final Widget Function(T response) builder;
  final Widget errorScreen;
  final Widget loadingScreen;
  final T? state;

  const FullscreenLoadingOverlay({
    super.key,
    required this.builder,
    required this.callback,
    required this.errorScreen,
    required this.loadingScreen,
    this.state,
  });

  @override
  State<FullscreenLoadingOverlay<T>> createState() =>
      _FullscreenLoadingOverlayState<T>();
}

class _FullscreenLoadingOverlayState<T extends Object>
    extends State<FullscreenLoadingOverlay<T>> {
  T? response;
  Object? exception;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    widget
        .callback()
        .then((value) {
          setState(() {
            response = value;
            exception = null;
          });
        })
        .onError((error, _) {
          setState(() {
            response = null;
            exception = error;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    var isError = exception != null;
    var isSuccess = response != null || widget.state != null;
    var isLoading = !(isError || isSuccess);

    return Stack(
      children: [
        IgnorePointer(
          ignoring: isLoading,
          child: AnimatedOpacity(
            opacity: isLoading ? 1 : 0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            child: widget.loadingScreen,
          ),
        ),
        if (!isLoading)
          AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            child:
                isSuccess
                    ? widget.builder(widget.state ?? response as T)
                    : Column(
                      children: [
                        widget.errorScreen,
                        TextButton.icon(
                          onPressed: _loadData,
                          label: const Text("Reintentar"),
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
          ),
      ],
    );
  }
}
