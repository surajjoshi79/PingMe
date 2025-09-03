class AiMessage {
  AiMessage({
    required this.msg,
    required this.fromId,
    required this.sent,
  });

  late final String msg;
  late final String fromId;
  late final String sent;

  AiMessage.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    fromId = json['fromId'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['fromId'] = fromId;
    data['sent'] = sent;
    return data;
  }
}