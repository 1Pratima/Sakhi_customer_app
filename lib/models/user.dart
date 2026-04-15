class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String accountNumber;
  final String memberType;
  final String profileImage;
  final String? base64Image;
  final bool isActive;
  final DateTime joinedDate;
  final String? sakhiName;
  final String? sakhiPhone;
  final String? sakhiId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.accountNumber,
    required this.memberType,
    required this.profileImage,
    this.base64Image,
    required this.isActive,
    required this.joinedDate,
    this.sakhiName,
    this.sakhiPhone,
    this.sakhiId,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? base64Image}) {
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
    
    // Construct profile image URL if no base64Image
    String imageUrl = 'https://ui-avatars.com/api/?name=User&background=random';
    final name = json['displayName']?.toString() ?? json['clientName']?.toString() ?? json['firstname']?.toString() ?? 'Member';
    if (name != 'Member') {
       imageUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random';
    }

    // Extract Sakhi details from root if assigned, otherwise fallback to timeline admin
    final directStaffId = json['staffId']?.toString();
    final directStaffName = json['staffName']?.toString();
    
    final timeline = json['timeline'] as Map<String, dynamic>?;
    final sFirstName = timeline?['activatedByFirstname']?.toString() ?? '';
    final sLastName = timeline?['activatedByLastname']?.toString() ?? '';
    final fullSakhiName = directStaffName ?? '$sFirstName $sLastName'.trim();
    final sakhiId = directStaffId ?? timeline?['activatedByUsername']?.toString();

    return User(
      id: json['id']?.toString() ?? json['clientId']?.toString() ?? '0',
      name: name,
      email: json['email']?.toString() ?? '',
      phone: json['mobileNo']?.toString() ?? '',
      accountNumber: json['accountNo']?.toString() ?? '',
      memberType: json['status']?['value']?.toString() ?? 'Active',
      profileImage: imageUrl,
      base64Image: base64Image,
      isActive: json['active'] as bool? ?? true,
      joinedDate: parsedDate,
      sakhiName: fullSakhiName.isNotEmpty ? fullSakhiName : null,
      sakhiPhone: '', // Will be fetched via separate API if needed
      sakhiId: sakhiId,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? accountNumber,
    String? memberType,
    String? profileImage,
    String? base64Image,
    bool? isActive,
    DateTime? joinedDate,
    String? sakhiName,
    String? sakhiPhone,
    String? sakhiId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      accountNumber: accountNumber ?? this.accountNumber,
      memberType: memberType ?? this.memberType,
      profileImage: profileImage ?? this.profileImage,
      base64Image: base64Image ?? this.base64Image,
      isActive: isActive ?? this.isActive,
      joinedDate: joinedDate ?? this.joinedDate,
      sakhiName: sakhiName ?? this.sakhiName,
      sakhiPhone: sakhiPhone ?? this.sakhiPhone,
      sakhiId: sakhiId ?? this.sakhiId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': name,
    'email': email,
    'mobileNo': phone,
    'accountNo': accountNumber,
    'sakhiName': sakhiName,
    'sakhiId': sakhiId,
  };
}
