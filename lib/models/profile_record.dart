enum UserType { professor, tutor, dean }

enum UserGender { masculine, feminine, other }

class ProfileRecord {
  final String name;
  final UserType type;
  final UserGender gender;

  const ProfileRecord({
    required this.name,
    required this.type,
    required this.gender,
  });

  ProfileRecord copyWith({String? name, UserType? type, UserGender? gender}) {
    return ProfileRecord(
      name: name ?? this.name,
      type: type ?? this.type,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type.name,
    'gender': gender.name,
  };

  factory ProfileRecord.fromJson(Map<String, dynamic> json) {
    final type = UserType.values.firstWhere(
      (element) => element.name == json['type'] as String,
    );
    final gender = UserGender.values.firstWhere(
      (element) => element.name == json['gender'] as String,
    );

    return ProfileRecord(
      name: (json['name'] as String?) ?? '',
      type: type,
      gender: gender,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileRecord &&
        other.name == name &&
        other.type == type &&
        other.gender == gender;
  }

  @override
  int get hashCode => Object.hash(name, type, gender);
}
