class UpdateProductDto {
  final String product_id;
  final String product_name;
  final String? product_imgUrl;
  final int? stock;
  final int? discount;
  final double price;

  UpdateProductDto({
    required this.product_id,
    required this.product_name,
    this.product_imgUrl,
    this.stock,
    this.discount,
    required this.price,
  });

  factory UpdateProductDto.fromJson(Map<String, dynamic> json) {
    return UpdateProductDto(
      product_id: json['product_id'] as String,
      product_name: json['product_name'] as String,
      product_imgUrl: json['product_imgUrl'] as String,
      stock: json['stock'] as int,
      discount: json['discount'] as int,
      price: json['price'] as double,
    );
  }
}
