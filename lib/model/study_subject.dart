class StudySubject {
  const StudySubject({
    required this.id,
    required this.name,
    this.category = 'Tự chọn',
    this.icon = 'book',
    this.color = 0,
  });
  final String id, name, category, icon;
  final int color;
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'icon': icon,
    'color': color,
  };
  factory StudySubject.fromJson(Map<String, dynamic> json) => StudySubject(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String? ?? 'Tự chọn',
    icon: json['icon'] as String? ?? 'book',
    color: json['color'] as int? ?? 0,
  );
  static const presets = [
    StudySubject(
      id: 'math',
      name: 'Toán cao cấp',
      category: 'Môn bắt buộc',
      icon: 'math',
      color: 0,
    ),
    StudySubject(
      id: 'english',
      name: 'Tiếng Anh',
      category: 'Kỹ năng',
      icon: 'language',
      color: 1,
    ),
    StudySubject(
      id: 'python',
      name: 'Lập trình Python',
      category: 'Môn chuyên ngành',
      icon: 'code',
      color: 2,
    ),
    StudySubject(id: 'literature', name: 'Văn học', icon: 'book', color: 3),
    StudySubject(id: 'history', name: 'Lịch sử', icon: 'history', color: 4),
    StudySubject(
      id: 'physics',
      name: 'Vật lý',
      category: 'Môn bắt buộc',
      icon: 'science',
      color: 5,
    ),
    StudySubject(
      id: 'chemistry',
      name: 'Hóa học',
      category: 'Môn bắt buộc',
      icon: 'science',
      color: 6,
    ),
  ];
}
