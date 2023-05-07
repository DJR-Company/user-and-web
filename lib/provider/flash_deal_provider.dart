import 'dart:async';
import 'package:flutter/material.dart';
import 'package:djr_shopping/data/model/response/base/api_response.dart';
import 'package:djr_shopping/data/model/response/flash_deal_model.dart';
import 'package:djr_shopping/data/model/response/product_model.dart';
import 'package:djr_shopping/data/repository/flash_deal_repo.dart';
import 'package:djr_shopping/helper/api_checker.dart';
import 'package:intl/intl.dart';

class FlashDealProvider extends ChangeNotifier {
  final FlashDealRepo flashDealRepo;
  FlashDealProvider({@required this.flashDealRepo});

  FlashDealModel _flashDeal;
  List<Product> _flashDealList;
  Duration _duration;
  Timer _timer;
  FlashDealModel get flashDeal => _flashDeal;
  List<Product> get flashDealList => _flashDealList;
  Duration get duration => _duration;
  int _currentIndex;
  int get currentIndex => _currentIndex;

  Future<void> getFlashDealList(bool reload, BuildContext context, bool notify) async {

    if (_flashDealList == null || reload) {
      ApiResponse apiResponse = await flashDealRepo.getFlashDeal();
      if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
        _flashDeal = FlashDealModel.fromJson(apiResponse.response.data);
        print('flash deal ---- > ${_flashDeal.banner}');

        if(_flashDeal.id != null) {
          DateTime endTime = DateFormat("yyyy-MM-dd").parse(_flashDeal.endDate).add(Duration(days: 1));
          _duration = endTime.difference(DateTime.now());
          _timer?.cancel();
          _timer = null;
          _timer = Timer.periodic(Duration(seconds: 1), (timer) {
            _duration = _duration - Duration(seconds: 1);
            notifyListeners();

          });

          ApiResponse megaDealResponse = await flashDealRepo.getFlashDealList(_flashDeal.id.toString());
          if (megaDealResponse.response != null && megaDealResponse.response.statusCode == 200) {
            _flashDealList = [];
            _flashDealList.addAll(ProductModel.fromJson(megaDealResponse.response.data).products);
            _currentIndex = 0;
            notifyListeners();
          } else {
            ApiChecker.checkApi(megaDealResponse);
          }
        } else {
          notifyListeners();
        }
      } else {
        ApiChecker.checkApi(apiResponse);
      }
    }
  }
  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
