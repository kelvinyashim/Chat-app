import 'package:chat_app/widgets/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chat")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No messages yet"),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text("Something went wrong"),
          );
        }
        final loadedMsg = snapshot.data!.docs;//this gives a list of data
        final user = FirebaseAuth.instance.currentUser!;
        return ListView.builder(
            reverse: true,
            padding: EdgeInsets.only(bottom: 60, left: 12, right: 12),
            itemCount: loadedMsg.length,
            itemBuilder: (context, index) {
              //first we get hold of the chat message
              final chatMsg = loadedMsg[index].data();
              //next we get the next msg, kind of like a second message
              //we have to check whether there is a next message
              //to do that the index + 1 must be lesser than loadedMsg.length to ensure we do have a next mssg
              final nxtMsg = index + 1 < loadedMsg.length
                  ? loadedMsg[index + 1].data()
                  : null; //now we can compare both msgs and decide what to do with them

              //Now we need to know which user is currently logged in and sending a message
              // to do that we must get the userId
              //we use the userId instead of username because two users can have the same name but not id

              final currUserId = chatMsg["userId"];
              final nextMsgUserId = nxtMsg != null ? nxtMsg["userId"] : null;
              //Then we check if the user is the same
              final nextUserIsSame = currUserId == nextMsgUserId;
              //Now if the user is same then we use Messagebubble.next or otherwise
              //but we must get the current user
              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: 
                    chatMsg["text"],
                     isMe: user.uid == currUserId);
              } else {
                return MessageBubble.first(
                    userImage: chatMsg["userImg"],
                    username: chatMsg["username"],
                    message: chatMsg["text"] ,
                    isMe: user.uid == currUserId);
              }
            });
      },
    );
  }
}
