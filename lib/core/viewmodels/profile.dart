import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';
import 'package:infrastrucktor/ui/widgets/menu.dart';

class AccountProfile extends StatefulWidget {
  AccountProfile(
      {Key key,
      this.userEmail,
      this.userId,
      this.auth,
      this.logoutCallback,
      this.db,
      this.fs,
      this.document})
      : super(key: key);

  final Firestore db;
  final FirebaseStorage fs;
  final String userEmail;
  final String userId;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final DocumentSnapshot document;
  @override
  _AccountProfileState createState() => _AccountProfileState();
}

class _AccountProfileState extends State<AccountProfile> {
  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    final _menu = Menu(widget.db, widget.fs, widget.userEmail, widget.userId,
        widget.auth, widget.logoutCallback, context);
    return Scaffold(
        key: _scaffoldKey,
        drawer: Navigator.of(context).canPop() ? null : _menu.adminDrawer(),
        body: StreamBuilder(
            stream: widget.db
                .collection("accounts")
                .where("uid", isEqualTo: widget.document["uid"])
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              DocumentSnapshot data = snapshot.data.documents[0];
              return CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    // TODO : multiple drawers
                    leading: Navigator.of(context).canPop()
                        ? null
                        : IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _scaffoldKey.currentState.openDrawer();
                            },
                          ),
                    expandedHeight: 200.0,
                    pinned: true,
                    actions: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 24,
                        backgroundImage: AssetImage("assets/logo.png"),
                      )
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.asset(
                        "assets/cover.png",
                        fit: BoxFit.cover,
                      ),
                      title: Text("Profile"),
                      centerTitle: true,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 30.0),
                        Text(
                          data["firstname"] +
                              " " +
                              data["middlename"] +
                              " " +
                              data["lastname"] +
                              " " +
                              data["suffix"],
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.5,
                        ),
                        Divider(
                          color: Colors.blueGrey,
                          thickness: 2.0,
                        ),
                        ListTile(
                            leading: Icon(Icons.build),
                            title: Text(data["permission"] == 0
                                ? "Administrator"
                                : data["permission"] == 1
                                    ? "Contractor"
                                    : "Public User")),
                        ListTile(
                          leading: Icon(MaterialIcons.contacts),
                          title: Text(data["age"].toString() + " years old"),
                        ),
                        ListTile(
                          leading: Icon(MaterialIcons.email),
                          title: Text(data["email"]),
                        ),
                        ListTile(
                          leading: Icon(MaterialIcons.phone),
                          title: Text(data["contact"].toString()),
                        ),
                        ListTile(
                          leading: Icon(MaterialIcons.person),
                          title: Text(data["gender"]),
                        ),
                      ],
                    ),
                  ),
                  data["permission"] == 1
                      ? SliverToBoxAdapter(
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                leading: Icon(MaterialIcons.thumbs_up_down),
                                title: Text(
                                  "Overall Rating(%): 100",
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                              SizedBox(
                                height: 50.0,
                              ),
                              Text(
                                "Projects",
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
                                title: Text(
                                  "Delayed",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Divider(
                                color: Colors.black45,
                              ),
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal,
                                  child: Text("3"),
                                ),
                                title: Text(
                                  "Total Projects",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Divider(
                                color: Colors.black45,
                              ),
                              SizedBox(
                                height: 50.0,
                              ),
                              InkWell(
                                splashColor: Theme.of(context).primaryColor,
                                onTap: () {},
                                child: Container(
                                  height: 72.0,
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1.5, color: Colors.blueGrey)),
                                  child: ListTile(
                                    leading: Icon(Icons.comment),
                                    title: Text(
                                      "See Comments",
                                      textAlign: TextAlign.center,
                                      textScaleFactor: 1.5,
                                    ),
                                    trailing: Icon(Icons.chevron_right),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              )
                            ],
                          ),
                        )
                      : SliverToBoxAdapter(
                          child: Container(),
                        ),
                ],
              );
            }));
  }
}
