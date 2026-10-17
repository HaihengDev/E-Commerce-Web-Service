String generateId(String prefix, int number) {
  return '$prefix${number.toString().padLeft(4, '0')}';
}
