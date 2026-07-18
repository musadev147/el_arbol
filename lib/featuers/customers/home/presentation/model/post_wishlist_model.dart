class PostCreateWishlistModel {
  int? id;
  Product? product;
  String? createdAt;

  PostCreateWishlistModel({this.id, this.product, this.createdAt});

  PostCreateWishlistModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    product =
    json['product'] != null ? new Product.fromJson(json['product']) : null;
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.product != null) {
      data['product'] = this.product!.toJson();
    }
    data['created_at'] = this.createdAt;
    return data;
  }
}

class Product {
  String? id;
  String? shop;
  List<Stores>? stores;
  String? brand;
  String? name;
  String? slug;
  String? description;
  Category? category;
  Subcategories? subCategory;
  String? shippingCategory;
  String? price;
  String? discountPrice;
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

  Product(
      {this.id,
        this.shop,
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
        this.uUserContext});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    shop = json['shop'];
    if (json['stores'] != null) {
      stores = <Stores>[];
      json['stores'].forEach((v) {
        stores!.add(new Stores.fromJson(v));
      });
    }
    brand = json['brand'];
    name = json['name'];
    slug = json['slug'];
    description = json['description'];
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
    subCategory = json['sub_category'] != null
        ? new Subcategories.fromJson(json['sub_category'])
        : null;
    shippingCategory = json['shipping_category'];
    price = json['price'];
    discountPrice = json['discount_price'];
    taxRate = json['tax_rate'];
    stock = json['stock'];
    isActive = json['is_active'];
    weight = json['weight'];
    length = json['length'];
    width = json['width'];
    height = json['height'];
    thumbnailUrl = json['thumbnail_url'];
    if (json['specifications'] != null) {
      specifications = List<dynamic>.from(json['specifications']);
    }
    if (json['additional_images'] != null) {
      additionalImages = <AdditionalImages>[];
      json['additional_images'].forEach((v) {
        additionalImages!.add(new AdditionalImages.fromJson(v));
      });
    }
    origin = json['origin'];
    unit = json['unit'];
    wholesaleUnit = json['wholesale_unit'];
    badge = json['badge'];
    badgeColor = json['badge_color'];
    variant = json['variant'];
    if (json['colors'] != null) {
      colors = List<dynamic>.from(json['colors']);
    }
    if (json['sizes'] != null) {
      sizes = List<dynamic>.from(json['sizes']);
    }
    if (json['reviews'] != null) {
      reviews = <Reviews>[];
      json['reviews'].forEach((v) {
        reviews!.add(new Reviews.fromJson(v));
      });
    }
    rating = (json['rating'] as num?)?.toDouble();
    reviewCount = json['review_count'];
    userCanReview = json['user_can_review'] != null
        ? new UserCanReview.fromJson(json['user_can_review'])
        : null;
    if (json['store_stocks'] != null) {
      storeStocks = <StoreStocks>[];
      json['store_stocks'].forEach((v) {
        storeStocks!.add(new StoreStocks.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdByName = json['created_by_name'];
    updatedByName = json['updated_by_name'];
    createdByRole = json['created_by_role'];
    updatedByRole = json['updated_by_role'];
    uUserContext = json['_user_context'] != null
        ? new UserContext.fromJson(json['_user_context'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['shop'] = this.shop;
    if (this.stores != null) {
      data['stores'] = this.stores!.map((v) => v.toJson()).toList();
    }
    data['brand'] = this.brand;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['description'] = this.description;
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    if (this.subCategory != null) {
      data['sub_category'] = this.subCategory!.toJson();
    }
    data['shipping_category'] = this.shippingCategory;
    data['price'] = this.price;
    data['discount_price'] = this.discountPrice;
    data['tax_rate'] = this.taxRate;
    data['stock'] = this.stock;
    data['is_active'] = this.isActive;
    data['weight'] = this.weight;
    data['length'] = this.length;
    data['width'] = this.width;
    data['height'] = this.height;
    data['thumbnail_url'] = this.thumbnailUrl;
    if (this.specifications != null) {
      data['specifications'] = this.specifications;
    }
    if (this.additionalImages != null) {
      data['additional_images'] =
          this.additionalImages!.map((v) => v.toJson()).toList();
    }
    data['origin'] = this.origin;
    data['unit'] = this.unit;
    data['wholesale_unit'] = this.wholesaleUnit;
    data['badge'] = this.badge;
    data['badge_color'] = this.badgeColor;
    data['variant'] = this.variant;
    if (this.colors != null) {
      data['colors'] = this.colors;
    }
    if (this.sizes != null) {
      data['sizes'] = this.sizes;
    }
    if (this.reviews != null) {
      data['reviews'] = this.reviews!.map((v) => v.toJson()).toList();
    }
    data['rating'] = this.rating;
    data['review_count'] = this.reviewCount;
    if (this.userCanReview != null) {
      data['user_can_review'] = this.userCanReview!.toJson();
    }
    if (this.storeStocks != null) {
      data['store_stocks'] = this.storeStocks!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['created_by_name'] = this.createdByName;
    data['updated_by_name'] = this.updatedByName;
    data['created_by_role'] = this.createdByRole;
    data['updated_by_role'] = this.updatedByRole;
    if (this.uUserContext != null) {
      data['_user_context'] = this.uUserContext!.toJson();
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
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
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

  Category(
      {this.id,
        this.name,
        this.slug,
        this.image,
        this.imageUrl,
        this.subcategories});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    image = json['image'];
    imageUrl = json['image_url'];
    if (json['subcategories'] != null) {
      subcategories = <Subcategories>[];
      json['subcategories'].forEach((v) {
        subcategories!.add(new Subcategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['image'] = this.image;
    data['image_url'] = this.imageUrl;
    if (this.subcategories != null) {
      data['subcategories'] =
          this.subcategories!.map((v) => v.toJson()).toList();
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

  Subcategories(
      {this.id,
        this.name,
        this.slug,
        this.image,
        this.imageUrl,
        this.category,
        this.categoryName,
        this.totalProducts});

  Subcategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    image = json['image'];
    imageUrl = json['image_url'];
    category = json['category'];
    categoryName = json['category_name'];
    totalProducts = json['total_products'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['slug'] = this.slug;
    data['image'] = this.image;
    data['image_url'] = this.imageUrl;
    data['category'] = this.category;
    data['category_name'] = this.categoryName;
    data['total_products'] = this.totalProducts;
    return data;
  }
}

class AdditionalImages {
  int? id;
  String? image;

  AdditionalImages({this.id, this.image});

  AdditionalImages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
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

  Reviews(
      {this.id,
        this.user,
        this.product,
        this.productName,
        this.rating,
        this.comment,
        this.createdAt});

  Reviews.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    product = json['product'];
    productName = json['product_name'];
    rating = (json['rating'] as num?)?.toDouble();
    comment = json['comment'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['product'] = this.product;
    data['product_name'] = this.productName;
    data['rating'] = this.rating;
    data['comment'] = this.comment;
    data['created_at'] = this.createdAt;
    return data;
  }
}

class User {
  String? firstName;
  String? lastName;

  User({this.firstName, this.lastName});

  User.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    return data;
  }
}

class UserCanReview {
  bool? canReview;
  String? message;

  UserCanReview({this.canReview, this.message});

  UserCanReview.fromJson(Map<String, dynamic> json) {
    canReview = json['can_review'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['can_review'] = this.canReview;
    data['message'] = this.message;
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
    id = json['id'];
    store = json['store'];
    storeName = json['store_name'];
    stock = json['stock'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['store'] = this.store;
    data['store_name'] = this.storeName;
    data['stock'] = this.stock;
    return data;
  }
}

class UserContext {
  bool? isWholesaler;
  bool? isApprovedWholesaler;
  String? wholesalerStatus;
  bool? isAdmin;

  UserContext(
      {this.isWholesaler,
        this.isApprovedWholesaler,
        this.wholesalerStatus,
        this.isAdmin});

  UserContext.fromJson(Map<String, dynamic> json) {
    isWholesaler = json['is_wholesaler'];
    isApprovedWholesaler = json['is_approved_wholesaler'];
    wholesalerStatus = json['wholesaler_status'];
    isAdmin = json['is_admin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['is_wholesaler'] = this.isWholesaler;
    data['is_approved_wholesaler'] = this.isApprovedWholesaler;
    data['wholesaler_status'] = this.wholesalerStatus;
    data['is_admin'] = this.isAdmin;
    return data;
  }
}
