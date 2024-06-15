class Message {
  final bool isSelf;
  final String message;
  // final Timestamp timestamp;
  final String timestamp;

  Message(
      {required this.isSelf, required this.message, required this.timestamp});

  Map<String, dynamic> toMap() {
    return {'isSelf': isSelf, 'message': message, 'timestamp': timestamp};
  }
}
