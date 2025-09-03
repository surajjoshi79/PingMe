import 'dart:developer';
import 'package:chat_app/common/last_active_time_format.dart';
import 'package:chat_app/common/read_time_format.dart';
import 'package:chat_app/common/utils.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/view_profile.dart';
import 'package:chat_app/secret.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import '../apis/apis.dart';
import '../models/message.dart';
import 'package:encrypt/encrypt.dart';
import 'package:local_auth/local_auth.dart';

class ChatCard extends StatefulWidget {
  final ChatUser user;
  const ChatCard({super.key,required this.user});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  Message? message;
  bool authenticated=false;
  late final LocalAuthentication auth;

  String showSubtitle(){
    if(message!.type==Type.image){
      return 'image';
    }
    else if(message!.type==Type.document){
      return 'document';
    }
    else if(message!.type==Type.audio){
      return 'audio';
    }
    return APIs.encrypted.decrypt(Encrypted.fromBase64(message!.msg), iv: Secret.iv);
  }

  Future<void> authenticate() async{
    try{
      authenticated = await auth.authenticate(
        localizedReason: "Unlock to chat",
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false
        ),
      );
    } on PlatformException catch(e){
      log(e as String);
    }
  }

  @override
  void initState() {
    super.initState();
    auth = LocalAuthentication();
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.05,vertical: 5),
      elevation: 0.5,
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      child: InkWell(
        radius: 70,
        borderRadius: BorderRadius.circular(15),
        onTap: () async{
          !widget.user.isLocked?
          Future.delayed(Duration(milliseconds: 250)).then((value){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatScreen(user: widget.user)));
          }):
          authenticate().then((_)=> authenticated?
          Future.delayed(Duration(milliseconds: 250)).then((value){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatScreen(user: widget.user)));
          }):
          Utils.showSnackBar(context, 'Authentication error')
          );
        },
        child: StreamBuilder(
          stream: APIs.firestore.collection('chats/${APIs.getConversationId(widget.user.id)}/messages/').orderBy('sent',descending: true).limit(1).snapshots(),
          builder: (context,snapshot){
            if(snapshot.connectionState==ConnectionState.waiting){
              return SizedBox();
            }
            final list=snapshot.data?.docs.map((e)=>Message.fromJson(e.data())).toList() ?? [];
            if(list.isNotEmpty){
              message=list[0];
            }
            return ListTile(
                leading: GestureDetector(
                  onTap: (){
                    showDialog(context: context, builder: (context){
                      return Opacity(
                        opacity: 0.8,
                        child: AlertDialog(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          content: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Flexible(
                                    child: Text(
                                      widget.user.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: GestureDetector(
                                    onTap: (){
                                      Navigator.of(context).pop();
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewProfile(user: widget.user, screen: Screen.homeScreen)));
                                    },
                                    child: Icon(Icons.info_outline)
                                  )
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: CachedNetworkImage(
                                      height: 200,
                                      width: 200,
                                      fit: BoxFit.cover,
                                      imageUrl: widget.user.image,
                                      placeholder: (context, url) => Icon(CupertinoIcons.person),
                                      errorWidget: (context, url, error) => Icon(CupertinoIcons.person),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: StreamBuilder(
                                    stream: APIs.firestore.collection('users').where('id',isEqualTo: widget.user.id).snapshots(),
                                    builder: (context,snapshot){
                                      if(snapshot.connectionState==ConnectionState.waiting){
                                        return SizedBox();
                                      }
                                      final list=snapshot.data?.docs.map((e)=>ChatUser.fromJson(e.data())).toList()??[];
                                      if(list.isEmpty){
                                        return SizedBox();
                                      }
                                      return Text(list[0].isOnline?
                                        'Online':
                                        list[0].lastActive.isNotEmpty?
                                        LastActiveTimeFormat.formatTime(context, list[0].lastActive):
                                        widget.user.lastActive.isNotEmpty?
                                        LastActiveTimeFormat.formatTime(context, widget.user.lastActive):
                                        'Last Seen not available'
                                      );
                                    },
                                  )
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      placeholder: (context, url) => Icon(CupertinoIcons.person),
                      errorWidget: (context, url, error) => Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
                title: Text(
                  widget.user.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  )
                ),
                subtitle: Row(
                  children: [
                    Flexible(
                      child: Text(
                        message==null?
                        widget.user.about:
                        showSubtitle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary
                        )
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    message!=null?
                    message!.fromId==APIs.auth.currentUser!.uid && message!.read.isEmpty?
                    CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 4,
                    ):
                    Container():
                    Container()
                  ],
                ),
                trailing: message!=null?
                  message!.read.isNotEmpty?
                    Text(ReadTimeFormat.formatTime(context: context, time: message!.read)):
                    Container(
                      height: 30,
                      width: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text("new",style: TextStyle(color: Theme.of(context).colorScheme.primary))
                    ):
                  SizedBox()
            );
          },
        )
      ),
    );
  }
}
