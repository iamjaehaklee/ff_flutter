class Thread {
  final String id;
  final String parentMessageId;
  final String threadContent;
  final String? latestReplyContent;
  final String? latestReplySenderId;
  final DateTime? latestReplyUpdatedAt;
  final int threadCount;

  Thread({
    required this.id,
    required this.parentMessageId,
    required this.threadContent,
    this.latestReplyContent,
    this.latestReplySenderId,
    this.latestReplyUpdatedAt,
    required this.threadCount,
  });

  // Factory constructor to parse JSON data into a Thread object
  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'],
      parentMessageId: json['parent_message_id'],
      threadContent: json['thread_content'],
      latestReplyContent: json['latest_reply_content'],
      latestReplySenderId: json['latest_reply_sender_id'],
      latestReplyUpdatedAt: json['latest_reply_updated_at'] != null
          ? DateTime.parse(json['latest_reply_updated_at'])
          : null,
      threadCount: json['thread_count'],
    );
  }

  // Convert Thread object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_message_id': parentMessageId,
      'thread_content': threadContent,
      'latest_reply_content': latestReplyContent,
      'latest_reply_sender_id': latestReplySenderId,
      'latest_reply_updated_at':
      latestReplyUpdatedAt?.toIso8601String(),
      'thread_count': threadCount,
    };
  }
}
