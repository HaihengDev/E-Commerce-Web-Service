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
    // MongoDB records created by older versions may contain an ObjectId here.
    // Convert it to a stable string before returning it or embedding it in JWTs.
    id: (document['user_id'] ?? document['_id']).toString(),
    email: document['email'].toString(),
    name: document['name'].toString(),
    role: document['role'].toString(),
  );
}
