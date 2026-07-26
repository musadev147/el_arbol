class GetStaffHistoryModel {
  List<Shifts>? shifts;
  int? totalShifts;
  double? totalHours;

  GetStaffHistoryModel({this.shifts, this.totalShifts, this.totalHours});

  GetStaffHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['shifts'] != null) {
      shifts = <Shifts>[];
      json['shifts'].forEach((v) {
        shifts!.add(Shifts.fromJson(v));
      });
    }
    totalShifts = json['total_shifts'];
    if (json['total_hours'] != null) {
      totalHours = (json['total_hours'] as num).toDouble();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (shifts != null) {
      data['shifts'] = shifts!.map((v) => v.toJson()).toList();
    }
    data['total_shifts'] = totalShifts;
    data['total_hours'] = totalHours;
    return data;
  }
}

class Shifts {
  int? id;
  String? date;
  int? storeId;
  String? storeName;
  String? storeImage;
  String? startTime;
  String? endTime;
  String? status;
  double? hours;

  Shifts({
    this.id,
    this.date,
    this.storeId,
    this.storeName,
    this.storeImage,
    this.startTime,
    this.endTime,
    this.status,
    this.hours,
  });

  Shifts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    storeId = json['store_id'];
    storeName = json['store_name'];
    storeImage = json['store_image'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    status = json['status'];
    if (json['hours'] != null) {
      hours = (json['hours'] as num).toDouble();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['date'] = date;
    data['store_id'] = storeId;
    data['store_name'] = storeName;
    data['store_image'] = storeImage;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['status'] = status;
    data['hours'] = hours;
    return data;
  }
}
