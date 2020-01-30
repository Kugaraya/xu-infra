import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';

class AdminDashboard extends StatefulWidget {
  AdminDashboard(
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
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: StreamBuilder(
          stream: widget.db
              .collection("accounts")
              .where("uid", isEqualTo: widget.userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            DocumentSnapshot data = snapshot.data.documents[0];

            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      "Welcome, " + data["firstname"] + " " + data["lastname"],
                      textScaleFactor: 1.3,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      formatDate(
                          DateTime.now(), [DD, " - ", MM, " ", dd, ", ", yyyy]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  Divider(
                    color: Colors.black45,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    child: Container(
                      height: 100.0,
                      color: Colors.blueGrey,
                      child: Center(
                        child: ListTile(
                          leading: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                            ),
                          ),
                          trailing: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            'Actions',
                            style: TextStyle(color: Colors.white),
                            textScaleFactor: 1.5,
                            textAlign: TextAlign.center,
                          ),
                          subtitle: Text(
                            'Swipe left/right',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      IconSlideAction(
                        caption: 'Projects',
                        color: Colors.blue,
                        icon: Icons.search,
                        onTap: () {},
                      ),
                    ],
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: 'Contractors',
                        color: Colors.red,
                        icon: Icons.people,
                        onTap: () {},
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  Text(
                    "Project Status",
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.5,
                  ),
                  Divider(
                    color: Colors.black45,
                    height: 20,
                    thickness: 2,
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text("1"),
                    ),
                    trailing: Icon(Icons.chevron_right),
                    title: Text(
                      "Ongoing",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(
                    color: Colors.black45,
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Text("1"),
                    ),
                    trailing: Icon(Icons.chevron_right),
                    title: Text(
                      "Finished",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(
                    color: Colors.black45,
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.yellow,
                      child: Text("1"),
                    ),
                    trailing: Icon(Icons.chevron_right),
                    title: Text(
                      "Delayed",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Divider(
                    color: Colors.black45,
                  ),
                ],
              ),
            );
          }),
    );
  }
}
