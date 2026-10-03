class Product {
  final String product_id;
  final String product_name;
  final String? product_imgUrl;
  final int? stock;
  final int? discount;
  final double price;

  Product({
    required this.product_id,
    required this.product_name,
    this.product_imgUrl,
    this.stock = 0,
    this.discount = 0,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': product_id,
      'product_name': product_name,
      'product_imgUrl': product_imgUrl,
      'stock': stock,
      'discount': discount,
      'price': price,
    };
  }
}
