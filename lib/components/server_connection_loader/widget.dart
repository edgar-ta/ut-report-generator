import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:ut_report_generator/api/verify_connection.dart';
import 'package:ut_report_generator/components/server_connection_loader/error_page.dart';
import 'package:ut_report_generator/components/server_connection_loader/loading_page.dart';

class ServerConnectionLoader extends StatefulWidget {
  final Widget Function(VerifyConnection_Response response) builder;
  final Duration minVisibleDuration;

  ServerConnectionLoader({
    super.key,
    required this.builder,
    this.minVisibleDuration = const Duration(seconds: 5),
  });

  @override
  State<ServerConnectionLoader> createState() => _ServerConnectionLoaderState();
}

class _ServerConnectionLoaderState extends State<ServerConnectionLoader> {
  bool _minTimeElapsed = false;
  bool _dataLoaded = false;
  VerifyConnection_Response? _response;

  @override
  void initState() {
    super.initState();
    _loadData();

    Future.delayed(widget.minVisibleDuration).then((_) {
      setState(() {
        _minTimeElapsed = true;
      });
    });
  }

  void _loadData() async {
    await verifyConnection()
        .then((result) {
          _response = result;
        })
        .catchError((error) {
          print("@server_connection_loader/widget.dart");
          print("An error ocurred");
          print(error);
        });
    setState(() {
      _dataLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_minTimeElapsed || !_dataLoaded) {
      return LoadingPage();
    }

    if (_response != null) {
      return widget.builder(_response!);
    }

    return ErrorPage(
      retry: () {
        setState(() {
          _dataLoaded = false;
          _loadData();
        });
      },
    );
  }
}
