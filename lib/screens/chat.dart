import 'package:chat_app/screens/auth.dart';
import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //we handle the push notification here because its only authenticated users that should be allowed
  //to receive push notifications
  //this was a staless now its stateful because we want to request for permission by the user

  void setUpNotifications() async {
    //now we ask for permission
    // fcm.requestPermission();
    //the method requestPermission yields a future but we cant make initstate asyc its not recommended by flutter
    //instead we create another fuction
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    //now we get the address of the device
    //await fcm.getToken(); //this gives us the address to target a specific device
    //however what we want is to send a notification for all devices connected to this chat app
    //so instead of getting the token and then sending a notification to a specific device
    //we will use topics to broadcast our message to everyone who has installed the app
    fcm.subscribeToTopic("chat");
  }

  @override
  void initState() {
    super.initState();
    setUpNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text("FlutterChat"),
          actions: [
            IconButton(
                onPressed: () {
                  firebase.signOut();
                },
                icon: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.primary,
                ))
          ],
        ),
        body: const Column(
          children: [
            Expanded(child: ChatMessages()),
            NewMessage(),
          ],
        ));
  }
}
