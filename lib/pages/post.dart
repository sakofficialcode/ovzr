import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';

class post extends StatefulWidget {
  const post({super.key});

  @override
  State<post> createState() => _postState();
}

class _postState extends State<post> {
  TextEditingController _titleController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();
  List<String> tagOptions = ["Mountains", "Beach", "Desert", "Custom"];
  List<String> selectedTags = [];
  late TextEditingController autoTextEditingController;
  ImagePicker _picker = new ImagePicker();
  List<XFile> images = [];
  List<Image> displayImages = [];
  final imagesRef = FirebaseStorage.instance.ref();
  final user = FirebaseAuth.instance.currentUser!;
  late String _trip;
  int _rating = 0;

  Future<void> _customTagDialog() async {
    TextEditingController _customTagController = new TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Custom Tag'),
          content: TextField(
            controller: _customTagController,
            decoration: InputDecoration(
              fillColor: Colors.lightGreen[50],
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
              border: InputBorder.none,
              hintText: "Custom Tag Name",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                setState(() {
                  selectedTags.add(_customTagController.text.toLowerCase());
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitPost() async {
    List<String> imageLocations = [];
    File imageFile;

    for (XFile element in images) {
      imageFile = File(element.path);
      Reference ref = imagesRef.child("images/${user.uid}-${DateTime.now().millisecondsSinceEpoch}.jpg");
      await ref.putFile(imageFile);
      imageLocations.add(await ref.getDownloadURL());
      print(imageLocations);
    }

    print("complete");

    var tripSnapshot = await FirebaseFirestore.instance.collection("trips").doc(_trip).get();

    await FirebaseFirestore.instance.collection("trips").doc(_trip).update({
      "totalStars": FieldValue.increment(_rating),
      "totalReviewers": FieldValue.increment(1),
    });

    var userSnapshot = await FirebaseFirestore.instance.collection("users").doc(user.email).get();

    await FirebaseFirestore.instance.collection("posts").add({
      "user": user.uid,
      "name": "${userSnapshot.get("firstName")} ${userSnapshot.get("lastName")}",
      "title": _titleController.text,
      "description": _descriptionController.text,
      "photographs": imageLocations,
      "trip": _trip,
      "tags": selectedTags,
    });

    final snapshot = await FirebaseFirestore.instance.collection("users").get();
    snapshot.docs.forEach((doc) {
      selectedTags.forEach((tag) {
        if (!doc.get("likeTags").contains(tag)) {
          FirebaseFirestore.instance.collection("users").doc(doc.id).update({
            "likeTags": FieldValue.arrayUnion([tag]),
          });
        }
      });
    });

    FirebaseFirestore.instance.collection("users").doc(user.email).update({
      "miles": FieldValue.increment(tripSnapshot.get("miles")),
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("trips").where("takers", arrayContains: user.email).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox.shrink();
          }
          try {
            _trip = snapshot.data!.docs.first.get("title");
          } catch (e) {
            return SizedBox.shrink();
          }

          return DefaultTabController(
            length: displayImages.length,
            child: Container(
              padding: EdgeInsets.all(25),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    images.isEmpty
                        ? Container(
                            padding: EdgeInsets.all(25),
                            child: Column(
                              children: [
                                IconButton.filled(
                                    onPressed: () async {
                                      images = await _picker.pickMultiImage();
                                      setState(() {
                                        images.forEach((element) {
                                          displayImages.add(Image.file(
                                            File(element.path),
                                          ));
                                        });
                                      });
                                    },
                                    icon: Icon(Ionicons.camera)),
                                SizedBox(height: 4),
                                Text("Select Media"),
                              ],
                            ))
                        : Container(
                            constraints: BoxConstraints(maxHeight: 150, maxWidth: 500),
                            padding: EdgeInsets.all(12),
                            child: TabBarView(children: displayImages)),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        fillColor: Colors.lightGreen[50],
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        border: InputBorder.none,
                        hintText: "Post Title",
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        fillColor: Colors.lightGreen[50],
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        border: InputBorder.none,
                        hintText: "Post Description",
                      ),
                      //                onSubmitted: (value) => signIn(),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Trip"),
                        DropdownMenu(
                            dropdownMenuEntries: snapshot.data!.docs.map((document) {
                          return DropdownMenuEntry(value: _trip, label: document.get("title"));
                        }).toList()),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Rating"),
                        RatingBar(
                          minRating: 1,
                          maxRating: 5,
                          onRatingUpdate: (value) {
                            _rating = value.toInt();
                          },
                          ratingWidget: RatingWidget(
                              full: Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              half: Icon(Ionicons.star_half_sharp, color: Colors.amber),
                              empty: Icon(
                                Icons.star,
                                color: Colors.grey,
                              )),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Autocomplete(
                      optionsBuilder: (textEditingValue) {
                        return tagOptions.where((element) => element.contains(textEditingValue.text));
                      },
                      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                        autoTextEditingController = textEditingController;
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            fillColor: Colors.lightGreen[50],
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            prefixIcon: selectedTags.length < 1
                                ? null
                                : Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 10),
                                    child: Wrap(
                                        spacing: 5,
                                        runSpacing: 5,
                                        children: selectedTags.map((s) {
                                          return Chip(
                                              backgroundColor: Colors.blue[100],
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(7),
                                              ),
                                              label: Text(s, style: TextStyle(color: Colors.blue[900])),
                                              onDeleted: () {
                                                setState(() {
                                                  selectedTags.remove(s);
                                                });
                                              });
                                        }).toList()),
                                  ),
                            hintText: "Tags",
                          ),
                          keyboardType: TextInputType.none,
                          showCursor: false,
                          onSubmitted: (value) {
                            textEditingController.clear();
                            if (!selectedTags.contains(value)) {
                              setState(() {
                                selectedTags.add(value);
                              });
                            }
                          },
                        );
                      },
                      onSelected: (tag) {
                        autoTextEditingController.clear();
                        if (tag != "Custom") {
                          setState(() {
                            selectedTags.add(tag);
                          });
                        } else {
                          _customTagDialog();
                        }
                      },
                    ),
                    Row(children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              _submitPost();
                            },
                            child: Text("Submit Post")),
                      ),
                    ])
                  ],
                ),
              ),
            ),
          );
        });
  }
}
