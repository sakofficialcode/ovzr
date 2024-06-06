import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ionicons/ionicons.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  final user = FirebaseAuth.instance.currentUser!;
  ScrollController _scrollController = new ScrollController();
  final _random = new Random();
  List posts = [];

  Future<QueryDocumentSnapshot> _getPosts() async {
    DocumentSnapshot userInfo = await FirebaseFirestore.instance.collection("users").doc(user.email).get();
    List likeTags = await userInfo.get("likeTags");
    print(likeTags);
    String element = likeTags[_random.nextInt(likeTags.length)];
    print(element);
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection("posts").where("tags", arrayContains: element).get();
    return snapshot.docs[_random.nextInt(snapshot.docs.length)];
  }

  Future _likePost(tagList, postID) async {
    await FirebaseFirestore.instance.collection("users").doc(user.email).update({
      "likeTags": FieldValue.arrayUnion(tagList),
    });

    await FirebaseFirestore.instance.collection("posts").doc(postID).update({
      "likers": FieldValue.arrayUnion([user.email]),
    });
  }

  Future _addToTrips(tripID) async {
    await FirebaseFirestore.instance.collection("trips").doc(tripID).update({
      "takers": FieldValue.arrayUnion([user.email]),
    });
  }

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 2; i++) {
      setState(() {
        posts.add(_getPosts());
      });
    }
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        setState(() {
          for (int i = 0; i < 2; i++) {
            posts.add(_getPosts());
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(posts);
    return ListView(
      controller: _scrollController,
      children: posts.map((e) {
        return FutureBuilder<QueryDocumentSnapshot>(
            future: e,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                print(snapshot.error);
                return SizedBox.shrink();
              }
              print("test");
              List<String> images = List<String>.from(snapshot.data!.get("photographs"));
              return DefaultTabController(
                length: snapshot.data!.get("photographs").length,
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(12.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data!.get("title"),
                          style: TextStyle(fontSize: 18),
                        ),
                        Container(
                          constraints: BoxConstraints(maxHeight: 300),
                          child: TabBarView(
                              children: images.map<Widget>((element) {
                            return Image.network(element);
                          }).toList()),
                        ),
                        Row(
                          children: [
                            Text(
                              snapshot.data!.get("name"),
                              style: TextStyle(fontSize: 16),
                            ),
                            IconButton(
                                onPressed: () {
                                  _likePost(snapshot.data!.get("tags"), snapshot.data!.id);
                                },
                                icon: Icon(Ionicons.heart))
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              snapshot.data!.get("trip"),
                              style: TextStyle(fontSize: 16),
                            ),
                            Spacer(),
                            Text(
                              "Add to My Trips",
                              style: TextStyle(fontSize: 16),
                            ),
                            IconButton(
                                onPressed: () {
                                  _addToTrips(
                                    snapshot.data!.get("trip"),
                                  );
                                },
                                icon: Icon(Ionicons.add))
                          ],
                        ),
                        Text(
                          snapshot.data!.get("description"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      }).toList(),
    );
  }
}
