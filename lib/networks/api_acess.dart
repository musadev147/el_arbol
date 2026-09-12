import 'package:rxdart/rxdart.dart';
import 'package:get/get.dart';
import '../helpers/di.dart';
import '../constants/app_constants.dart';
import '../route/app_pages.dart';
import '../networks/dio/dio.dart';

import '../networks/dio/token_storage.dart';

class PostLogoutRX {
  final dynamic empty;
  final BehaviorSubject dataFetcher;

  PostLogoutRX({required this.empty, required this.dataFetcher});

  Future<void> logOut() async {
    try {
      await appData.remove(kKeyAccessToken);
      await appData.remove(kKeyRefreshToken);
      await appData.remove(kKeyUserID);
      await appData.remove('user_role');
      await TokenStorage().clearTokens();
      DioSingleton.instance.update('');
    } catch (e) {
      // Ignore errors during local cleanup
    } finally {
      Get.offAllNamed(Routes.ROLE_SELECTION);
    }
  }
}

class DeletePropertyRx {
  final dynamic empty;
  final BehaviorSubject dataFetcher;

  DeletePropertyRx({required this.empty, required this.dataFetcher});

  Future<bool> propertyDelete({required int id}) async {
    // Stub implementation
    return true;
  }
}

class PostLogOutModel {}
class PropertyDeleteModel {}

final PostLogoutRX postLogoutRX = PostLogoutRX(
  empty: PostLogOutModel(),
  dataFetcher: BehaviorSubject<PostLogOutModel>(),
);

final DeletePropertyRx deletePropertyRx = DeletePropertyRx(
  empty: PropertyDeleteModel(),
  dataFetcher: BehaviorSubject<PropertyDeleteModel>(),
);

bool isTenantAdded = false;