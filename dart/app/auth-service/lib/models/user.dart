class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  final String id;
  final String email;
  final String name;
  final String role;

  Map<String, dynamic> toPublicJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
  };

  factory AppUser.fromDocument(Map<String, dynamic> document) => AppUser(
    id: document['user_id'] as String,
    email: document['email'] as String,
    name: document['name'] as String,
    role: document['role'] as String,
  );
}
