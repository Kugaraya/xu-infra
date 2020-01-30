import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
                    applicationVersion: "1.0b");
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
                  subtitle: Text("1.0b",
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
