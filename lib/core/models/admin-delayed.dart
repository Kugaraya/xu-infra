import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:infrastrucktor/core/models/admin-project.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';
import 'package:infrastrucktor/core/viewmodels/add-project.dart';
import 'package:infrastrucktor/ui/widgets/menu.dart';

class NotifiedProjects extends StatefulWidget {
  NotifiedProjects(
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
  _NotifiedProjects createState() => _NotifiedProjects();
}

class _NotifiedProjects extends State<NotifiedProjects> {
  TextEditingController _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _menu = Menu(widget.db, widget.fs, widget.userEmail, widget.userId,
        widget.auth, widget.logoutCallback, context);
    return Scaffold(
      drawer: Navigator.of(context).canPop() ? null : _menu.contractorDrawer(),
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      floatingActionButton: StreamBuilder(
          stream: widget.db
              .collection("accounts")
              .where("uid", isEqualTo: widget.userId)
              .snapshots(),
          builder: (context, snapshot) {
            var data = snapshot.data.documents[0];
            return data["permission"] == 1
                ? FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AddProject(
                                auth: widget.auth,
                                db: widget.db,
                                userEmail: widget.userEmail,
                                userId: widget.userId,
                              )));
                    },
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  )
                : Container();
          }),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            StreamBuilder(
              stream: widget.db
                  .collection("projects")
                  .where("hasUpdate", isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                var data = snapshot.data.documents;
                return Column(
                  children: <Widget>[
                    data.length != 0 ? Text("Recently Updated") : Container(),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (context, i) {
                          return Container(
                            height: 100.0,
                            child: Card(
                              elevation: 5.0,
                              child: InkWell(
                                splashColor: Theme.of(context).primaryColor,
                                onTap: () async {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => AdminProjectView(
                                            auth: widget.auth,
                                            db: widget.db,
                                            document: data[i],
                                            userEmail: widget.userEmail,
                                            userId: widget.userId,
                                          )));
                                  await widget.db
                                      .collection("projects")
                                      .document(data[i].documentID)
                                      .updateData({"hasUpdate": false});
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14.0),
                                  child: ListTile(
                                    leading: Container(
                                      child: Image.asset("assets/logo.png"),
                                    ),
                                    trailing: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.chevron_right,
                                      ),
                                    ),
                                    title: Text(
                                      data[i]["name"],
                                      textScaleFactor: 1.5,
                                    ),
                                    subtitle: data[i]["id"].isNotEmpty
                                        ? Text("Project ID: " + data[i]["id"])
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                    data.length != 0
                        ? SizedBox(
                            height: 25,
                          )
                        : Container(),
                  ],
                );
              },
            ),
            StreamBuilder(
              stream: widget.db
                  .collection("projects")
                  .where("deadline", isLessThan: DateTime.now())
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                var data = snapshot.data.documents;
                return Column(
                  children: <Widget>[
                    data.length != 0 ? Text("Delayed Projects") : Container(),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (context, i) {
                          return Container(
                            height: 100.0,
                            child: Card(
                              elevation: 5.0,
                              child: InkWell(
                                splashColor: Theme.of(context).primaryColor,
                                onTap: () async {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => AdminProjectView(
                                            auth: widget.auth,
                                            db: widget.db,
                                            document: data[i],
                                            userEmail: widget.userEmail,
                                            userId: widget.userId,
                                          )));
                                  await widget.db
                                      .collection("projects")
                                      .document(data[i].documentID)
                                      .updateData({"hasUpdate": false});
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14.0),
                                  child: ListTile(
                                    leading: Container(
                                      child: Image.asset("assets/logo.png"),
                                    ),
                                    trailing: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.chevron_right,
                                      ),
                                    ),
                                    title: Text(
                                      data[i]["name"],
                                      textScaleFactor: 1.5,
                                    ),
                                    subtitle: data[i]["id"].isNotEmpty
                                        ? Text("Project ID: " + data[i]["id"])
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ],
                );
              },
            ),
          ]),
        ),
      ),
    );
  }
}
