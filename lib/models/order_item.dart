class OrderItem {
  String name;
  int quantity;
  double pricePerUnit;

  OrderItem({
    required this.name,
    this.quantity = 1,
    required this.pricePerUnit,
  });

  double get totalPrice => quantity * pricePerUnit;

  OrderItem copyWith({String? name, int? quantity, double? pricePerUnit}) {
    return OrderItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
    );
  }
}
