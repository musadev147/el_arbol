class LeftoverStoreModel {
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
  String? provenance;
  String? image;
  List<LeftoverPack>? leftoverPacks;
  bool? isActive;

  LeftoverStoreModel({
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
    this.provenance,
    this.image,
    this.leftoverPacks,
    this.isActive,
  });

  LeftoverStoreModel.fromJson(Map<String, dynamic> json) {
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
    lat = json['lat'] != null ? double.tryParse(json['lat'].toString()) : null;
    lng = json['lng'] != null ? double.tryParse(json['lng'].toString()) : null;
    if (json['features'] != null) {
      features = List<String>.from(json['features']);
    }
    provenance = json['provenance'];
    image = json['image'];
    if (json['leftoverPacks'] != null) {
      leftoverPacks = <LeftoverPack>[];
      json['leftoverPacks'].forEach((v) {
        leftoverPacks!.add(LeftoverPack.fromJson(v));
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
    if (features != null) {
      data['features'] = features;
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

class LeftoverPack {
  int? id;
  String? name;
  String? description;
  double? originalPrice;
  double? price;
  double? shippingCharge;
  String? shippingCategory;
  String? weight;
  String? packageType;
  String? weightQuantity;
  String? storeSlug;
  String? storeName;
  int? stock;
  String? estimatedDelivery;
  String? image;
  List<dynamic>? gallery;
  double? discountPercentage;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  LeftoverPack({
    this.id,
    this.name,
    this.description,
    this.originalPrice,
    this.price,
    this.shippingCharge,
    this.shippingCategory,
    this.weight,
    this.packageType,
    this.weightQuantity,
    this.storeSlug,
    this.storeName,
    this.stock,
    this.estimatedDelivery,
    this.image,
    this.gallery,
    this.discountPercentage,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  LeftoverPack.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    originalPrice = json['original_price'] != null ? double.tryParse(json['original_price'].toString()) : null;
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : null;
    shippingCharge = json['shipping_charge'] != null ? double.tryParse(json['shipping_charge'].toString()) : null;
    shippingCategory = json['shipping_category'];
    weight = json['weight'];
    packageType = json['package_type'];
    weightQuantity = json['weight_quantity'];
    storeSlug = json['store_slug'];
    storeName = json['store_name'];
    stock = json['stock'];
    estimatedDelivery = json['estimated_delivery'];
    image = json['image'];
    if (json['gallery'] != null) {
      gallery = List<dynamic>.from(json['gallery']);
    }
    discountPercentage = json['discount_percentage'] != null ? double.tryParse(json['discount_percentage'].toString()) : null;
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['original_price'] = originalPrice;
    data['price'] = price;
    data['shipping_charge'] = shippingCharge;
    data['shipping_category'] = shippingCategory;
    data['weight'] = weight;
    data['package_type'] = packageType;
    data['weight_quantity'] = weightQuantity;
    data['store_slug'] = storeSlug;
    data['store_name'] = storeName;
    data['stock'] = stock;
    data['estimated_delivery'] = estimatedDelivery;
    data['image'] = image;
    if (gallery != null) {
      data['gallery'] = gallery;
    }
    data['discount_percentage'] = discountPercentage;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
