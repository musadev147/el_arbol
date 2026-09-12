class PostCreateWishlistModel {
  int? id;
  Product? product;
  String? createdAt;

  PostCreateWishlistModel({this.id, this.product, this.createdAt});

  PostCreateWishlistModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    product = json['product'] != null && json['product'] is Map
        ? Product.fromJson(Map<String, dynamic>.from(json['product']))
        : null;
    createdAt = json['created_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    data['created_at'] = createdAt;
    return data;
  }
}

class Product {
  String? id;
  dynamic shop;
  String? shopName;
  List<Stores>? stores;
  dynamic brand;
  String? name;
  String? slug;
  String? description;
  Category? category;
  Subcategories? subCategory;
  dynamic shippingCategory;
  String? price;
  String? discountPrice;
  String? wholesalePrice;
  String? taxRate;
  int? stock;
  bool? isActive;
  String? weight;
  String? length;
  String? width;
  String? height;
  String? thumbnailUrl;
  List<dynamic>? specifications;
  List<AdditionalImages>? additionalImages;
  String? origin;
  String? unit;
  String? wholesaleUnit;
  String? badge;
  String? badgeColor;
  String? variant;
  List<dynamic>? colors;
  List<dynamic>? sizes;
  List<Reviews>? reviews;
  double? rating;
  int? reviewCount;
  UserCanReview? userCanReview;
  List<StoreStocks>? storeStocks;
  String? createdAt;
  String? updatedAt;
  String? createdByName;
  String? updatedByName;
  String? createdByRole;
  String? updatedByRole;
  UserContext? uUserContext;

  Product({
    this.id,
    this.shop,
    this.shopName,
    this.stores,
    this.brand,
    this.name,
    this.slug,
    this.description,
    this.category,
    this.subCategory,
    this.shippingCategory,
    this.price,
    this.discountPrice,
    this.wholesalePrice,
    this.taxRate,
    this.stock,
    this.isActive,
    this.weight,
    this.length,
    this.width,
    this.height,
    this.thumbnailUrl,
    this.specifications,
    this.additionalImages,
    this.origin,
    this.unit,
    this.wholesaleUnit,
    this.badge,
    this.badgeColor,
    this.variant,
    this.colors,
    this.sizes,
    this.reviews,
    this.rating,
    this.reviewCount,
    this.userCanReview,
    this.storeStocks,
    this.createdAt,
    this.updatedAt,
    this.createdByName,
    this.updatedByName,
    this.createdByRole,
    this.updatedByRole,
    this.uUserContext,
  });

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    shop = json['shop'];
    if (json['shop'] is Map) {
      shopName = json['shop']['name']?.toString();
    } else {
      shopName = json['shop']?.toString();
    }

