class Product {
  final String product_id;
  final String product_name;
  final String? imgUrl;
  final int? stock;
  final int? discount;
  final double price;
  final String description;
  final String category;

  const Product({
    required this.product_id,
    required this.product_name,
    this.imgUrl,
    this.stock = 0,
    this.discount = 0,
    required this.price,
    required this.description,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': product_id,
      'product_name': product_name,
      'imgUrl': imgUrl,
      'stock': stock,
      'discount': discount,
      'price': price,
      'description': description,
      'category': category,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      product_id: json['product_id'] as String,
      product_name: json['product_name'] as String,
      imgUrl: json['imgUrl'] as String,
      stock: json['stock'] as int,
      discount: json['discount'] as int,
      price: json['price'] as double,
      description: json['description'] as String,
      category: json['category'] as String,
    );
  }
}
