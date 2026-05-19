class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final List<Map<String, String>> trustedContacts;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.trustedContacts,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'trustedContacts': trustedContacts,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      profileImage: map['profileImage'] ?? '',
      trustedContacts: List<Map<String, String>>.from(
        (map['trustedContacts'] ?? []).map(
          (item) => Map<String, String>.from(item),
        ),
      ),
    );
  }
}