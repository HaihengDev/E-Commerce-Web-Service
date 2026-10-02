class CreateProductDto {
  final String product_id;
  final String product_name;
  final String? product_imgUrl;
  final int? stock;
  final int? discount;
  final double price;

  CreateProductDto({
    required this.product_id,
    required this.product_name,
    this.product_imgUrl,
    this.stock = 0,
    this.discount = 0,
    required this.price,
  });
}
