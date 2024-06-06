import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import "package:latlong2/latlong.dart" as latLng;
import 'package:ionicons/ionicons.dart';

class trip extends StatefulWidget {
  const trip({super.key});

  @override
  State<trip> createState() => _tripState();
}

class _tripState extends State<trip> {
  bool _myTrips = false;
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> _newTripDialog() async {
    TextEditingController _titleController = new TextEditingController();
    TextEditingController _descriptionController = new TextEditingController();
    TextEditingController _latController = new TextEditingController();
    TextEditingController _longController = new TextEditingController();
    TextEditingController _milesController = new TextEditingController();
    TextEditingController _recommendedEquipmentController = new TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Trip Info'),
          content: SingleChildScrollView(
            child: Column(
              children: [
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
                    hintText: "Title",
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
                SizedBox(
                  height: 10,
                ),
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
                    hintText: "Description",
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latController,
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
                          hintText: "Latitude",
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _longController,
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
                          hintText: "Longitude",
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _milesController,
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
                    hintText: "Miles Travelled",
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _recommendedEquipmentController,
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
                    hintText: "Recommended Equipment",
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("Cancel")),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                setState(() {
                  _addNewTrip(_titleController.text, _descriptionController.text, double.parse(_latController.text),
                      double.parse(_longController.text), int.parse(_milesController.text), _recommendedEquipmentController.text);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNewTrip(String title, String description, double lat, double long, int miles, String recommendedEquipment) async {
    FirebaseFirestore.instance.collection("trips").doc(title).set({
      "user": user.uid,
      "title": title,
      "description": description,
      "location": GeoPoint(lat, long),
      "miles": miles,
      "recEquip": recommendedEquipment,
      "totalStars": 0,
      "totalReviewers": 0,
      "takers": FieldValue.arrayUnion([user.email])
    });
  }

  Future _addToTrips(tripID) async {
    await FirebaseFirestore.instance.collection("trips").doc(tripID).update({
      "takers": FieldValue.arrayUnion([user.email]),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          Row(
            children: [
              Text(_myTrips ? "My Trips" : "Trips", style: TextStyle(fontSize: 20)),
              SizedBox(
                width: 25,
              ),
              _myTrips
                  ? IconButton(
                      onPressed: () {
                        _newTripDialog();
                      },
                      icon: Icon(Ionicons.add_outline))
                  : SizedBox.shrink(),
              Spacer(),
              IconButton(
                  onPressed: () {
                    setState(() {
                      _myTrips = !_myTrips;
                    });
                  },
                  icon: Icon(Ionicons.paper_plane_outline))
            ],
          ),
          StreamBuilder(
              stream: _myTrips
                  ? FirebaseFirestore.instance.collection("trips").where("takers", arrayContains: user.email).snapshots()
                  : FirebaseFirestore.instance.collection("trips").snapshots(),
              builder: (builder, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox.shrink();
                }

                return Expanded(
                  child: ListView(
                      children: snapshot.data!.docs.map((document) {
                    GeoPoint point = document.get("location");
                    return ExpansionTile(
                      title: Row(children: [
                        Text(document.get("title")),
                      ]),
                      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        RatingBar(
                          initialRating: document.get("totalReviewers") > 0 ? document.get("totalStars") / document.get("totalReviewers") : 0,
                          itemSize: 17,
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
                          onRatingUpdate: (e) {},
                        ),
                        Text(document.get("description")),
                        Text("Recommended Equipment: ${document.get("recEquip")}"),
                        !_myTrips
                            ? Row(
                                children: [
                                  Text("Add to My Trips"),
                                  IconButton(
                                      onPressed: () {
                                        _addToTrips(document.get("title"));
                                      },
                                      icon: Icon(Ionicons.add)),
                                ],
                              )
                            : SizedBox.shrink(),
                      ]),
                      children: [
                        Container(
                          constraints: BoxConstraints(maxHeight: 100),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: latLng.LatLng(point.latitude, point.longitude),
                              initialZoom: 6,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.app',
                              ),
                              MarkerLayer(markers: [Marker(point: latLng.LatLng(point.latitude, point.longitude), child: Icon(Ionicons.location))])
                            ],
                          ),
                        )
                      ],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    );
                  }).toList()),
                );
              })
        ],
      ),
    );
  }
}
