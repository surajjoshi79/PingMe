import 'package:chat_app/apis/apis.dart';
import 'package:chat_app/common/utils.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/screens/ai_chat_screen.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/widget/chat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> user=[];
  final List<ChatUser> searchResult=[];
  bool isSearching=false;
  TextEditingController email=TextEditingController();
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message){
      if(APIs.auth.currentUser!=null) {
        if (message.toString().contains('pause')) {
          APIs.updateOnlineStatus(false);
        }
        if (message.toString().contains('resume')) {
          APIs.updateOnlineStatus(true);
        }
      }
      return Future.value(message);
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: PopScope(
        canPop: !isSearching,
        onPopInvokedWithResult: (didPop,result) {
          if(isSearching){
            setState(() {
              isSearching=!isSearching;
            });
          }else{
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(5),
              child: Image.asset('assets/icon_foreground.png'),
            ),
            title: isSearching?
            TextField(
              cursorColor: Colors.purple.shade50,
              decoration: InputDecoration(
                hintText: "Search User",
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontSize: 18,
              ),
              autofocus: true,
              onChanged: (val){
                searchResult.clear();
                for(var user in user){
                  if(user.name.toLowerCase().contains(val.toLowerCase().trim()) || user.email.toLowerCase().contains(val.toLowerCase().trim())){
                    searchResult.add(user);
                  }
                }
                setState(() {});
              },
            ):
            Text(
              "PingMe",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              )
            ),
            actions: [
              IconButton(
                onPressed: (){
                  setState(() {
                    isSearching=!isSearching;
                  });
                },
                icon: Icon(isSearching?Icons.cancel:Icons.search)
              ),
              Visibility(
                visible: isSearching,
                child: IconButton(
                  onPressed: (){
                    setState(() {
                      isSearching=false;
                    });
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AiChatScreen()));
                  },
                  icon: Image.asset('assets/chatbot_icon.png'),
                ),
              ),
              IconButton(
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return ProfileScreen(user: APIs.me);
                    }));
                  },
                  icon: Icon(Icons.account_circle)
              ),
            ],
          ),
          body: StreamBuilder(
            stream: APIs.firestore.collection('users').doc(APIs.auth.currentUser!.uid).collection('my_users').snapshots(),
            builder: (context,snapshot){
              if(snapshot.connectionState==ConnectionState.waiting){
                return Center(
                  child: CircularProgressIndicator(color: Colors.purple),
                );
              }
              else if(snapshot.hasError){
                return Center(
                  child: Text(
                    "Unknown Error Occurred😢",
                    style: TextStyle(
                      fontSize: 20,
                    )
                  ),
                );
              }
              final friends=snapshot.data?.docs.map((e) => e.id).toList() ?? [];
              if(friends.isEmpty){
                return Center(
                  child: Text(
                    "No connections found😔",
                    style: TextStyle(
                      fontSize: 20,
                    )
                  ),
                );
              }
              return StreamBuilder(
                stream: APIs.firestore.collection('users').where('id', whereIn:friends).snapshots(),
                builder: (context,snapshot){
                  if(snapshot.connectionState==ConnectionState.waiting){
                    return Center(
                      child: CircularProgressIndicator(color: Colors.purple),
                    );
                  }
                  else if(snapshot.hasError){
                    return Center(
                      child: Text(
                          "Unknown Error Occurred😢",
                          style: TextStyle(
                            fontSize: 20,
                          )
                      ),
                    );
                  }
                  user=snapshot.data?.docs.map((e)=> ChatUser.fromJson(e.data())).toList()??[];
                  if(user.isEmpty){
                    return Center(
                      child: Text(
                          "No connections found😔",
                          style: TextStyle(
                            fontSize: 20,
                          )
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: isSearching?searchResult.length:user.length,
                    padding: EdgeInsets.only(top:10),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context,index){
                      return ChatCard(user: isSearching?searchResult[index]:user[index]);
                    },
                  );
                },
              );
            },
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  elevation: 0,
                  splashColor: Colors.transparent,
                  onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AiChatScreen()));
                  },
                  backgroundColor: Colors.transparent,
                  child: Image.asset('assets/chatbot_icon.png'),
                ),
                SizedBox(
                  height: 10,
                ),
                FloatingActionButton(
                  onPressed: (){
                    showDialog(
                      context: context,
                      builder: (context){
                        return AlertDialog(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          title: Row(
                            children: [
                              Icon(Icons.message),
                              SizedBox(width: 5),
                              Text('Add friends',
                                style:TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500
                                )
                              )
                            ],
                          ),
                          content: TextField(
                            controller: email,
                            cursorColor: Colors.purple.shade50,
                            keyboardType: TextInputType.multiline,
                            maxLines: 3,
                            minLines: 1,
                            decoration: InputDecoration(
                            hintText: 'Enter email',
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
                              onPressed: () async{
                                if(email.text.toString().trim().isNotEmpty){
                                  final userExist=await APIs.myUserExist(email.text.trim());
                                  if(!userExist){
                                    Utils.showSnackBar(context, 'User don\'t exist');
                                  }
                                }else{
                                  Utils.showSnackBar(context, 'Empty email');
                                }
                                email.text='';
                                Navigator.of(context).pop();
                              },
                              child: Text('Add',style: TextStyle(color:Theme.of(context).colorScheme.secondary)),
                            )
                          ],
                        );
                      }
                    );
                  },
                  backgroundColor: sharedPreferences.sp.getBool('isDark')??false?Colors.purple:Colors.purple.shade100,
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
