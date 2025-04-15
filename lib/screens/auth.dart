import 'dart:io';

import 'package:chat_app/widgets/image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firebase = FirebaseAuth.instance;

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  File? selectedImg;
  var isLogin = true;
  var formKey = GlobalKey<FormState>();
  var enteredEmail = "";
  var enteredPsw = "";
  var isAuthenticating = false;
  var username = "";

  void login() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid ||(!isLogin && selectedImg == null)) {
      return;
    }

    formKey.currentState!.save();

    try {
      setState(() {
        isAuthenticating = true;
      });

      if (isLogin) {
        final loggedIn = await firebase.signInWithEmailAndPassword(
          email: enteredEmail,
          password: enteredPsw,
        );
        // Handle successful login
      } else {
        final userCredentials = await firebase.createUserWithEmailAndPassword(
          email: enteredEmail,
          password: enteredPsw,
        );

        //we handle the image upload here because of cause this is where the user is created and adds an image
        //we do this with the firebase storage
        //the ref gives us access to the firebase storage in firebase
        //the first child allows us create a path to the storage in firebase
        //the second child is used to specify the file type we want stored
        //and this child is our usercredentials
        //we then access it by .user which gives us access to the data of the user and then .uid to get the id of that user

        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_places")
            .child("${userCredentials.user!.uid}.jpg");

        await storageRef.putFile(selectedImg!);

        final imageUrl = await storageRef.getDownloadURL();

        FirebaseFirestore.instance
            .collection("user")
            .doc(userCredentials.user!.uid)
            .set({
          "username":username,
          "email": enteredEmail,
          "image": imageUrl
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? "Authentication failed"),
        ),
      );
      setState(() {
        isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(25),
                width: 400,
                child: Image.asset('lib/asset/image/chat.png'),
              ),
              Card(
                elevation: 3.0,
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLogin == false)
                              InputImage(
                                onSelect: (pickedImg) {
                                  selectedImg = pickedImg;
                                },
                              ),
                            TextFormField(
                              autocorrect: false,
                              decoration: const InputDecoration(
                                  labelText: "Enter email"),
                              keyboardType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains("@")) {
                                  return "Please enter a valid email address.";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                enteredEmail = newValue!;
                              },
                            ),
                            TextFormField(
                              autocorrect: false,
                              decoration: const InputDecoration(
                                  labelText: "Enter Password"),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return "Must be above 6 characters long";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                enteredPsw = newValue!;
                              },
                            ),
                             if(!isLogin)
                             TextFormField(
                              autocorrect: false,
                              decoration: const InputDecoration(
                                  labelText: "Username"),
                                  enableSuggestions: false,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return "Must be above 5 characters long";
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                username = newValue!;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            if (isAuthenticating)
                              const CircularProgressIndicator(),
                            if (!isAuthenticating)
                              ElevatedButton(
                                onPressed: login,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                child: Text(isLogin ? "Login" : "Sign Up"),
                              ),
                            if (!isAuthenticating)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    isLogin = !isLogin;
                                  });
                                },
                                child: Text(isLogin
                                    ? "Create an account"
                                    : "I already have an account"),
                              ),
                          ],
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
