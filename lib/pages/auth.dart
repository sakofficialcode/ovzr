import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ovzr/pages/login.dart';
import 'base.dart';

Future<bool> getPerms() async {
  bool perms = false;
  var documentSnapshot =
      (await FirebaseFirestore.instance.collection("users").where("email", isEqualTo: FirebaseAuth.instance.currentUser!.email).get());
  perms = documentSnapshot.docs.first['isTeacher'];
  return perms;
}

class auth extends StatelessWidget {
  const auth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return base();
          } else {
            return login();
          }
        });
  }
}
