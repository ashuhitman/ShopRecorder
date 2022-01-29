class PartItem {
  static final String columnId = '_id';
  static final columnPartName = 'partname';
  static final columnItemName = 'itemname';
  static final columnPrice = 'price';

  final int? id;
  final String partName;
  final int? price;
  final String? itemName;
  PartItem(
      {this.id,
      required this.partName,
      required this.price,
      required this.itemName});
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map[columnId] = id;
    }

    map[columnPartName] = partName;
    map[columnItemName] = itemName;
    map[columnPrice] = price;

    return map;
  }

  static PartItem fromMap(Map<String, dynamic> map) {
    return PartItem(
      id: map[columnId] as int?,
      partName: map[columnPartName] as String,
      price: map[columnPrice] as int,
      itemName: map[columnItemName] as String,
    );
  }

  PartItem copy({
    int? id,
    String? partName,
    String? itemName,
    int? price,
  }) {
    return PartItem(
      id: id ?? this.id,
      partName: partName ?? this.partName,
      itemName: itemName ?? this.itemName,
      price: price ?? this.price,
    );
  }
}
