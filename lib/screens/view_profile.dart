import 'package:chat_app/common/joined_on_date_format.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../apis/apis.dart';
import 'chat_screen.dart';
import 'package:chat_app/models/message.dart';

class ViewProfile extends StatefulWidget {
  final ChatUser user;
  final Screen screen;
  const ViewProfile({super.key,required this.user,required this.screen});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  late bool isLocked;

  @override
  void initState() {
    super.initState();
    isLocked=widget.user.isLocked;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          widget.user.name,
          style: TextStyle(
              fontSize: 22
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 35,
              ),
              Card(
                color: Theme.of(context).colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 87,
                            backgroundColor: Colors.purple,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              height: 170,
                              width: 170,
                              fit: BoxFit.cover,
                              imageUrl: widget.user.image,
                              placeholder: (context, url) => Icon(CupertinoIcons.person),
                              errorWidget: (context, url, error) => Icon(CupertinoIcons.person),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                        width: MediaQuery.of(context).size.width,
                      ),
                      Text(
                        widget.user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.secondary
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Card(
                color: Theme.of(context).colorScheme.primary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15 , horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                      ),
                      Text(
                        'About',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      Flexible(
                        child: Text(
                          widget.user.about,
                          maxLines: 6,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.tertiary
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height/4,
                child: Card(
                  color: Theme.of(context).colorScheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Media Files",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        StreamBuilder(
                          stream: APIs.firestore.collection('chats/${APIs.getConversationId(widget.user.id)}/messages').where('type',isEqualTo: Type.image.name).snapshots(),
                          builder: (context,snapshot){
                            if(snapshot.connectionState==ConnectionState.waiting){
                              return CircularProgressIndicator(color: Colors.purple);
                            }
                            final list=snapshot.data?.docs.map((e) => Message.fromJson(e.data())).toList()??[];
                            if(list.isEmpty){
                              return Text("no media shared");
                            }
                            return Expanded(
                              child: ListView.builder(
                                itemCount: list.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context,index){
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: list[index].msg,
                                          placeholder: (context, url) => CircularProgressIndicator.adaptive(
                                            padding: const EdgeInsets.all(18),
                                          ),
                                          errorWidget: (context, url, error) => Icon(Icons.error,color: Colors.red,size: 30),
                                        )
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Visibility(
                visible: widget.screen==Screen.chatScreen,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ChatScreen(user: widget.user)));
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Icon(Icons.message,size: 40)
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Icon(Icons.home,size: 40)
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        APIs.firestore.collection('users').doc(widget.user.id).update({
                          'isLocked':!widget.user.isLocked
                        });
                        setState(() {
                          isLocked=!isLocked;
                        });
                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Icon(isLocked?Icons.lock:Icons.lock_open,size: 40)
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){

                      },
                      child: Card(
                        color: Theme.of(context).colorScheme.primary,
                        child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Icon(Icons.video_call,size: 40)
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Joined On: ',
            style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold
            ),
          ),
          Text(
            JoinedOnDateFormat.getJoinedDate(context, widget.user.createdAt),
            style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

enum Screen{
  homeScreen,
  chatScreen;
}