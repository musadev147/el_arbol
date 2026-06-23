import 'dart:developer';
import 'package:el_arbol/common_wigdets/app_toast.dart';
import 'package:el_arbol/networks/exception_handler/data_source.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rxdart/subjects.dart';

abstract class RxResponseInt<T> {
  T empty;
  BehaviorSubject<T> dataFetcher;
  Map? map;
  BehaviorSubject? dataFetcher2;

  RxResponseInt(
      {required this.empty,
      required this.dataFetcher,
      this.map,
      this.dataFetcher2});

  dynamic handleSuccessWithReturn(T data) {
    dataFetcher.sink.add(data);
    return data;
  }

  dynamic handleErrorWithReturn(dynamic error) {
    log(error.toString());

    // Always dismiss loading spinner first so toast is visible
    EasyLoading.dismiss();

    String errorMessage = "Something went wrong";

    if (error is DioException) {
      final failure = ErrorHandler.handle(error).failure;
      errorMessage = failure.responseMessage;
    } else if (error is Exception) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
    }

    // Show at top of screen using AppToast (uses showToast which respects toastPosition)
    AppToast.error(errorMessage);

    dataFetcher.sink.addError(error);
    throw error;
  }

  void clean() {
    dataFetcher.sink.add(empty);
  }

  void dispose() {
    dataFetcher.close();
  }
}
