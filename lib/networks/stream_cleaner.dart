
import '../constants/app_constants.dart';
import '../helpers/di.dart';

Future<void> totalDataClean() async {
  await appData.write(kKeyIsLoggedIn, false);
  await appData.write(kKeyIsExploring, false);
  await appData.remove(kKeyUserName);
  await appData.remove(kKeyUserID);
  await appData.remove(kKeyAccessToken);
  // cleanLoginData();
}

void cleanLoginData() {
}
