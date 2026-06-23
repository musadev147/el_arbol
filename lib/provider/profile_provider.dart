import 'dart:io';

import 'package:flutter/cupertino.dart';

class ProfileProvider extends ChangeNotifier {
  String _name = "";
  String _email = "";
  String _phone = "";
  String _gender = "";
  String _dateOfBirth = "";
  String _avatar = "";
 // String _countryCode = "";
  File? selectedFile;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  //String get countryCode => _countryCode;
  String get gender => _gender;
  String get dateOfBirth => _dateOfBirth;
  String get avatar => _avatar;
  file(File? selectFile) {
    selectedFile = selectFile;
    notifyListeners();
  }

  // changeCountryCode(String countC) {
  //   _countryCode = countC;
  //   notifyListeners();
  // }

  changeInformation({
    required String fullName,
    required String email,
    required String phone,
   // required String countryCode,
    required String gender,
    required String dateOfBirth,
    required String avatar,
  }) {
    _name = fullName;
    _email = email;
    _phone = phone;
    //_countryCode = countryCode;
    _gender = gender;
    _dateOfBirth = dateOfBirth;
    _avatar = avatar;
    notifyListeners();
  }
}