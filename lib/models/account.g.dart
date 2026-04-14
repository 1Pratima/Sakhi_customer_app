// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SavingsAccount _$SavingsAccountFromJson(Map<String, dynamic> json) =>
    SavingsAccount(
      accountId: json['accountId'] as String,
      accountName: json['accountName'] as String,
      totalSavings: (json['totalSavings'] as num).toDouble(),
      yourSavings: (json['yourSavings'] as num).toDouble(),
      lastDeposit: DateTime.parse(json['lastDeposit'] as String),
      averageDeposit: (json['averageDeposit'] as num).toDouble(),
      deposits: (json['deposits'] as List<dynamic>)
          .map((e) => Deposit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SavingsAccountToJson(SavingsAccount instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'accountName': instance.accountName,
      'totalSavings': instance.totalSavings,
      'yourSavings': instance.yourSavings,
      'lastDeposit': instance.lastDeposit.toIso8601String(),
      'averageDeposit': instance.averageDeposit,
      'deposits': instance.deposits,
    };

Deposit _$DepositFromJson(Map<String, dynamic> json) => Deposit(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$DepositToJson(Deposit instance) => <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'description': instance.description,
    };
