class FailureSectionArguments {
  int unit;
  bool showDelayedTeachers;

  FailureSectionArguments({
    required this.unit,
    required this.showDelayedTeachers,
  });

  static FailureSectionArguments fromJson(Map<String, dynamic> map) {
    return FailureSectionArguments(
      unit: map['unit'] as int,
      showDelayedTeachers: map['show_delayed_teachers'] as bool,
    );
  }

  FailureSectionArguments copyWith({int? unit, bool? showDelayedTeachers}) {
    return FailureSectionArguments(
      unit: unit ?? this.unit,
      showDelayedTeachers: showDelayedTeachers ?? this.showDelayedTeachers,
    );
  }

  Map<String, dynamic> toJson() {
    return {'unit': unit, 'show_delayed_teachers': showDelayedTeachers};
  }
}
