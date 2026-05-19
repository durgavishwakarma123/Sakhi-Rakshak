class ContactModel {
  final String name;
  final String phone;

  ContactModel({required this.name, required this.phone});

  Map<String, String> toMap() {
    return {'name': name, 'phone': phone};
  }
}