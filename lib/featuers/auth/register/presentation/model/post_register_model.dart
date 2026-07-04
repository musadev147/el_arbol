class PostRegisterModel {
  String? access;
  String? refresh;
  User? user;

  PostRegisterModel({this.access, this.refresh, this.user});

  PostRegisterModel.fromJson(Map<String, dynamic> json) {
    access = json['access'];
    refresh = json['refresh'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access'] = this.access;
    data['refresh'] = this.refresh;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
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
    profile =
    json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
    userType = json['user_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['email'] = this.email;
    data['username'] = this.username;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['fullName'] = this.fullName;
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
    data['user_type'] = this.userType;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['resolvedAvatar'] = this.resolvedAvatar;
    data['phone'] = this.phone;
    data['bio'] = this.bio;
    data['notifOrderUpdates'] = this.notifOrderUpdates;
    data['notifPromotions'] = this.notifPromotions;
    data['notifPriceChanges'] = this.notifPriceChanges;
    data['notifLeftoverPacks'] = this.notifLeftoverPacks;
    return data;
  }
}
