// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      accountNumber: json['accountNumber'] as String,
      memberType: json['memberType'] as String,
      profileImage: json['profileImage'] as String,
      isActive: json['isActive'] as bool,
      joinedDate: DateTime.parse(json['joinedDate'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'accountNumber': instance.accountNumber,
      'memberType': instance.memberType,
      'profileImage': instance.profileImage,
      'isActive': instance.isActive,
      'joinedDate': instance.joinedDate.toIso8601String(),
    };
