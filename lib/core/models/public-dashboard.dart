import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:infrastrucktor/core/models/public-contractors.dart';
import 'package:infrastrucktor/core/models/public-projects.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';

class PublicDashboard extends StatefulWidget {
  PublicDashboard(
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
  _PublicDashboardState createState() => _PublicDashboardState();
}

class _PublicDashboardState extends State<PublicDashboard> {
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
              physics: BouncingScrollPhysics(),
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
                      child: Card(
                        elevation: 5.0,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: ListTile(
                            leading: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.chevron_left,
                              ),
                            ),
                            trailing: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.chevron_right,
                              ),
                            ),
                            title: Text(
                              'View',
                              textScaleFactor: 1.6,
                              textAlign: TextAlign.center,
                            ),
                            subtitle: Text(
                              'Swipe left/right',
                              textScaleFactor: 1.2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      IconSlideAction(
                        caption: 'Projects',
                        color: Colors.blue,
                        icon: Icons.search,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PublicProjects(
                                      auth: widget.auth,
                                      db: widget.db,
                                      fs: widget.fs,
                                      userEmail: widget.userEmail,
                                      userId: widget.userId,
                                      logoutCallback: widget.logoutCallback)));
                        },
                      ),
                    ],
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: 'Contractors',
                        color: Colors.red,
                        icon: Icons.people,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PublicContractors(
                                    auth: widget.auth,
                                    db: widget.db,
                                    fs: widget.fs,
                                    userId: widget.userId,
                                    userEmail: widget.userEmail,
                                    logoutCallback: widget.logoutCallback,
                                  )));
                        },
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
                  StreamBuilder(
                      stream: widget.db
                          .collection("projects")
                          .where("completed", isEqualTo: false)
                          .where("start", isLessThan: DateTime.now())
                          .snapshots(),
                      builder: (context, snapshot) {
                        var data = snapshot.data == null
                            ? []
                            : snapshot.data.documents;

                        return InkWell(
                          onTap: () {},
                          splashColor: Theme.of(context).primaryColor,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(data.length.toString()),
                            ),
                            trailing: Icon(Icons.chevron_right),
                            title: Text(
                              "Ongoing",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }),
                  Divider(
                    color: Colors.black45,
                  ),
                  StreamBuilder(
                      stream: widget.db
                          .collection("projects")
                          .where("completed", isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        var data = snapshot.data == null
                            ? []
                            : snapshot.data.documents;

                        return InkWell(
                          onTap: () {},
                          splashColor: Theme.of(context).primaryColor,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Text(data.length.toString()),
                            ),
                            trailing: Icon(Icons.chevron_right),
                            title: Text(
                              "Finished",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }),
                  Divider(
                    color: Colors.black45,
                  ),
                  StreamBuilder(
                      stream: widget.db
                          .collection("projects")
                          .where("completed", isEqualTo: false)
                          .where("deadline", isLessThan: DateTime.now())
                          .snapshots(),
                      builder: (context, snapshot) {
                        var data = snapshot.data == null
                            ? []
                            : snapshot.data.documents;

                        return InkWell(
                          onTap: () {},
                          splashColor: Theme.of(context).primaryColor,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.yellow,
                              child: Text(data.length.toString()),
                            ),
                            trailing: Icon(Icons.chevron_right),
                            title: Text(
                              "Delayed",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }),
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
