import 'package:pustakalaya/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    phoneNumber: json['phoneNumber'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
  };
}
