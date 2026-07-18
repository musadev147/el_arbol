import 'get_product_model.dart';

/// Robust model to represent category data from the API (both paginated and list format).
class GetCategoryModel {
  int? count;
  List<Category>? results;

  GetCategoryModel({this.count, this.results});

  GetCategoryModel.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      count = json['count'] as int?;
      if (json['results'] != null) {
        results = <Category>[];
        json['results'].forEach((v) {
          results!.add(Category.fromJson(v));
        });
      }
    } else if (json is List) {
      results = <Category>[];
      for (var v in json) {
        if (v is Map<String, dynamic>) {
          results!.add(Category.fromJson(v));
        }
      }
      count = results!.length;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
