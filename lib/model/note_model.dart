class Note {
  final int id;
  final String description;
  Note({
    required this.id,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'description': description,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int,
      description: map['description'] as String,
    );
  }
}
