import 'package:equatable/equatable.dart';
import 'package:shop_record/utils/db_provider.dart';

class MobilePart extends Equatable {
  final int? id;
  final String partName;
  final String iconName;

  MobilePart({this.id, required this.partName, required this.iconName});

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map[DBProvider.columnId] = id;
    }

    map[DBProvider.coulmnPartName] = partName;
    map[DBProvider.columnIconName] = iconName;
    return map;
  }

  static MobilePart fromMap(Map<String, dynamic> map) {
    return MobilePart(
      id: map[DBProvider.columnId] as int?,
      partName: map[DBProvider.coulmnPartName] as String,
      iconName: map[DBProvider.columnIconName] as String,
    );
  }

  MobilePart copy({
    int? id,
    String? partName,
    String? iconName,
  }) {
    return MobilePart(
      id: id ?? this.id,
      partName: partName ?? this.partName,
      iconName: iconName ?? this.iconName,
    );
  }

  @override
  List<Object?> get props => [this.id, this.partName, this.iconName];
}
