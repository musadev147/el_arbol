import 'package:rxdart/rxdart.dart';

class PostLogoutRX {
  final dynamic empty;
  final BehaviorSubject dataFetcher;

  PostLogoutRX({required this.empty, required this.dataFetcher});

  Future<void> logOut() async {
    // Stub implementation
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