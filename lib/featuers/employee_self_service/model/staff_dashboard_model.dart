class StaffDashboardModel {
  StaffProfile? profile;
  List<StaffShift>? shifts;
  List<StaffTask>? tasks;
  List<StaffNotification>? notifications;
  List<ActiveStore>? activeStores;
  dynamic currentActiveShift;
  bool? hasCompletedShiftToday;

  StaffDashboardModel({
    this.profile,
    this.shifts,
    this.tasks,
    this.notifications,
    this.activeStores,
    this.currentActiveShift,
    this.hasCompletedShiftToday,
  });

  StaffDashboardModel.fromJson(Map<String, dynamic> json) {
    profile = json['profile'] != null ? StaffProfile.fromJson(json['profile']) : null;
    if (json['shifts'] != null) {
      shifts = <StaffShift>[];
      json['shifts'].forEach((v) {
        shifts!.add(StaffShift.fromJson(v));
      });
    }
    if (json['tasks'] != null) {
      tasks = <StaffTask>[];
      json['tasks'].forEach((v) {
        tasks!.add(StaffTask.fromJson(v));
      });
    }
    if (json['notifications'] != null) {
      notifications = <StaffNotification>[];
      json['notifications'].forEach((v) {
        notifications!.add(StaffNotification.fromJson(v));
      });
    }
    if (json['active_stores'] != null) {
      activeStores = <ActiveStore>[];
      json['active_stores'].forEach((v) {
        activeStores!.add(ActiveStore.fromJson(v));
      });
    }
    currentActiveShift = json['current_active_shift'];
    hasCompletedShiftToday = json['has_completed_shift_today'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
    if (shifts != null) {
      data['shifts'] = shifts!.map((v) => v.toJson()).toList();
    }
    if (tasks != null) {
      data['tasks'] = tasks!.map((v) => v.toJson()).toList();
    }
    if (notifications != null) {
      data['notifications'] = notifications!.map((v) => v.toJson()).toList();
    }
    if (activeStores != null) {
      data['active_stores'] = activeStores!.map((v) => v.toJson()).toList();
    }
    data['current_active_shift'] = currentActiveShift;
    data['has_completed_shift_today'] = hasCompletedShiftToday;
    return data;
  }
}

class StaffProfile {
  int? id;
  StaffUser? user;
  String? staffId;
  String? role;
  String? phone;
  String? hireDate;
  String? createdAt;
  bool? canCreateOrders;
  bool? canUpdateOrders;
  bool? canDeleteOrders;
  bool? canCreateProducts;
  bool? canUpdateProducts;
  bool? canDeleteProducts;
  String? secretKey;
  String? photo;
  String? storeSlug;
  String? storeName;
  String? activeStoreName;
  bool? isWorking;

  StaffProfile({
    this.id,
    this.user,
    this.staffId,
    this.role,
    this.phone,
    this.hireDate,
    this.createdAt,
    this.canCreateOrders,
    this.canUpdateOrders,
    this.canDeleteOrders,
    this.canCreateProducts,
    this.canUpdateProducts,
    this.canDeleteProducts,
    this.secretKey,
    this.photo,
    this.storeSlug,
    this.storeName,
    this.activeStoreName,
    this.isWorking,
  });

  StaffProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? StaffUser.fromJson(json['user']) : null;
    staffId = json['staff_id'];
    role = json['role'];
    phone = json['phone'];
    hireDate = json['hire_date'];
    createdAt = json['created_at'];
    canCreateOrders = json['can_create_orders'];
    canUpdateOrders = json['can_update_orders'];
    canDeleteOrders = json['can_delete_orders'];
    canCreateProducts = json['can_create_products'];
    canUpdateProducts = json['can_update_products'];
    canDeleteProducts = json['can_delete_products'];
    secretKey = json['secret_key'];
    photo = json['photo'];
    storeSlug = json['store_slug'];
    storeName = json['store_name'];
    activeStoreName = json['active_store_name'];
    isWorking = json['is_working'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['staff_id'] = staffId;
    data['role'] = role;
    data['phone'] = phone;
    data['hire_date'] = hireDate;
    data['created_at'] = createdAt;
    data['can_create_orders'] = canCreateOrders;
    data['can_update_orders'] = canUpdateOrders;
    data['can_delete_orders'] = canDeleteOrders;
    data['can_create_products'] = canCreateProducts;
    data['can_update_products'] = canUpdateProducts;
    data['can_delete_products'] = canDeleteProducts;
    data['secret_key'] = secretKey;
    data['photo'] = photo;
    data['store_slug'] = storeSlug;
    data['store_name'] = storeName;
    data['active_store_name'] = activeStoreName;
    data['is_working'] = isWorking;
    return data;
  }
}

class StaffUser {
  int? id;
  String? name;
  String? email;
  String? userType;
  bool? isActive;
  String? phone;

  StaffUser({
    this.id,
    this.name,
    this.email,
    this.userType,
    this.isActive,
    this.phone,
  });

  StaffUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    userType = json['user_type'];
    isActive = json['is_active'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['user_type'] = userType;
    data['is_active'] = isActive;
    data['phone'] = phone;
    return data;
  }
}

class StaffShift {
  int? id;
  String? storeName;
  String? storeLocation;
  String? storeMapLink;
  String? date;
  String? startTime;
  String? endTime;
  dynamic breakStart;
  dynamic breakEnd;
  int? breakDurationMinutes;
  dynamic location;
  String? status;
  String? createdAt;
  int? staff;
  int? store;

  StaffShift({
    this.id,
    this.storeName,
    this.storeLocation,
    this.storeMapLink,
    this.date,
    this.startTime,
    this.endTime,
    this.breakStart,
    this.breakEnd,
    this.breakDurationMinutes,
    this.location,
    this.status,
    this.createdAt,
    this.staff,
    this.store,
  });

  StaffShift.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeName = json['store_name'];
    storeLocation = json['store_location'];
    storeMapLink = json['store_map_link'];
    date = json['date'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    breakStart = json['break_start'];
    breakEnd = json['break_end'];
    breakDurationMinutes = json['break_duration_minutes'];
    location = json['location'];
    status = json['status'];
    createdAt = json['created_at'];
    staff = json['staff'];
    store = json['store'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['store_name'] = storeName;
    data['store_location'] = storeLocation;
    data['store_map_link'] = storeMapLink;
    data['date'] = date;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['break_start'] = breakStart;
    data['break_end'] = breakEnd;
    data['break_duration_minutes'] = breakDurationMinutes;
    data['location'] = location;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['staff'] = staff;
    data['store'] = store;
    return data;
  }
}

class StaffTask {
  int? id;
  String? title;
  String? description;
  String? status;
  int? progressPercentage;
  String? createdAt;
  String? completedAt;
  String? updatedAt;
  int? staff;

  StaffTask({
    this.id,
    this.title,
    this.description,
    this.status,
    this.progressPercentage,
    this.createdAt,
    this.completedAt,
    this.updatedAt,
    this.staff,
  });

  StaffTask.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    status = json['status'];
    progressPercentage = json['progress_percentage'];
    createdAt = json['created_at'];
    completedAt = json['completed_at'];
    updatedAt = json['updated_at'];
    staff = json['staff'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['status'] = status;
    data['progress_percentage'] = progressPercentage;
    data['created_at'] = createdAt;
    data['completed_at'] = completedAt;
    data['updated_at'] = updatedAt;
    data['staff'] = staff;
    return data;
  }
}

class StaffNotification {
  int? id;
  String? title;
  String? message;
  bool? isRead;
  String? createdAt;
  int? staff;

  StaffNotification({
    this.id,
    this.title,
    this.message,
    this.isRead,
    this.createdAt,
    this.staff,
  });

  StaffNotification.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    message = json['message'];
    isRead = json['is_read'];
    createdAt = json['created_at'];
    staff = json['staff'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['message'] = message;
    data['is_read'] = isRead;
    data['created_at'] = createdAt;
    data['staff'] = staff;
    return data;
  }
}

class ActiveStore {
  int? id;
  String? slug;
  String? name;
  String? shortName;
  String? address;
  String? city;
  String? fullAddress;
  String? phone;
  String? storeCode;
  String? openTime;
  String? closeTime;
  String? hours;
  String? mapLink;
  double? lat;
  double? lng;
  List<String>? features;
  List<dynamic>? availability;
  String? provenance;
  String? image;
  List<dynamic>? leftoverPacks;
  bool? isActive;

  ActiveStore({
    this.id,
    this.slug,
    this.name,
    this.shortName,
    this.address,
    this.city,
    this.fullAddress,
    this.phone,
    this.storeCode,
    this.openTime,
    this.closeTime,
    this.hours,
    this.mapLink,
    this.lat,
    this.lng,
    this.features,
    this.availability,
    this.provenance,
    this.image,
    this.leftoverPacks,
    this.isActive,
  });

  ActiveStore.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    name = json['name'];
    shortName = json['shortName'];
    address = json['address'];
    city = json['city'];
    fullAddress = json['fullAddress'];
    phone = json['phone'];
    storeCode = json['storeCode'];
    openTime = json['openTime'];
    closeTime = json['closeTime'];
    hours = json['hours'];
    mapLink = json['mapLink'];
    lat = json['lat']?.toDouble();
    lng = json['lng']?.toDouble();
    features = json['features']?.cast<String>();
    if (json['availability'] != null) {
      availability = <dynamic>[];
      json['availability'].forEach((v) {
        availability!.add(v);
      });
    }
    provenance = json['provenance'];
    image = json['image'];
    if (json['leftoverPacks'] != null) {
      leftoverPacks = <dynamic>[];
      json['leftoverPacks'].forEach((v) {
        leftoverPacks!.add(v);
      });
    }
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['slug'] = slug;
    data['name'] = name;
    data['shortName'] = shortName;
    data['address'] = address;
    data['city'] = city;
    data['fullAddress'] = fullAddress;
    data['phone'] = phone;
    data['storeCode'] = storeCode;
    data['openTime'] = openTime;
    data['closeTime'] = closeTime;
    data['hours'] = hours;
    data['mapLink'] = mapLink;
    data['lat'] = lat;
    data['lng'] = lng;
    data['features'] = features;
    if (availability != null) {
      data['availability'] = availability!.map((v) => v.toJson()).toList();
    }
    data['provenance'] = provenance;
    data['image'] = image;
    if (leftoverPacks != null) {
      data['leftoverPacks'] = leftoverPacks!.map((v) => v.toJson()).toList();
    }
    data['is_active'] = isActive;
    return data;
  }
}
