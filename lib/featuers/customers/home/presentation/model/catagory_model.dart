class GetCategoryModel {
  int? id;
  String? name;
  String? slug;
  String? image;
  String? imageUrl;
  List<Subcategories>? subcategories;
  int? totalProducts;
  int? subCategoryCount;

  GetCategoryModel(
      {this.id,
        this.name,
        this.slug,
        this.image,
        this.imageUrl,
        this.subcategories,
        this.totalProducts,
        this.subCategoryCount});

  GetCategoryModel.fromJson(Map<String, dynamic> json) {
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
    totalProducts = json['total_products'];
    subCategoryCount = json['sub_category_count'];
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
    data['total_products'] = this.totalProducts;
    data['sub_category_count'] = this.subCategoryCount;
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
