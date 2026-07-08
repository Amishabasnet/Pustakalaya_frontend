import 'package:pustakalaya/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phoneNumber,
    super.username,
    super.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    fullName: (json['fullName'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    phoneNumber: (json['phoneNumber'] ?? '').toString(),
    username: json['username'] as String?,
    address: json['address'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'username': username,
    'address': address,
  };
}
