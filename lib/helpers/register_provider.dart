import 'package:el_arbol/provider/carosul_provider.dart';
import 'package:el_arbol/provider/forget_password_provider.dart';
import 'package:el_arbol/provider/profile_provider.dart';
import 'package:el_arbol/provider/singnup_provider.dart';
import 'package:provider/provider.dart';

var providers = [
  ChangeNotifierProvider<ForgetPasswordProvider>(
    create: ((context) => ForgetPasswordProvider()),
  ),

  ChangeNotifierProvider<SignupProvider>(
    create: ((context) => SignupProvider()),
  ),

  ChangeNotifierProvider<ProfileProvider>(
    create: ((context) => ProfileProvider()),
  ),

  ChangeNotifierProvider<CarosulProvider>(
    create: ((context) => CarosulProvider()),
  ),
];
