import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat_app/models/ai_message.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/secret.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as https;
import 'notification_access_token.dart';
import 'package:encrypt/encrypt.dart';

class APIs{
  static FirebaseAuth auth=FirebaseAuth.instance;
  static FirebaseFirestore firestore=FirebaseFirestore.instance;
  static FirebaseMessaging firebaseMessaging=FirebaseMessaging.instance;
  static late ChatUser me;
  static final encrypted=Encrypter(AES(Secret.key, mode: AESMode.cbc));

  static Future<bool> userExist() async{
    return (await firestore.collection('users').doc(auth.currentUser!.uid).get()).exists;
  }

  static Future<bool> myUserExist(String email) async{
    final data=await firestore.collection('users').where('email',isEqualTo: email).get();
    if(data.docs.isNotEmpty && data.docs.first.id!=auth.currentUser!.uid){
      firestore.collection('users').doc(auth.currentUser!.uid).collection('my_users').doc(data.docs.first.id).set({});
      firestore.collection('users').doc(data.docs.first.id).collection('my_users').doc(auth.currentUser!.uid).set({});
      return Future.value(true);
    }
    return Future.value(false);
  }
  
  static Future<void> getFirebaseMessagingToken() async{
    await firebaseMessaging.requestPermission();
    firebaseMessaging.getToken().then((t){
      if(t!=null){
        me.pushToken=t;
      }
    });
  }

  static Future<void> pushNotification(ChatUser receiver,String msg) async{
    try{
      final body={
        "message": {
          "token": receiver.pushToken,
          "notification": {
            "title": me.name,
            "body": msg,
            "android_channel_id":'chats'
          }
        }
      };
      const projectId='pingme-409d8';
      final bearerToken=await NotificationAccessToken.getToken;
      if(bearerToken==null) return;
      await https.post(Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $bearerToken'
        },
        body: jsonEncode(body)
      );
    }catch(e){
      log('Push notification Exception:$e');
    }
  }

  static Future<void> getSelfInfo() async{
    await firestore.collection('users').doc(auth.currentUser!.uid).get().then((user) async{
      if(user.exists){
        me=ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken().then((_)async => await updateOnlineStatus(true));
      }else{
        await createUser().then((value){
          getSelfInfo();
        });
      }
    });
  }

  static Future<void> createUser() async{
    if(!(await userExist())){
      final time=DateTime.now().microsecondsSinceEpoch.toString();
      final user=ChatUser(
          image: auth.currentUser!.photoURL.toString(),
          about: 'Hey I am using PingMe',
          name: auth.currentUser!.displayName.toString(),
          createdAt: time,
          isOnline: false,
          id: auth.currentUser!.uid,
          lastActive: '',
          email: auth.currentUser!.email.toString(),
          pushToken: '',
          isLocked: false
      );
      await firestore.collection('users').doc(auth.currentUser!.uid).set(user.toJson());
    }
  }

  static Future<void> updateUserInfo() async{
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      'name':me.name,
      'about':me.about,
      'image':me.image
    });
  }

  static String getConversationId(String id) =>
      auth.currentUser!.uid.hashCode >= id.hashCode ?
      '${auth.currentUser!.uid}_$id' :
      '${id}_${auth.currentUser!.uid}';

  static Future<void> sendMessage(ChatUser receiver,String msg) async{
    String time=DateTime.now().millisecondsSinceEpoch.toString();
    Message message=Message(
        toId: receiver.id,
        msg: encrypted.encrypt(msg, iv:Secret.iv).base64,
        read: '',
        type: Type.text,
        fromId: auth.currentUser!.uid,
        sent: time
    );
    await firestore.collection('chats/${getConversationId(receiver.id)}/messages/').doc(time).set(message.toJson()).then((_){
      pushNotification(receiver, msg);
    });
  }

  static Future<void> sendImage(ChatUser receiver,String imageUrl) async{
    String time=DateTime.now().millisecondsSinceEpoch.toString();
    Message message=Message(
        toId: receiver.id,
        msg: imageUrl,
        read: '',
        type: Type.image,
        fromId: auth.currentUser!.uid,
        sent: time
    );
    await firestore.collection('chats/${getConversationId(receiver.id)}/messages/').doc(time).set(message.toJson()).then((_){
      pushNotification(receiver, 'image');
    });
  }

  static Future<void> sendDocument(ChatUser receiver,String documentUrl) async{
    String time=DateTime.now().millisecondsSinceEpoch.toString();
    Message message=Message(
        toId: receiver.id,
        msg: documentUrl,
        read: '',
        type: Type.document,
        fromId: auth.currentUser!.uid,
        sent: time
    );
    await firestore.collection('chats/${getConversationId(receiver.id)}/messages/').doc(time).set(message.toJson()).then((_){
      pushNotification(receiver, 'document');
    });
  }

  static Future<void> sendAudioMsg(ChatUser receiver,String audioUrl) async{
    String time=DateTime.now().millisecondsSinceEpoch.toString();
    Message message=Message(
        toId: receiver.id,
        msg: audioUrl,
        read: '',
        type: Type.audio,
        fromId: auth.currentUser!.uid,
        sent: time
    );
    await firestore.collection('chats/${getConversationId(receiver.id)}/messages/').doc(time).set(message.toJson()).then((_){
      pushNotification(receiver, 'audio');
    });
  }

  static Future<void> updateRead(Message msg) async{
    await firestore.collection('chats/${getConversationId(msg.fromId)}/messages/').doc(msg.sent).update({
      'read':DateTime.now().millisecondsSinceEpoch.toString()
    });
  }

  static Future<void> updateOnlineStatus(bool isOnline) async{
    await firestore.collection('users').doc(auth.currentUser!.uid).update({
      'is_online':isOnline,
      'last_active':DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token':me.pushToken
    });
  }

  static Future<void> deleteMessage(Message msg) async{
    await firestore.collection('chats/${getConversationId(msg.toId)}/messages/').doc(msg.sent).delete();
  }

  static Future<void> editMessage(Message msg,String newMessage) async{
    await firestore.collection('chats/${getConversationId(msg.toId)}/messages/').doc(msg.sent).update({
      'msg':encrypted.encrypt(newMessage, iv:Secret.iv).base64
    });
  }

  static Future<void> sendMessageToAI(String msg,String id) async{
    String time=DateTime.now().millisecondsSinceEpoch.toString();
    AiMessage message= AiMessage(
        msg: msg,
        fromId: id,
        sent: time
    );
    await firestore.collection('aichats/${auth.currentUser!.uid}/messages/').doc(time).set(message.toJson());
  }
}