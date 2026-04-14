// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoanAccount _$LoanAccountFromJson(Map<String, dynamic> json) => LoanAccount(
      loanId: json['loanId'] as String,
      accountName: json['accountName'] as String,
      currentBalance: (json['currentBalance'] as num).toDouble(),
      loanAmount: (json['loanAmount'] as num).toDouble(),
      disbursedDate: DateTime.parse(json['disbursedDate'] as String),
      interestRate: (json['interestRate'] as num).toDouble(),
      tenureMonths: (json['tenureMonths'] as num).toInt(),
      expectedEndDate: DateTime.parse(json['expectedEndDate'] as String),
      nextEmiDue: DateTime.parse(json['nextEmiDue'] as String),
      monthlyEmi: (json['monthlyEmi'] as num).toDouble(),
    );

Map<String, dynamic> _$LoanAccountToJson(LoanAccount instance) =>
    <String, dynamic>{
      'loanId': instance.loanId,
      'accountName': instance.accountName,
      'currentBalance': instance.currentBalance,
      'loanAmount': instance.loanAmount,
      'disbursedDate': instance.disbursedDate.toIso8601String(),
      'interestRate': instance.interestRate,
      'tenureMonths': instance.tenureMonths,
      'expectedEndDate': instance.expectedEndDate.toIso8601String(),
      'nextEmiDue': instance.nextEmiDue.toIso8601String(),
      'monthlyEmi': instance.monthlyEmi,
    };
