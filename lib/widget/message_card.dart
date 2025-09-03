import 'package:chat_app/apis/apis.dart';
import 'package:chat_app/common/read_time_format.dart';
import 'package:chat_app/common/utils.dart';
import 'package:chat_app/widget/audio_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message.dart';
import 'package:encrypt/encrypt.dart';
import '../secret.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({super.key,required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  Widget showMsg(){
    if(widget.message.type==Type.text){
      return Text(
        APIs.encrypted.decrypt(Encrypted.fromBase64(widget.message.msg),iv: Secret.iv),
        style: TextStyle(
          fontSize: 18,
        ),
      );
    }
    else if(widget.message.type==Type.image){
      return ClipRRect(
          borderRadius:
          widget.message.fromId==APIs.auth.currentUser!.uid?
          BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20)
          ):
          BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20)
          ),
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: widget.message.msg,
            placeholder: (context, url) => CircularProgressIndicator.adaptive(
              padding: const EdgeInsets.all(18),
            ),
            errorWidget: (context, url, error) =>
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  Icon(Icons.error,color: Colors.red,size: 30),
                  Text('Image loading error',style: TextStyle(color: Colors.red))
                ],
              ),
            ),
          )
      );
    }
    else if(widget.message.type==Type.audio){
      return AudioCard(audioUrl: widget.message.msg);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.picture_as_pdf_outlined),
        SizedBox(
          width: 10,
        ),
        Text("Document")
      ],
    );
  }
  Widget greenContainer(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Text(
            ReadTimeFormat.formatTime(context: context, time: widget.message.sent),
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.tertiary
            ),
          ),
        ),
        Flexible(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              widget.message.type!=Type.audio?
              Container(
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.025, horizontal: 15),
                margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.04, horizontal: 18),
                decoration: BoxDecoration(
                  color: sharedPreferences.sp.getBool('isDark')??false?Colors.green.shade400:Colors.lightGreen.shade200,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20)
                  ),
                  border: Border.all(
                    color: sharedPreferences.sp.getBool('isDark')??false?Colors.lightGreen.shade200:Colors.green
                  )
                ),
                child: showMsg()
              ):
              Container(
                margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.04, horizontal: 18),
                decoration: BoxDecoration(
                  color: sharedPreferences.sp.getBool('isDark')??false?Colors.orange.shade300:Colors.orange.shade100,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20)
                  ),
                  border: Border.all(
                    color: sharedPreferences.sp.getBool('isDark')??false?Colors.orange.shade100:Colors.orange
                  )
                ),
                child: showMsg()
              ),
              Padding(
                padding: EdgeInsets.only(bottom:20,right: MediaQuery.of(context).size.width * 0.05),
                child: Icon(
                  Icons.done_all,
                  color: widget.message.read.isNotEmpty?Colors.blue:Colors.grey,
                  size: 15,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget purpleContainer(){
    if(widget.message.read.isEmpty){
      APIs.updateRead(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: widget.message.type!=Type.audio?
          Container(
            padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.025, horizontal: 15),
            margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.04, horizontal: 18),
            decoration: BoxDecoration(
                color: sharedPreferences.sp.getBool('isDark')??false?Colors.purple:Colors.purple.shade50,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20)
                ),
                border: Border.all(
                    color: sharedPreferences.sp.getBool('isDark')??false?Colors.purple.shade100:Colors.purple
                )
            ),
            child: showMsg()
          ):
          Container(
            margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.04, horizontal: 18),
            decoration: BoxDecoration(
              color: sharedPreferences.sp.getBool('isDark')??false?Colors.lime:Colors.teal.shade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20)
              ),
              border: Border.all(
                color: sharedPreferences.sp.getBool('isDark')??false?Colors.lime.shade100:Colors.teal
              )
            ),
            child: showMsg()
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Padding(
          padding: EdgeInsets.only(bottom:18,right:MediaQuery.of(context).size.width * 0.04),
          child: Text(
            ReadTimeFormat.formatTime(context: context, time: widget.message.sent),
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.tertiary
            ),
          ),
        )
      ],
    );
  }

  void showBottomSheet(){
    TextEditingController updatedMessage=TextEditingController();
    updatedMessage.text=APIs.encrypted.decrypt(Encrypted.fromBase64(widget.message.msg),iv: Secret.iv);
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.primary,
      builder: (context){
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 10,horizontal: MediaQuery.of(context).size.width * 0.4),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10)
              ),
            ),
            widget.message.fromId==APIs.auth.currentUser!.uid?
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left:10,right: 10),
              children: [
                listItem(Icon(Icons.copy,color: Colors.purple), "Copy",() async{
                  Clipboard.setData(ClipboardData(text: APIs.encrypted.decrypt(Encrypted.fromBase64(widget.message.msg),iv: Secret.iv))).then((_){
                    Navigator.of(context).pop();
                    Utils.showSnackBar(context, "Text copied successfully");
                  });
                }),
                listItem(Icon(Icons.edit,color: Colors.purple), "Edit", () async{
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context){
                      return AlertDialog(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        title: Row(
                          children: [
                            Icon(Icons.message),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Update Message',
                              style:TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500
                              )
                            )
                          ],
                        ),
                        content: TextField(
                          controller: updatedMessage,
                          cursorColor: Colors.purple.shade50,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 3,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: 'type anything',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Colors.purple
                                )
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Colors.purple
                                )
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: (){
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel',style: TextStyle(color:Theme.of(context).colorScheme.secondary)),
                          ),
                          TextButton(
                            onPressed: (){
                              if(updatedMessage.text.toString().trim().isNotEmpty){
                                APIs.editMessage(widget.message, updatedMessage.text.trim()).then((_){
                                  Utils.showSnackBar(context, 'Message edited successfully');
                                });
                              }else{
                                Utils.showSnackBar(context, 'Empty message');
                              }
                              Navigator.of(context).pop();
                            },
                            child: Text('Update',style: TextStyle(color:Theme.of(context).colorScheme.secondary)),
                          )
                        ],
                      );
                    }
                  );
                }),
                listItem(Icon(Icons.delete,color: Colors.red), "Delete", () async{
                  APIs.deleteMessage(widget.message).then((_){
                    Navigator.of(context).pop();
                    Utils.showSnackBar(context, "Message deleted");
                  });
                }),
                Divider(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  thickness: 2,
                ),
                listItem(
                  Icon(Icons.send,color: Colors.green),
                  'Sent at: ${ReadTimeFormat.formatTime(context: context, time: widget.message.sent)}',
                  (){}
                ),
                listItem(
                  Icon(Icons.remove_red_eye_rounded,color: Colors.green),
                  widget.message.read.isNotEmpty?
                  'Read at: ${ReadTimeFormat.formatTime(context: context, time: widget.message.read)}':
                  'Not seen till now',
                  (){}
                )
              ],
            ):
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left:10,right: 10),
              children: [
                listItem(Icon(Icons.copy,color: Colors.purple), "Copy", () async{
                  Clipboard.setData(ClipboardData(text: APIs.encrypted.decrypt(Encrypted.fromBase64(widget.message.msg),iv: Secret.iv))).then((_){
                    Navigator.of(context).pop();
                    Utils.showSnackBar(context, "Text copied successfully");
                  });
                }),
                Divider(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  thickness: 2,
                ),
                listItem(
                  Icon(Icons.send,color: Colors.green),
                  'Sent at: ${ReadTimeFormat.formatTime(context: context, time: widget.message.sent)}',
                  (){}
                ),
                listItem(
                  Icon(Icons.remove_red_eye_rounded,color: Colors.green),
                  widget.message.read.isNotEmpty?
                  'Read at: ${ReadTimeFormat.formatTime(context: context, time: widget.message.read)}':
                  'Not seen till now',
                  (){}
                )
              ],
            )
          ],
        );
      }
    );
  }

  void showBottomSheetImage(){
    showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.primary,
        builder: (context){
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 10,horizontal: MediaQuery.of(context).size.width * 0.4),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)
                ),
              ),
              widget.message.fromId==APIs.auth.currentUser!.uid?
              ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left:10,right: 10),
                children: [
                  listItem(Icon(Icons.save_alt,color: Colors.purple), "Download",() async{
                    final response = await http.get(Uri.parse(widget.message.msg));
                    Navigator.of(context).pop();
                    try {
                      await Gal.putImageBytes(response.bodyBytes);
                      Utils.showSnackBar(context, 'Image saved successfully');
                    } catch (e) {
                      Utils.showSnackBar(context, 'Failed to save image');
                    }
                  }),
                  listItem(Icon(Icons.delete,color: Colors.red), "Delete", () async{
                    APIs.deleteMessage(widget.message).then((_){
                      Navigator.of(context).pop();
                      Utils.showSnackBar(context, "Message deleted");
                    });
                  }),
                  Divider(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    thickness: 2,
                  ),
                  listItem(
                      Icon(Icons.send,color: Colors.green),
                      'Sent at: ${ReadTimeFormat.formatTime(context: context, time: widget.message.sent)}',
                      (){}
                  ),
                  listItem(
                      Icon(Icons.remove_red_eye_rounded,color: Colors.green),
                      widget.message.read.isNotEmpty?
                      'Read at: ${ReadTimeFormat.formatTime(context: context, time: widget.message.read)}':
                      'Not seen till now',
                      (){}
                  )
                ],
              ):
              ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left:10,right: 10),
                children: [
                  listItem(Icon(Icons.save_alt,color: Colors.purple), "Download", () async{
                    final response = await http.get(Uri.parse(widget.message.msg));
                    Navigator.of(context).pop();
                    try {
                      await Gal.putImageBytes(response.bodyBytes);
                      Utils.showSnackBar(context, 'Image saved successfully');
                    } catch (e) {
                      Utils.showSnackBar(context, 'Failed to save image');
                    }
                  }),
                  Divider(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    thickness: 2,
                  ),
                  listItem(
                      Icon(Icons.send,color: Colors.green),
                      'Sent at: ${ReadTimeFormat.formatTime(context: context, time: widget.message.sent)}',
                      (){}
                  ),
                  listItem(
                      Icon(Icons.remove_red_eye_rounded,color: Colors.green),
                      widget.message.read.isNotEmpty?
                      'Read at: ${ReadTimeFormat.formatTime(context: context, time: widget.message.read)}':
                      'Not seen till now',
                      (){}
                  )
                ],
              )
            ],
          );
        }
    );
  }

  void showBottomSheetDocument(){
    showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).colorScheme.primary,
        builder: (context){
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 10,horizontal: MediaQuery.of(context).size.width * 0.4),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10)
                ),
              ),
              widget.message.fromId==APIs.auth.currentUser!.uid?
              ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left:10,right: 10),
                children: [
                  listItem(Icon(Icons.open_with,color: Colors.purple), "Open",() async{
                    Navigator.of(context).pop();
                    await launchUrl(Uri.parse(widget.message.msg),mode: LaunchMode.externalApplication);
                  }),
                  listItem(Icon(Icons.delete,color: Colors.red), "Delete", () async{
                    APIs.deleteMessage(widget.message).then((_){
                      Navigator.of(context).pop();
                      Utils.showSnackBar(context, "Message deleted");
                    });
                  }),
                  Divider(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    thickness: 2,
                  ),
                  listItem(
                      Icon(Icons.send,color: Colors.green),
                      'Sent at: ${ReadTimeFormat.formatTime(context: context, time: widget.message.sent)}',
                      (){}
                  ),
                  listItem(
                      Icon(Icons.remove_red_eye_rounded,color: Colors.green),
                      widget.message.read.isNotEmpty?
                      'Read at: ${ReadTimeFormat.formatTime(context: context, time: widget.message.read)}':
                      'Not seen till now',
                      (){}
                  )
                ],
              ):
              ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left:10,right: 10),
                children: [
                  listItem(Icon(Icons.open_with,color: Colors.purple), "Open", () async{
                    Navigator.of(context).pop();
                    await launchUrl(Uri.parse(widget.message.msg),mode: LaunchMode.externalApplication);
                  }),
                  Divider(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    thickness: 2,
                  ),
                  listItem(
                      Icon(Icons.send,color: Colors.green),
                      'Sent at: ${ReadTimeFormat.formatTime(context: context, time: widget.message.sent)}',
                      (){}
                  ),
                  listItem(
                      Icon(Icons.remove_red_eye_rounded,color: Colors.green),
                      widget.message.read.isNotEmpty?
                      'Read at: ${ReadTimeFormat.formatTime(context: context, time: widget.message.read)}':
                      'Not seen till now',
                      (){}
                  )
                ],
              )
            ],
          );
        }
    );
  }


  Widget listItem(Icon icon,String name,Function() action){
    return GestureDetector(
      onTap: action,
      child: ListTile(
        leading: icon,
        title: Text(name,style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => FocusScope.of(context).unfocus(),
      onLongPress: () => widget.message.type==Type.text?showBottomSheet():widget.message.type==Type.image?showBottomSheetImage():showBottomSheetDocument(),
      child: widget.message.fromId==APIs.auth.currentUser!.uid?
      greenContainer():
      purpleContainer(),
    );
  }
}
