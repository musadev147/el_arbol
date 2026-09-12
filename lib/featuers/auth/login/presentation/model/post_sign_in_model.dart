import 'dart:convert';
import 'dart:developer';

class PostSignInModel {
  String? access;
  String? refresh;
  User? user;
  String? message;
  bool? isWholesale;
  String? status;

  PostSignInModel({
    this.access,
    this.refresh,
    this.user,
    this.message,
    this.isWholesale,
    this.status,
  });

  PostSignInModel.fromJson(Map<String, dynamic> json) {
    access = json['access'] ?? json['token'] ?? json['access_token'] ?? json['data']?['access'] ?? json['data']?['token'];
    refresh = json['refresh'] ?? json['refresh_token'] ?? json['data']?['refresh'];
    
    if (json['user'] != null && json['user'] is Map) {
      user = User.fromJson(Map<String, dynamic>.from(json['user']));
    } else if (json['data'] != null && json['data'] is Map && json['data']['user'] != null) {
      user = User.fromJson(Map<String, dynamic>.from(json['data']['user']));
    } else if (json['data'] != null && json['data'] is Map) {
      user = User.fromJson(Map<String, dynamic>.from(json['data']));
    } else {
      // If user info is at top-level
      user = User.fromJson(json);
    }

    message = json['message'] ?? json['detail'] ?? json['msg'];
    isWholesale = json['is_wholesale'] ?? json['isWholesale'] ?? (user?.isWholesale);
    status = json['status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['access'] = access;
    data['refresh'] = refresh;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['message'] = message;
    data['is_wholesale'] = isWholesale;
    data['status'] = status;
    return data;
  }

  /// Decodes and extracts the JWT payload claims from the access token
  Map<String, dynamic> get jwtClaims {
    if (access == null || access!.trim().isEmpty) return {};
    try {
      final parts = access!.trim().split('.');
      if (parts.length != 3) return {};
      final normalized = base64Url.normalize(parts[1]);
      final decodedString = utf8.decode(base64Url.decode(normalized));
      final decoded = json.decode(decodedString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (e) {
      log("JWT payload decode error: $e");
    }
    return {};
  }

  /// Extracts the effective user type string across JWT claims, user object, and root response
  String get resolvedUserType {
    final jwtType = jwtClaims['user_type'] ?? jwtClaims['role'] ?? jwtClaims['userType'];
    if (jwtType != null && jwtType.toString().trim().isNotEmpty) {
      return jwtType.toString().trim();
    }
    if (user?.userType != null && user!.userType!.trim().isNotEmpty) {
      return user!.userType!.trim();
    }
    if (user?.role != null && user!.role!.trim().isNotEmpty) {
      return user!.role!.trim();
    }
    if (isWholesaleAccount) return 'WHOLESALE';
    return '';
  }

  /// Identifies if this account is a wholesale B2B account
  bool get isWholesaleAccount {
    if (isWholesale == true) return true;
    if (user?.isWholesale == true) return true;
    if (jwtClaims['is_wholesale'] == true) return true;
    final uType = resolvedUserType.toUpperCase();
    if (uType == 'WHOLESALE' || uType == 'WHOLESALER' || uType == 'B2B') return true;
    return false;
  }

  /// Identifies if this account has Staff / Employee / Admin privileges
  bool get isStaffAccount {
    if (user?.isStaff == true || user?.isSuperuser == true) return true;
    if (jwtClaims['is_staff'] == true || jwtClaims['is_superuser'] == true) return true;
    final uType = resolvedUserType.toUpperCase();
    const staffTypes = [
      'STAFF',
      'ADMIN',
      'MANAGER',
      'EMPLOYEE',
      'EMPLOYEESELFSERVICE',
      'STORE_MANAGER',
      'CASHIER',
      'STOCK_CLERK',
      'DELIVERY_DRIVER',
      'ORDER_PICKER',
    ];
    return staffTypes.contains(uType);
  }

  /// Wholesale account approval status string (e.g. 'approved', 'pending', 'rejected')
  String get wholesaleStatus {
    final jwtStatus = jwtClaims['status']?.toString();
    if (jwtStatus != null && jwtStatus.isNotEmpty) return jwtStatus.toLowerCase();
    if (status != null && status!.isNotEmpty) return status!.toLowerCase();
    if (user?.status != null && user!.status!.isNotEmpty) return user!.status!.toLowerCase();
    return 'approved';
  }

  /// Returns true if wholesale account is approved
  bool get isApprovedWholesale {
    if (jwtClaims['is_approved'] == false) return false;
    final st = wholesaleStatus;
    if (st == 'pending' || st == 'rejected' || st == 'suspended') return false;
    return true;
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
  String? role;
  bool? isWholesale;
  bool? isStaff;
  bool? isSuperuser;
  String? businessName;
  String? status;

  User({
    this.id,
    this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.fullName,
    this.profile,
    this.userType,
    this.role,
    this.isWholesale,
    this.isStaff,
    this.isSuperuser,
    this.businessName,
    this.status,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['user_id'] ?? json['userId'];
    email = json['email'];
    username = json['username'] ?? json['email'];
    firstName = json['firstName'] ?? json['first_name'];
    lastName = json['lastName'] ?? json['last_name'];
    fullName = json['fullName'] ?? json['full_name'] ?? json['name'];
    profile = json['profile'] != null && json['profile'] is Map
        ? Profile.fromJson(Map<String, dynamic>.from(json['profile']))
        : null;
    userType = json['user_type'] ?? json['userType'] ?? json['role'];
    role = json['role']?.toString();
    isWholesale = json['is_wholesale'] ?? json['isWholesale'];
    isStaff = json['is_staff'] ?? json['isStaff'];
    isSuperuser = json['is_superuser'] ?? json['isSuperuser'];
    businessName = json['business_name'] ?? json['businessName'];
    status = json['status']?.toString();
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
    data['role'] = role;
    data['is_wholesale'] = isWholesale;
    data['is_staff'] = isStaff;
    data['is_superuser'] = isSuperuser;
    data['business_name'] = businessName;
    data['status'] = status;
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

  Profile({
    this.resolvedAvatar,
    this.phone,
    this.bio,
    this.notifOrderUpdates,
    this.notifPromotions,
    this.notifPriceChanges,
    this.notifLeftoverPacks,
  });

  Profile.fromJson(Map<String, dynamic> json) {
    resolvedAvatar = json['resolvedAvatar'] ?? json['avatar'];
    phone = json['phone'];
    bio = json['bio'];
    notifOrderUpdates = json['notifOrderUpdates'] ?? json['notif_order_updates'];
    notifPromotions = json['notifPromotions'] ?? json['notif_promotions'];
    notifPriceChanges = json['notifPriceChanges'] ?? json['notif_price_changes'];
    notifLeftoverPacks = json['notifLeftoverPacks'] ?? json['notif_leftover_packs'];
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