    if (json['stores'] != null && json['stores'] is List) {
      stores = <Stores>[];
      for (var v in (json['stores'] as List)) {
        if (v is Map) {
          stores!.add(Stores.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }

    brand = json['brand'];
    name = json['name']?.toString();
    slug = json['slug']?.toString();
    description = json['description']?.toString();
    
    if (json['category'] != null && json['category'] is Map) {
      category = Category.fromJson(Map<String, dynamic>.from(json['category']));
    }
    
    if (json['sub_category'] != null && json['sub_category'] is Map) {
      subCategory = Subcategories.fromJson(Map<String, dynamic>.from(json['sub_category']));
    }

    shippingCategory = json['shipping_category'];
    price = json['price']?.toString();
    discountPrice = json['discount_price']?.toString();
    wholesalePrice = json['wholesale_price']?.toString();
    taxRate = json['tax_rate']?.toString();
    
    if (json['stock'] != null) {
      stock = json['stock'] is int ? json['stock'] : int.tryParse(json['stock'].toString());
    }

    isActive = json['is_active'];
    weight = json['weight']?.toString();
    length = json['length']?.toString();
    width = json['width']?.toString();
    height = json['height']?.toString();
    thumbnailUrl = json['thumbnail_url']?.toString();

    if (json['specifications'] != null && json['specifications'] is List) {
      specifications = List<dynamic>.from(json['specifications']);
    }

    if (json['additional_images'] != null && json['additional_images'] is List) {
      additionalImages = <AdditionalImages>[];
      for (var v in (json['additional_images'] as List)) {
        if (v is Map) {
          additionalImages!.add(AdditionalImages.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }

    origin = json['origin']?.toString();
    unit = json['unit']?.toString();
    wholesaleUnit = json['wholesale_unit']?.toString();
    badge = json['badge']?.toString();
    badgeColor = json['badge_color']?.toString();
    variant = json['variant']?.toString();

    if (json['colors'] != null && json['colors'] is List) {
      colors = List<dynamic>.from(json['colors']);
    }
    if (json['sizes'] != null && json['sizes'] is List) {
      sizes = List<dynamic>.from(json['sizes']);
    }

    if (json['reviews'] != null && json['reviews'] is List) {
      reviews = <Reviews>[];
      for (var v in (json['reviews'] as List)) {
        if (v is Map) {
          reviews!.add(Reviews.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }

    if (json['rating'] != null) {
      rating = (json['rating'] as num?)?.toDouble() ?? double.tryParse(json['rating'].toString());
    } else {
      rating = 0.0;
    }

    if (json['review_count'] != null) {
      reviewCount = json['review_count'] is int
          ? json['review_count']
          : int.tryParse(json['review_count'].toString());
    }

    if (json['user_can_review'] != null && json['user_can_review'] is Map) {
      userCanReview = UserCanReview.fromJson(Map<String, dynamic>.from(json['user_can_review']));
    }

    if (json['store_stocks'] != null && json['store_stocks'] is List) {
      storeStocks = <StoreStocks>[];
      for (var v in (json['store_stocks'] as List)) {
        if (v is Map) {
          storeStocks!.add(StoreStocks.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }

    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    createdByName = json['created_by_name']?.toString();
    updatedByName = json['updated_by_name']?.toString();
    createdByRole = json['created_by_role']?.toString();
    updatedByRole = json['updated_by_role']?.toString();

    if (json['_user_context'] != null && json['_user_context'] is Map) {
      uUserContext = UserContext.fromJson(Map<String, dynamic>.from(json['_user_context']));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['shop'] = shop;
    if (stores != null) {
      data['stores'] = stores!.map((v) => v.toJson()).toList();
    }
    data['brand'] = brand;
    data['name'] = name;
    data['slug'] = slug;
    data['description'] = description;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (subCategory != null) {
      data['sub_category'] = subCategory!.toJson();
    }
    data['shipping_category'] = shippingCategory;
    data['price'] = price;
    data['discount_price'] = discountPrice;
    data['tax_rate'] = taxRate;
    data['stock'] = stock;
    data['is_active'] = isActive;
    data['weight'] = weight;
    data['length'] = length;
    data['width'] = width;
    data['height'] = height;
    data['thumbnail_url'] = thumbnailUrl;
    if (specifications != null) {
      data['specifications'] = specifications;
    }
    if (additionalImages != null) {
      data['additional_images'] = additionalImages!.map((v) => v.toJson()).toList();
    }
    data['origin'] = origin;
    data['unit'] = unit;
    data['wholesale_unit'] = wholesaleUnit;
    data['badge'] = badge;
    data['badge_color'] = badgeColor;
    data['variant'] = variant;
    if (colors != null) {
      data['colors'] = colors;
    }
    if (sizes != null) {
      data['sizes'] = sizes;
    }
    if (reviews != null) {
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    data['rating'] = rating;
    data['review_count'] = reviewCount;
    if (userCanReview != null) {
      data['user_can_review'] = userCanReview!.toJson();
    }
    if (storeStocks != null) {
      data['store_stocks'] = storeStocks!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by_name'] = createdByName;
    data['updated_by_name'] = updatedByName;
    data['created_by_role'] = createdByRole;
    data['updated_by_role'] = updatedByRole;
    if (uUserContext != null) {
      data['_user_context'] = uUserContext!.toJson();
    }
    return data;
  }
}

class Stores {
  int? id;
  String? name;
  String? slug;

  Stores({this.id, this.name, this.slug});

  Stores.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString();
    slug = json['slug']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    return data;
  }
}

class Category {
  int? id;
  String? name;
  String? slug;
  String? image;
  String? imageUrl;
  List<Subcategories>? subcategories;

  Category({
    this.id,
    this.name,
    this.slug,
    this.image,
    this.imageUrl,
    this.subcategories,
  });

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString();
    slug = json['slug']?.toString();
    image = json['image']?.toString();
    imageUrl = json['image_url']?.toString();
    if (json['subcategories'] != null && json['subcategories'] is List) {
      subcategories = <Subcategories>[];
      for (var v in (json['subcategories'] as List)) {
        if (v is Map) {
          subcategories!.add(Subcategories.fromJson(Map<String, dynamic>.from(v)));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['image'] = image;
    data['image_url'] = imageUrl;
    if (subcategories != null) {
      data['subcategories'] = subcategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Subcategories {
  int? id;
  String? name;
  String? slug;
  String? image;
  String? imageUrl;
  int? category;
  String? categoryName;
  int? totalProducts;

  Subcategories({
    this.id,
    this.name,
    this.slug,
    this.image,
    this.imageUrl,
    this.category,
    this.categoryName,
    this.totalProducts,
  });

  Subcategories.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    name = json['name']?.toString();
    slug = json['slug']?.toString();
    image = json['image']?.toString();
    imageUrl = json['image_url']?.toString();
    category = json['category'] is int ? json['category'] : int.tryParse(json['category']?.toString() ?? '');
    categoryName = json['category_name']?.toString();
    totalProducts = json['total_products'] is int ? json['total_products'] : int.tryParse(json['total_products']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['image'] = image;
    data['image_url'] = imageUrl;
    data['category'] = category;
    data['category_name'] = categoryName;
    data['total_products'] = totalProducts;
    return data;
  }
}

class AdditionalImages {
  int? id;
  String? image;

  AdditionalImages({this.id, this.image});

  AdditionalImages.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    image = json['image']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    return data;
  }
}

class Reviews {
  int? id;
  User? user;
  String? product;
  String? productName;
  double? rating;
  String? comment;
  String? createdAt;

  Reviews({
    this.id,
    this.user,
    this.product,
    this.productName,
    this.rating,
    this.comment,
    this.createdAt,
  });

  Reviews.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    user = json['user'] != null && json['user'] is Map ? User.fromJson(Map<String, dynamic>.from(json['user'])) : null;
    product = json['product']?.toString();
    productName = json['product_name']?.toString();
    rating = (json['rating'] as num?)?.toDouble() ?? double.tryParse(json['rating']?.toString() ?? '0');
    comment = json['comment']?.toString();
    createdAt = json['created_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['product'] = product;
    data['product_name'] = productName;
    data['rating'] = rating;
    data['comment'] = comment;
    data['created_at'] = createdAt;
    return data;
  }
}

class User {
  String? firstName;
  String? lastName;

  User({this.firstName, this.lastName});

  User.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name']?.toString();
    lastName = json['last_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    return data;
  }
}

class UserCanReview {
  bool? canReview;
  String? message;

  UserCanReview({this.canReview, this.message});

  UserCanReview.fromJson(Map<String, dynamic> json) {
    canReview = json['can_review'];
    message = json['message']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['can_review'] = canReview;
    data['message'] = message;
    return data;
  }
}

class StoreStocks {
  int? id;
  int? store;
  String? storeName;
  int? stock;

  StoreStocks({this.id, this.store, this.storeName, this.stock});

  StoreStocks.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '');
    store = json['store'] is int ? json['store'] : int.tryParse(json['store']?.toString() ?? '');
    storeName = json['store_name']?.toString();
    stock = json['stock'] is int ? json['stock'] : int.tryParse(json['stock']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['store'] = store;
    data['store_name'] = storeName;
    data['stock'] = stock;
    return data;
  }
}

class UserContext {
  bool? isWholesaler;
  bool? isApprovedWholesaler;
  String? wholesalerStatus;
  bool? isAdmin;

  UserContext({
    this.isWholesaler,
    this.isApprovedWholesaler,
    this.wholesalerStatus,
    this.isAdmin,
  });

  UserContext.fromJson(Map<String, dynamic> json) {
    isWholesaler = json['is_wholesaler'];
    isApprovedWholesaler = json['is_approved_wholesaler'];
    wholesalerStatus = json['wholesaler_status']?.toString();
    isAdmin = json['is_admin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_wholesaler'] = isWholesaler;
    data['is_approved_wholesaler'] = isApprovedWholesaler;
    data['wholesaler_status'] = wholesalerStatus;
    data['is_admin'] = isAdmin;
    return data;
  }
}
