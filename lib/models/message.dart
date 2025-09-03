class Message {
  Message({
    required this.toId,
    required this.msg,
    required this.read,
    required this.type,
    required this.fromId,
    required this.sent,
  });

  late final String toId;
  late final String msg;
  late final String read;
  late final String fromId;
  late final String sent;
  late final Type type;

  Type getType(Map<String, dynamic> json){
    if(json['type'].toString() == Type.image.name){
      return Type.image;
    }
    else if(json['type'].toString() == Type.document.name){
      return Type.document;
    }
    else if(json['type'].toString() == Type.audio.name){
      return Type.audio;
    }
    return Type.text;
  }

  Message.fromJson(Map<String, dynamic> json) {
    toId = json['toId'].toString();
    msg = json['msg'].toString();
    read = json['read'].toString();
    type = getType(json);
    fromId = json['fromId'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toId'] = toId;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type.name;
    data['fromId'] = fromId;
    data['sent'] = sent;
    return data;
  }
}

enum Type {
  text,
  image,
  document,
  audio
}
