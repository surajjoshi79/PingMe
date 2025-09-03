import 'dart:io';
import 'package:chat_app/apis/cloudinary_services.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../apis/apis.dart';
import '../models/chat_user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:chat_app/common/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key,required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey=GlobalKey<FormState>();
  FocusNode fn1=FocusNode();
  FocusNode fn2=FocusNode();
  String? imagePath;
  String? imageUrl;

  void showBottomSheet(){
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top:Radius.circular(25))
      ),
      builder: (context){
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 20,bottom: 20),
          children: [
            Text(
              'Pick Profile Picture',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async{
                    final ImagePicker imagePicker=ImagePicker();
                    XFile? image=await imagePicker.pickImage(source: ImageSource.gallery);
                    if(image!=null){
                      await CloudinaryService.uploadProfilePicture(image.path).then((imageUrl){
                        APIs.me.image=imageUrl;
                        APIs.updateUserInfo().then((val){
                          Utils.showSnackBar(context, 'Profile updated successful');
                        });
                      });
                      setState(() {
                        imagePath=image.path;
                      });
                    }else{
                      Utils.showSnackBar(context, 'Failed to fetch image');
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: CircleBorder(),
                    fixedSize: Size(120, 120)
                  ),
                  child: Image.asset('assets/gallery.png'),
                ),
                ElevatedButton(
                  onPressed: () async{
                    final ImagePicker imagePicker=ImagePicker();
                    XFile? image=await imagePicker.pickImage(source: ImageSource.camera);
                    if(image!=null){
                      setState(() {
                        imagePath=image.path;
                      });
                    }else{
                      Utils.showSnackBar(context, 'Failed to fetch image');
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: CircleBorder(),
                      fixedSize: Size(120, 120)
                  ),
                  child: Image.asset('assets/camera.png'),
                )
              ],
            )
          ],
        );
      }
   );
  }

  @override
  void dispose() {
    fn1.dispose();
    fn2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return GestureDetector(
      onTap: (){
        fn1.unfocus();
        fn2.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        appBar: AppBar(
          title: Text(
            'Profile',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500
            ),
          ),
          actions: [
            IconButton(
              onPressed: (){
                Provider.of<ThemeProvider>(context,listen:false).toggleTheme();
              },
              icon: Icon(
              sharedPreferences.sp.getBool('isDark')??false?
                Icons.light_mode:
                Icons.dark_mode
              ),
            )
          ],
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10 , horizontal: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: size.width,
                  ),
                  Card(
                    color: Theme.of(context).colorScheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                          ),
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              imagePath!=null?
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.file(
                                  File(imagePath!),
                                  height: 170,
                                  width: 170,
                                  fit: BoxFit.cover,
                                ),
                              ):
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
                              MaterialButton(
                                onPressed: showBottomSheet,
                                shape: const CircleBorder(),
                                color: sharedPreferences.sp.getBool('isDark')??false?Colors.purple:Colors.purple.shade100,
                                child: Icon(
                                  Icons.edit,
                                  color: sharedPreferences.sp.getBool('isDark')??false?Colors.black:Colors.white
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            widget.user.email,
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.tertiary
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Card(
                    color: Theme.of(context).colorScheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment:CrossAxisAlignment.start,
                        children: [
                          Text('Your Information',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.tertiary,
                              fontWeight: FontWeight.w500
                            )
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            initialValue: widget.user.name,
                            onSaved: (val) => APIs.me.name=val?.trim() ?? APIs.me.name,
                            validator: (val) => val!=null && val.isNotEmpty ? null:'Required Field',
                            focusNode: fn1,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 3,
                            minLines: 1,
                            cursorColor: Colors.purple.shade50,
                            decoration: InputDecoration(
                              hintText: 'e.g.Suraj Joshi',
                              label: Text('Name',style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                              prefixIcon: Icon(Icons.person),
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
                          SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                            initialValue: widget.user.about,
                            onSaved: (val) => APIs.me.about=val?.trim() ?? APIs.me.about,
                            validator: (val) => val!=null && val.isNotEmpty ? null:'Required Field',
                            focusNode: fn2,
                            cursorColor: Colors.purple.shade50,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 3,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: 'e.g.Feeling Happy',
                              label: Text('About',style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                              prefixIcon: Icon(Icons.info),
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
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height/4,
                    child: Card(
                      color: Theme.of(context).colorScheme.primary,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("My Friends",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            StreamBuilder(
                              stream: APIs.firestore.collection('users/${APIs.auth.currentUser!.uid}/my_users').snapshots(),
                              builder: (context,snapshot){
                                final list=snapshot.data?.docs.map((e) => e.id).toList() ?? [];
                                if(list.isEmpty){
                                  return Center(child: Text("No connections found😔"));
                                }
                                return StreamBuilder(
                                  stream: APIs.firestore.collection('users').where('id', whereIn:list).snapshots(),
                                  builder: (context,snapshot){
                                    if(snapshot.hasError){
                                      return Text(
                                          "Unknown Error Occurred😢",
                                          style: TextStyle(
                                            fontSize: 20,
                                          )
                                      );
                                    }
                                    final user=snapshot.data?.docs.map((e)=> ChatUser.fromJson(e.data())).toList()??[];
                                    if(user.isEmpty){
                                      return Text(
                                          "No connections found😔",
                                          style: TextStyle(
                                            fontSize: 20,
                                          )
                                      );
                                    }
                                    return Expanded(
                                      child: ListView.builder(
                                        itemCount: user.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context,index){
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Column(
                                              children: [
                                                CircleAvatar(
                                                  radius: MediaQuery.of(context).size.height / 13,
                                                  foregroundImage: NetworkImage(
                                                    user[index].image,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    user[index].name,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.secondary,
                                                      fontWeight: FontWeight.w500
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton:
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: (){
                  fn1.unfocus();
                  fn2.unfocus();
                  if(_formKey.currentState!.validate()){
                    _formKey.currentState!.save();
                    APIs.updateUserInfo().then((val){
                      Utils.showSnackBar(context, 'Profile updated successful');
                    });
                  }
                },
                backgroundColor: sharedPreferences.sp.getBool('isDark')??false?Colors.purple:Colors.purple.shade100,
                child: Icon(
                  Icons.edit,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              FloatingActionButton.extended(
                onPressed: () async{
                  Utils.showProgressBar(context);
                  APIs.updateOnlineStatus(false);
                  await APIs.auth.signOut().then((value) async{
                    await GoogleSignIn.instance.signOut().then((value) async{
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
                    });
                  });
                },
                backgroundColor: sharedPreferences.sp.getBool('isDark')??false?Colors.purple:Colors.purple.shade100,
                icon: Icon(
                  Icons.logout_sharp,
                ),
                label: Text(
                  'Logout',
                  style:TextStyle(
                      fontSize: 20
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
