import 'dart:io';
import 'package:chat_app/secret.dart';
import 'package:flutter/material.dart';
import '../models/ai_message.dart';
import '../apis/apis.dart';
import '../common/utils.dart';
import '../widget/message_card_ai.dart';
import '../widget/scrollbutton.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> with SingleTickerProviderStateMixin{
  List<AiMessage> messages = [];
  final message = TextEditingController();
  final controller = ScrollController();
  final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: Secret.api);
  bool isLoading = false;
  bool imageSelected = false;
  String? imagePath;
  late AnimationController _animationController;

  String cleanResponse(String response) {
    String cleanedResponse = response.replaceAll('**', '');
    cleanedResponse=cleanedResponse.replaceAll('*', '•');
    cleanedResponse=cleanedResponse.replaceAll('`', '');
    return cleanedResponse;
  }

  void scrollToBottom() {
    controller.animateTo(
        controller.position.extentTotal,
        duration: Duration(milliseconds: 1000),
        curve: Curves.fastOutSlowIn
    );
  }

  void openFilePicker() async{
    FilePickerResult? result=await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image
    );
    if(result==null){
      Utils.showSnackBar(context, 'No image selected');
    }else{
      setState(() {
        imageSelected=true;
        imagePath=result.files.single.path;
      });
    }
  }

  Future<void> getReply() async{

    final query = message.text;

    setState(() {
      isLoading=true;
    });

    final prompt = [Content.text(query)];
    final response = await model.generateContent(prompt);
    setState(() {
      try {
        APIs.sendMessageToAI(cleanResponse(response.text??''), 'AI${APIs.auth.currentUser!.uid}');
      }catch(e){
        APIs.sendMessageToAI(
          'I am really sorry for your inconvenience but I am unable to find an appropriate response for your query.',
          'AI${APIs.auth.currentUser!.uid}'
        );
      }
      isLoading=false;
    });
  }

  Future<void> getReplyImage() async{

    final query = message.text;

    setState(() {
      imageSelected=false;
      isLoading=true;
    });

    final textPrompt = TextPart(query);
    final imagePrompt = [DataPart('image/jpeg', await File(imagePath!).readAsBytes())];
    final response = await model.generateContent([Content.multi([textPrompt,...imagePrompt])]);

    setState(() {
      try {
        APIs.sendMessageToAI(cleanResponse(response.text??''), 'AI${APIs.auth.currentUser!.uid}');
      }catch(e){
        APIs.sendMessageToAI(
            'I am really sorry for your inconvenience but I am unable to find an appropriate response for your query.',
            'AI${APIs.auth.currentUser!.uid}'
        );
      }
      isLoading=false;
    });

  }

  Widget aiChatScreenBar(){
    return SafeArea(
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.12,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset('assets/chatbot_icon.png',fit: BoxFit.cover)
          ),
          SizedBox(
            width: 12,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PingAI',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(
                height: 1,
              ),
              isLoading?
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _animationController,
                    child: Text("thinking...",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue
                      ),
                    ),
                  ),
                ],
              ):
              Text(
                'Powered by Gemini AI',
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.tertiary
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget chatField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left:10),
                      child: TextField(
                        controller: message,
                        cursorColor: Colors.purple.shade50,
                        decoration: InputDecoration(
                          hintText: "type anything to ask....",
                          hintStyle: TextStyle(
                              color: Colors.purple
                          ),
                          border: InputBorder.none,
                        ),
                        minLines: 1,
                        maxLines: 6,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      openFilePicker();
                    },
                    icon: Icon(Icons.photo, color: Colors.purple, size: 26),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 5),
            child: MaterialButton(
              onPressed: () async{
                if (message.text.trim().isNotEmpty) {
                  imageSelected?getReplyImage():getReply();
                  await APIs.sendMessageToAI(message.text.trim().toString(), APIs.auth.currentUser!.uid).then((val){
                    message.clear();
                    scrollToBottom();
                  });
                } else {
                  Utils.showSnackBar(context, 'Unable to send');
                }
              },
              elevation: 0.5,
              shape: const CircleBorder(),
              padding: EdgeInsets.only(left: 10, right: 8, top: 10, bottom: 10),
              color: Colors.purple,
              minWidth: 0,
              child: Icon(Icons.send_rounded, color: Theme.of(context).colorScheme.primary, size: 30),
            ),
          )
        ],
      ),
    );
  }

  Widget suggestionBox(String text){
    return GestureDetector(
      onTap: (){
        message.text=text;
      },
      child: Card(
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 15),
          child: Text(
            text,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          appBar: AppBar(
            flexibleSpace: aiChatScreenBar(),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StreamBuilder(
                stream: APIs.firestore.collection('aichats/${APIs.auth.currentUser!.uid}/messages/').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.none) {
                    return Center(
                        child: SizedBox()
                    );
                  }
                  else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                          "Unknown Error Occurred😢",
                          style: TextStyle(
                            fontSize: 20,
                          )
                      ),
                    );
                  }
                  final messages = snapshot.data?.docs.map((e) => AiMessage.fromJson(e.data())).toList() ?? [];
                  if (messages.isEmpty) {
                    return Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                                'assets/chatbot_icon.png',
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                            ),
                            Text(
                                "Ask anything to PingAI",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                )
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            suggestionBox("Write a story about a king who is curious about space"),
                            suggestionBox("Give me some tips for improving english communication"),
                            suggestionBox("How to improve my coding skills"),
                            suggestionBox("Suggest me some good RomCom movies"),
                            suggestionBox("Trending topics for instagram reels"),
                            suggestionBox("I need some career advice in coding field"),
                            suggestionBox("Suggest me some underrated bollywood songs"),
                            suggestionBox("I want to hear a joke"),
                            suggestionBox("Give me some love advice")
                          ],
                        ),
                      ),
                    );
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (controller.hasClients) {
                      controller.jumpTo(controller.position.maxScrollExtent);
                    }
                  });
                  return Flexible(
                    child: ListView.builder(
                      itemCount: messages.length,
                      padding: EdgeInsets.only(top: 10),
                      controller: controller,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return MessageCardAi(message: messages[index]);
                      },
                    ),
                  );
                },
              ),
              imageSelected && imagePath!=null?
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 10),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(File(imagePath!),fit: BoxFit.cover),
                  ),
                ),
              ):
              Container(),
              chatField(),
            ],
          ),
          floatingActionButton: ScrollButton(controller: controller)
      ),
    );
  }
}
