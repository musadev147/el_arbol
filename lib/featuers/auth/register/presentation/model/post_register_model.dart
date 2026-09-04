class PostRegisterModel {
  String? message;
  String? access;
  String? refresh;
  User? user;

  PostRegisterModel({this.message, this.access, this.refresh, this.user});

  PostRegisterModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    access = json['access'];
    refresh = json['refresh'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['access'] = access;
    data['refresh'] = refresh;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  dynamic id;
  String? email;
  String? username;
  String? firstName;
  String? lastName;
  String? fullName;
  Profile? profile;
  String? userType;

  // Wholesale specific fields
  String? businessName;
  String? contactName;
  String? tradeLicenseNumber;
  String? phone;
  String? postcode;
  String? businessType;
  String? displayBusinessType;
  String? monthlyVolume;
  String? displayVolume;
  String? status;
  bool? isApproved;
  String? appliedAt;
  String? approvedAt;
  String? accountManagerName;
  String? accountManagerEmail;
  int? totalOrders;
  String? totalSpent;
  String? profileImageUrl;

  User({
    this.id,
    this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.fullName,
    this.profile,
    this.userType,
    this.businessName,
    this.contactName,
    this.tradeLicenseNumber,
    this.phone,
    this.postcode,
    this.businessType,
    this.displayBusinessType,
    this.monthlyVolume,
    this.displayVolume,
    this.status,
    this.isApproved,
    this.appliedAt,
    this.approvedAt,
    this.accountManagerName,
    this.accountManagerEmail,
    this.totalOrders,
    this.totalSpent,
    this.profileImageUrl,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    username = json['username'];
    firstName = json['firstName'] ?? json['first_name'];
    lastName = json['lastName'] ?? json['last_name'];
    fullName = json['fullName'] ?? json['name'];
    profile = json['profile'] != null ? Profile.fromJson(json['profile']) : null;
    userType = json['user_type'];

    // Wholesale parsing
    businessName = json['business_name'];
    contactName = json['contact_name'];
    tradeLicenseNumber = json['trade_license_number'];
    phone = json['phone'];
    postcode = json['postcode'];
    businessType = json['business_type'];
    displayBusinessType = json['display_business_type'];
    monthlyVolume = json['monthly_volume'];
    displayVolume = json['display_volume'];
    status = json['status'];
    isApproved = json['is_approved'];
    appliedAt = json['applied_at'];
    approvedAt = json['approved_at'];
    accountManagerName = json['account_manager_name'];
    accountManagerEmail = json['account_manager_email'];
    totalOrders = json['total_orders'];
    totalSpent = json['total_spent'];
    profileImageUrl = json['profile_image_url'];
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

    // Wholesale serialization
    data['business_name'] = businessName;
    data['contact_name'] = contactName;
    data['trade_license_number'] = tradeLicenseNumber;
    data['phone'] = phone;
    data['postcode'] = postcode;
    data['business_type'] = businessType;
    data['display_business_type'] = displayBusinessType;
    data['monthly_volume'] = monthlyVolume;
    data['display_volume'] = displayVolume;
    data['status'] = status;
    data['is_approved'] = isApproved;
    data['applied_at'] = appliedAt;
    data['approved_at'] = approvedAt;
    data['account_manager_name'] = accountManagerName;
    data['account_manager_email'] = accountManagerEmail;
    data['total_orders'] = totalOrders;
    data['total_spent'] = totalSpent;
    data['profile_image_url'] = profileImageUrl;
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
