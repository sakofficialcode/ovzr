import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection("users").doc(user.email).get(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return SizedBox.shrink();
        }
        return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("posts").where("user", isEqualTo: user.uid).snapshots(),
            builder: (context, userPostsSnapshot) {
              if (!userPostsSnapshot.hasData) {
                return SizedBox.shrink();
              }
              return Container(
                padding: EdgeInsets.all(25),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "${userSnapshot.data!.get("firstName")} ${userSnapshot.data!.get("lastName")}",
                          style: TextStyle(fontSize: 20),
                        ),
                        Spacer(),
                        IconButton(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                            },
                            icon: Icon(Ionicons.log_out))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(userSnapshot.data!.get("miles").toString()),
                            Text("Miles Travelled"),
                          ],
                        ),
                        Column(
                          children: [
                            Text(userSnapshot.data!.get("followers").length.toString()),
                            Text("Followers"),
                          ],
                        ),
                        Column(
                          children: [
                            Text(userSnapshot.data!.get("following").length.toString()),
                            Text("Following"),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 12.5,
                    ),
                    Row(children: [
                      Text(
                        "Posts",
                        style: TextStyle(fontSize: 18),
                      ),
                      Spacer(),
                    ]),
                    Expanded(
                      child: GridView.count(
                          crossAxisCount: 3,
                          children: userPostsSnapshot.data!.docs.map((e) {
                            return Image.network(e.get("photographs")[0]);
                          }).toList()),
                    )
                  ],
                ),
              );
            });
      },
    );
  }
}
