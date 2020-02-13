import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';

class AboutApp extends StatefulWidget {
  AboutApp(
      {Key key,
      this.userEmail,
      this.userId,
      this.auth,
      this.logoutCallback,
      this.db,
      this.fs})
      : super(key: key);

  final Firestore db;
  final FirebaseStorage fs;
  final String userEmail;
  final String userId;
  final BaseAuth auth;
  final VoidCallback logoutCallback;

  @override
  _AboutAppState createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                showAboutDialog(
                    context: context,
                    applicationIcon: Image.asset("assets/logo.png"),
                    applicationName: "Infrastrucktor",
                    applicationVersion: "1.0c");
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
                height: 108.0,
                color: Theme.of(context).primaryColor,
                child: ListTile(
                  leading: Icon(
                    Icons.info,
                    color: Colors.white,
                    size: 60.0,
                  ),
                  title: Text("Infrastrucktor",
                      textScaleFactor: 2.0,
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  subtitle: Text("1.0c",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
            ),
            StreamBuilder(
              stream: widget.db
                  .collection("app")
                  .where("confirm", isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                DocumentSnapshot data = snapshot.data.documents[0];
                double _intRating = 0;
                double _rating = 0;
                if (data["ratings"].isNotEmpty) {
                  for (var i = 0; i < data["ratings"].length; i++) {
                    _intRating += data["ratings"][i]["rating"];
                  }
                  _rating = _intRating / data["ratings"].length;
                }

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Card(
                    elevation: 3.0,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            snapshot.data.documents[0]["about"],
                            textAlign: TextAlign.start,
                            textScaleFactor: 1.5,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            snapshot.data.documents[0]["about2"],
                            textAlign: TextAlign.start,
                            textScaleFactor: 1.5,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          StreamBuilder(
                              stream: widget.db
                                  .collection("accounts")
                                  .where("uid", isEqualTo: widget.userId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }

                                DocumentSnapshot data =
                                    snapshot.data.documents[0];

                                return data["permission"] == 2
                                    ? RatingBar(
                                        initialRating: _rating != 0 &&
                                                !_rating.isNaN &&
                                                !_rating.isNegative &&
                                                _rating != null
                                            ? _rating
                                            : 0,
                                        minRating: _rating != 0 &&
                                                !_rating.isNaN &&
                                                !_rating.isNegative &&
                                                _rating != null
                                            ? 1
                                            : 0,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemPadding: EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (value) {
                                          showDialog(
                                              context: context,
                                              child: AlertDialog(
                                                content: Text(
                                                    "Rate this app $value?"),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    color: Colors.blue,
                                                    child: Text("Confirm"),
                                                    onPressed: () async {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Thank you for rating our app",
                                                          backgroundColor:
                                                              Colors.green,
                                                          textColor:
                                                              Colors.white);
                                                      Navigator.of(context)
                                                          .pop();
                                                      await widget.db
                                                          .collection("app")
                                                          .document(
                                                              "LwgTDBxMs98hjqxEOqyy")
                                                          .updateData({
                                                        "ratings": FieldValue
                                                            .arrayUnion([
                                                          {
                                                            "rating": value,
                                                            "uid": widget.userId
                                                          }
                                                        ]),
                                                      });
                                                    },
                                                  ),
                                                  FlatButton(
                                                    color: Colors.red,
                                                    child: Text("Cancel"),
                                                    onPressed: () {
                                                      setState(() {
                                                        value = _rating;
                                                        Navigator.of(context)
                                                            .pop();
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ));
                                        },
                                      )
                                    : RatingBar(
                                        initialRating: _rating != 0 &&
                                                !_rating.isNaN &&
                                                !_rating.isNegative &&
                                                _rating != null
                                            ? _rating
                                            : 0,
                                        minRating: _rating != 0 &&
                                                !_rating.isNaN &&
                                                !_rating.isNegative &&
                                                _rating != null
                                            ? 1
                                            : 0,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemPadding: EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: null,
                                      );
                              }),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            "Contact us at: infrastrucktor19@gmail.com",
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
