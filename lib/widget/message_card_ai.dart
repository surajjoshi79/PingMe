import 'package:chat_app/models/ai_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../apis/apis.dart';
import '../common/read_time_format.dart';
import '../common/utils.dart';

class MessageCardAi extends StatefulWidget {
  final AiMessage message;
  const MessageCardAi({super.key,required this.message});

  @override
  State<MessageCardAi> createState() => _MessageCardAiState();
}

class _MessageCardAiState extends State<MessageCardAi> {

  Widget blueContainer(){
    return Align(
      alignment: Alignment.centerLeft,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Flexible(
            child: Container(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.18),
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.015, horizontal: 15),
                margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.04, horizontal: 18),
                decoration: BoxDecoration(
                    color: sharedPreferences.sp.getBool('isDark')??false?Colors.blue:Colors.blue.shade100,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20)
                    ),
                    border: Border.all(
                        color: sharedPreferences.sp.getBool('isDark')??false?Colors.blue.shade100:Colors.blue
                    )
                ),
                child: Text(
                  '${widget.message.msg}\n',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                )
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom:18,right:MediaQuery.of(context).size.width * 0.06),
            child: Text(
              ReadTimeFormat.formatTime(context: context, time: widget.message.sent),
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.tertiary
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget purpleContainer(){
    return Align(
      alignment: Alignment.centerRight,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Flexible(
            child: Container(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width * 0.18),
                padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.015, horizontal: 15),
                margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.width * 0.04, horizontal: 18),
                decoration: BoxDecoration(
                    color: sharedPreferences.sp.getBool('isDark')??false?Colors.purple:Colors.purple.shade100,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20)
                    ),
                    border: Border.all(
                        color: sharedPreferences.sp.getBool('isDark')??false?Colors.purple.shade100:Colors.purple
                    ),
                ),
                child: Text(
                  '${widget.message.msg}\n',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                )
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom:18,right:MediaQuery.of(context).size.width * 0.06),
            child: Text(
              ReadTimeFormat.formatTime(context: context, time: widget.message.sent),
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.tertiary
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showBottomSheet(){
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
              ListView(
                shrinkWrap: true,
                padding: EdgeInsets.only(left:10,right: 10),
                children: [
                  listItem(Icon(Icons.copy,color: Colors.purple), "Copy",() async{
                    Clipboard.setData(ClipboardData(text: widget.message.msg));
                    Navigator.of(context).pop();
                    Utils.showSnackBar(context, "Text copied successfully");
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
                ],
              ),
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
      onLongPress: () => showBottomSheet(),
      child: widget.message.fromId==APIs.auth.currentUser!.uid?
      purpleContainer():
      blueContainer()
    );
  }
}
