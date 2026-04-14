class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String accountNumber;
  final String memberType;
  final String profileImage;
  final bool isActive;
  final DateTime joinedDate;
  final String? sakhiName;
  final String? sakhiPhone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.accountNumber,
    required this.memberType,
    required this.profileImage,
    required this.isActive,
    required this.joinedDate,
    this.sakhiName,
    this.sakhiPhone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Parse Fineract date arrays for activationDate
    DateTime parsedDate = DateTime.now();
    if (json['activationDate'] is List) {
      final rawDate = json['activationDate'] as List;
      if (rawDate.length >= 3) {
        parsedDate = DateTime(rawDate[0], rawDate[1], rawDate[2]);
      }
    } else if (json['activationDate'] != null) {
      parsedDate = DateTime.tryParse(json['activationDate'].toString()) ?? parsedDate;
    }
    
    // Construct profile image URL if imageId is present, else placeholder
    String imageUrl = 'https://ui-avatars.com/api/?name=User&background=random';
    final name = json['displayName']?.toString() ?? json['clientName']?.toString() ?? json['firstname']?.toString() ?? 'Member';
    if (name != 'Member') {
       imageUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random';
    }

    return User(
      id: json['id']?.toString() ?? json['clientId']?.toString() ?? '0',
      name: name,
      email: json['email']?.toString() ?? '',
      phone: json['mobileNo']?.toString() ?? '',
      accountNumber: json['accountNo']?.toString() ?? '',
      memberType: json['status']?['value']?.toString() ?? 'Active',
      profileImage: imageUrl,
      isActive: json['active'] as bool? ?? true,
      joinedDate: parsedDate,
      sakhiName: '',
      sakhiPhone: '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': name,
    'email': email,
    'mobileNo': phone,
    'accountNo': accountNumber,
  };
}
