import 'dart:io';
import 'package:flutter/material.dart';

class SignupProvider extends ChangeNotifier {
  File? _cover;
  String? _fullName;
  String? _gender;
  Map<int, String> _preferences = {}; // Changed to Map<int, String>
  String? _dateOfBirth;
  String? _country;
  String? _userName;
  String? _email;
  String? _phone;
  String? _loginEmail;
  String? _password;
  String? _passwordConfirm;

  bool _isRemember = false;

  File? get cover => _cover;
  String? get fullName => _fullName;
  String? get gender => _gender;
  
  // Get only preference names
  // List<String> get preferences => _preferences.values.toList(); 
  List<int> get preferences => _preferences.keys.toList();
  // Get only preference IDs
  List<int> get preferenceIds => _preferences.keys.toList(); 

  String? get dateOfBirth => _dateOfBirth;
  String? get country => _country;
  String? get userName => _userName;
  String? get email => _email;
  String? get phone => _phone;
  String? get password => _password;
  String? get passwordConfirm => _passwordConfirm;
  String? get loginEmail => _loginEmail;
  bool get isRemember => _isRemember;

  void setSelectedGender(String gender) {
    _gender = gender;
    notifyListeners();
  }

  // Update selected preferences (full replace)
  void setSelectedPreferences(Map<int, String> preferences) {
    _preferences = Map.from(preferences);
    notifyListeners();
  }

  // Add a preference by ID and Name
  void addPreference(int id, String name) {
    _preferences[id] = name;
    notifyListeners();
  }

  // Remove a preference by ID
  void removePreference(int id) {
    _preferences.remove(id);
    notifyListeners();
  }

  void setFullName(String fullName) {
    _fullName = fullName;
    notifyListeners();
  }

  void setDateOfBirth(String dateOfBirth) {
    _dateOfBirth = dateOfBirth;
    notifyListeners();
  }

  void setCountry(String country) {
    _country = country;
    notifyListeners();
  }

  void setUserName(String userName) {
    _userName = userName;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPhone(String phone) {
    _phone = phone;
    notifyListeners();
  }

  void setLoginEmail(String loginEmail) {
    _loginEmail = loginEmail;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setPasswordConfirm(String passwordConfirm) {
    _passwordConfirm = passwordConfirm;
    notifyListeners();
  }

  void setCover(File cover) {
    _cover = cover;
    notifyListeners();
  }

  void toggleRemember(bool value) {
    _isRemember = value;
    notifyListeners();
  }
}
