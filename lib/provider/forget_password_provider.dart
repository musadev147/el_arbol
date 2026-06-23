import 'package:flutter/material.dart';

class ForgetPasswordProvider extends ChangeNotifier {

  String? _email;
  String? _otp;
  String? _forgetEmail;





  String? get email => _email;
  String? get otp => _otp;
  String? get forgetEmail => _forgetEmail;




  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }
  void setForgetEmail(String forgetEmail) {
    _forgetEmail = forgetEmail;
    notifyListeners();
  }

  void setPhone(String phone) {
    _otp = otp;
    notifyListeners();
  }

}
