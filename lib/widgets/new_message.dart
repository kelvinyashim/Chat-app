import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var enteredTxt = TextEditingController();

  void submitMessage() async {
    final enteredMsg = enteredTxt.text;

    if (enteredMsg.trim().isEmpty) {
      return;
    }
   // FocusScope.of(context).unfocus();//close the keyboard
    enteredTxt.clear(); //this is to clear the txt field after we sent a message

    final user = FirebaseAuth.instance.currentUser!;
    //we want that when a user sends an image he's username and pic is shown 
    //so the username and image is already stored in firestore therefore to get it
    //so we can use it here

    final userData = await FirebaseFirestore.instance
        .collection("user")
        .doc(user.uid)//we do this to get a specific user
        .get(); //get yields a future
    FirebaseFirestore.instance.collection("chat").add({
      "text": enteredMsg,
      "createdAt": Timestamp.now(),
      "userId": user.uid,
      "username": userData.data()!["username"],
      "userImg": userData.data()!["image"]
    });
    //send meassage
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    enteredTxt.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            controller: enteredTxt,
            decoration: const InputDecoration(labelText: "Send a message"),
          )),
          IconButton(
              color: Theme.of(context).colorScheme.primary,
              onPressed: submitMessage,
              icon: Icon(Icons.send))
        ],
      ),
    );
  }
}
