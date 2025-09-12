import 'dart:io';
import 'package:chat_app/apis/cloudinary_services.dart';
import 'package:chat_app/common/utils.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/screens/view_profile.dart';
import 'package:chat_app/secret.dart';
import 'package:chat_app/widget/message_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../apis/apis.dart';
import '../common/last_active_time_format.dart';
import '../widget/scrollbutton.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:encrypt/encrypt.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key,required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  List<Message> search = [];
  final message = TextEditingController();
  final controller = ScrollController();
  final recordController = RecorderController();
  bool showEmojiPicker = false;
  bool recording = false;
  bool showMic = true;
  bool isSearching = false;
  String? imageUrl;
  String? documentUrl;
  String? audioUrl;

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
      Utils.showSnackBar(context, 'Failed to fetch file');
    }
    else {
      imageUrl=await CloudinaryService.uploadToCloudinary(result);
      if(imageUrl!=null && imageUrl!.isNotEmpty){
        APIs.sendImage(widget.user, imageUrl!);
      }
    }
  }

  void openFilePickerDocument() async{
    FilePickerResult? result=await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowedExtensions: ['pdf','doc','docx','ppt'],
        type: FileType.custom
    );
    if(result==null){
      Utils.showSnackBar(context, 'Failed to fetch file');
    }
    else {
      documentUrl=await CloudinaryService.uploadPdfToCloudinary(File(result.files.single.path!));
      if(documentUrl!=null && documentUrl!.isNotEmpty){
        APIs.sendDocument(widget.user, documentUrl!);
      }
    }
  }

  Future<void> startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/my_audio.m4a';
    await recordController.record(
      androidEncoder: AndroidEncoder.aac,
      sampleRate: 44100,
      bitRate: 96000,
      path: filePath
    );
  }

  Future<void> stopRecording() async{
    final path = await recordController.stop();
    if(path!=null && path.isNotEmpty){
      audioUrl=await CloudinaryService.uploadAudioMsg(path);
      if(audioUrl!=null && audioUrl!.isNotEmpty){
        APIs.sendAudioMsg(widget.user, audioUrl!);
      }
    }
  }

  Widget chatScreenBar(){
    return SafeArea(
        child: !isSearching?
        InkWell(
          radius: 65,
          onTap: () async{
            Future.delayed(Duration(milliseconds: 240)).then((value){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewProfile(user: widget.user,screen: Screen.chatScreen)));
            });
          },
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.12,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CachedNetworkImage(
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                  imageUrl: widget.user.image,
                  placeholder: (context, url) => Icon(CupertinoIcons.person),
                  errorWidget: (context, url, error) => Icon(CupertinoIcons.person),
                ),
              ),
              SizedBox(
                width: 12,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
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
                  StreamBuilder(
                    stream: APIs.firestore.collection('users').where('id',isEqualTo: widget.user.id).snapshots(),
                    builder: (context,snapshot){
                      final list=snapshot.data?.docs.map((e)=>ChatUser.fromJson(e.data())).toList()??[];
                      if(snapshot.connectionState==ConnectionState.waiting){
                        return Text(
                          list.isNotEmpty?
                          list[0].isOnline?'Online':
                          LastActiveTimeFormat.formatTime(context,list[0].lastActive):
                          widget.user.lastActive.isNotEmpty?
                          LastActiveTimeFormat.formatTime(context,widget.user.lastActive):
                          'Last seen updating',
                          style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.tertiary
                          ),
                        );
                      }
                      return Text(
                        list.isNotEmpty?
                        list[0].isOnline?'Online':
                        LastActiveTimeFormat.formatTime(context,list[0].lastActive):
                        widget.user.lastActive.isNotEmpty?
                        LastActiveTimeFormat.formatTime(context,widget.user.lastActive):
                        'Last seen not available',
                        style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.tertiary
                        ),
                      );
                    },
                  )
                ],
              )
            ],
          ),
        ):
        Padding(
          padding: EdgeInsets.only(top:MediaQuery.of(context).size.width * 0.01, left: MediaQuery.of(context).size.width * 0.12, right: MediaQuery.of(context).size.width * 0.25),
          child: TextField(
            cursorColor: Colors.purple.shade50,
            decoration: InputDecoration(
              hintText: "Search Message",
              border: InputBorder.none,
            ),
            style: TextStyle(
              fontSize: 18,
            ),
            autofocus: true,
            onChanged: (val){
              search.clear();
              for(var message in messages){
                if(message.type==Type.text) {
                  if (APIs.encrypted.decrypt(
                      Encrypted.fromBase64(message.msg), iv: Secret.iv)
                      .toString().toLowerCase()
                      .contains(val.trim().toLowerCase())) {
                    search.add(message);
                  }
                }
              }
              setState(() {});
            },
          ),
        )
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
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        showEmojiPicker = !showEmojiPicker;
                      });
                    },
                    icon: Icon(Icons.emoji_emotions, color: Colors.purple, size: 26),
                  ),
                  showMic?
                  IconButton(
                    onPressed: () {
                      if(recording){
                        stopRecording();
                      }else{
                        startRecording();
                      }
                      setState(() {
                        recording = !recording;
                      });
                    },
                    icon: Icon(recording?Icons.square:Icons.mic, color: recording?Colors.red:Colors.purple, size: 26),
                  ):
                  SizedBox(),
                  recording?
                  Expanded(
                    child: AudioWaveforms(
                      margin: EdgeInsets.only(left:50,bottom: 15),
                      recorderController: recordController,
                      waveStyle: WaveStyle(
                        waveColor: Colors.purple,
                        waveThickness: 2,
                        showMiddleLine: false,
                      ),
                      size: Size(double.infinity,20),
                    ),
                  ):
                  Expanded(
                    child: TextField(
                      controller: message,
                      cursorColor: Colors.purple.shade50,
                      onTap: () {
                        if (showEmojiPicker) {
                          setState(() {
                            showEmojiPicker = !showEmojiPicker;
                          });
                        }
                      },
                      onChanged: (val){
                        if(val.isNotEmpty){
                          setState(() {
                            showMic=false;
                          });
                        }else{
                          setState(() {
                            showMic=true;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "type anything",
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
                  !recording?
                  IconButton(
                    onPressed: () {
                      openFilePicker();
                    },
                    icon: Icon(Icons.photo, color: Colors.purple, size: 26),
                  ):
                  SizedBox(),
                  recording?
                  SizedBox():
                  IconButton(
                    onPressed: () {
                      openFilePickerDocument();
                    },
                    icon: Icon(Icons.attach_file, color: Colors.purple, size: 24),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 5),
            child: MaterialButton(
              onPressed: () {
                if(!recording){
                  if (message.text.trim().isNotEmpty) {
                    APIs.sendMessage(widget.user, message.text.trim());
                    scrollToBottom();
                  } else {
                    Utils.showSnackBar(context, 'Unable to send');
                  }
                  message.clear();
                }else{
                  setState(() {
                    recording = !recording;
                  });
                  stopRecording();
                  scrollToBottom();
                }
              },
              elevation: 0.5,
              shape: const CircleBorder(),
              padding: EdgeInsets.only(left: 10, right: 8, top: 10, bottom: 10),
              color: Colors.green,
              minWidth: 0,
              child: Icon(Icons.send, color: Theme.of(context).colorScheme.primary, size: 30),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          if (showEmojiPicker) {
            showEmojiPicker = !showEmojiPicker;
          }
        });
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, __) {
          if (showEmojiPicker) {
            setState(() => showEmojiPicker = !showEmojiPicker);
            return;
          }
          Future.delayed(const Duration(milliseconds: 300), () {
            try {
              if (Navigator.canPop(context)) Navigator.pop(context);
            } catch (e) {
              Utils.showSnackBar(context, 'Unable to go back');
            }
          });
        },
        child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primary,
            appBar: AppBar(
              flexibleSpace: chatScreenBar(),
              actions: [
                IconButton(
                  onPressed: (){
                    setState(() {
                      isSearching=!isSearching;
                    });
                  },
                  icon: Icon(isSearching?Icons.cancel:Icons.search),
                ),
                IconButton(
                  onPressed: (){
                    Utils.showSnackBar(context, 'Video call will be added soon');
                  },
                  icon: Icon(Icons.video_call,size: 30),
                )
              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                StreamBuilder(
                  stream: APIs.firestore.collection('chats/${APIs.getConversationId(widget.user.id)}/messages/').snapshots(),
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
                    messages = snapshot.data?.docs.map((e) => Message.fromJson(e.data())).toList() ?? [];
                    if (messages.isEmpty) {
                      return Expanded(
                        child: Center(
                          child: Text(
                              "Say hiii👋",
                              style: TextStyle(
                                fontSize: 20,
                              )
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
                        itemCount: isSearching ? search.length:messages.length,
                        padding: EdgeInsets.only(top: 10),
                        controller: controller,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          if(isSearching && search.isEmpty){
                            return MessageCard(message: messages[index]);
                          }
                          return MessageCard(message: isSearching ? search[index]:messages[index]);
                        },
                      ),
                    );
                  },
                ),
                chatField(),
                Visibility(
                  visible: showEmojiPicker,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: EmojiPicker(
                      textEditingController: message,
                      config: Config(
                        checkPlatformCompatibility: true,
                        viewOrderConfig: const ViewOrderConfig(),
                        emojiViewConfig: EmojiViewConfig(
                            columns: 9,
                            emojiSizeMax: 28 * (Platform.isIOS ? 1.2 : 1.0)
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: ScrollButton(controller: controller)
        ),
      ),
    );
  }
}