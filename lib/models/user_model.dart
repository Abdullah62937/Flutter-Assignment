// lib/models/user_model.dart
import 'enums.dart';

class UserModel {
  final String fullName;
  final String email;
  final Gender gender;

  const UserModel({
    required this.fullName,
    required this.email,
    required this.gender,
  });

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';
  }

  Map<String, String> toMap() => {
        'fullName': fullName,
        'email': email,
        'gender': gender.name,
      };

  factory UserModel.fromMap(Map<String, String> map) => UserModel(
        fullName: map['fullName'] ?? '',
        email: map['email'] ?? '',
        gender: Gender.values.firstWhere(
          (g) => g.name == map['gender'],
          orElse: () => Gender.preferNotToSay,
        ),
      );
}
