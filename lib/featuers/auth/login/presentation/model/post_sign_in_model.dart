class PostSignInModel {
  String? access;
  String? refresh;
  User? user;

  PostSignInModel({this.access, this.refresh, this.user});

  PostSignInModel.fromJson(Map<String, dynamic> json) {
    access = json['access'];
    refresh = json['refresh'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['access'] = access;
    data['refresh'] = refresh;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? email;
  String? username;
  String? firstName;
  String? lastName;
  String? fullName;
  Profile? profile;
  String? userType;

  User(
      {this.id,
      this.email,
      this.username,
      this.firstName,
      this.lastName,
      this.fullName,
      this.profile,
      this.userType});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    username = json['username'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    fullName = json['fullName'];
    profile = json['profile'] != null ? Profile.fromJson(json['profile']) : null;
    userType = json['user_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['username'] = username;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['fullName'] = fullName;
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
    data['user_type'] = userType;
    return data;
  }
}

class Profile {
  String? resolvedAvatar;
  String? phone;
  String? bio;
  bool? notifOrderUpdates;
  bool? notifPromotions;
  bool? notifPriceChanges;
  bool? notifLeftoverPacks;

  Profile(
      {this.resolvedAvatar,
      this.phone,
      this.bio,
      this.notifOrderUpdates,
      this.notifPromotions,
      this.notifPriceChanges,
      this.notifLeftoverPacks});

  Profile.fromJson(Map<String, dynamic> json) {
    resolvedAvatar = json['resolvedAvatar'];
    phone = json['phone'];
    bio = json['bio'];
    notifOrderUpdates = json['notifOrderUpdates'];
    notifPromotions = json['notifPromotions'];
    notifPriceChanges = json['notifPriceChanges'];
    notifLeftoverPacks = json['notifLeftoverPacks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['resolvedAvatar'] = resolvedAvatar;
    data['phone'] = phone;
    data['bio'] = bio;
    data['notifOrderUpdates'] = notifOrderUpdates;
    data['notifPromotions'] = notifPromotions;
    data['notifPriceChanges'] = notifPriceChanges;
    data['notifLeftoverPacks'] = notifLeftoverPacks;
    return data;
  }
}
