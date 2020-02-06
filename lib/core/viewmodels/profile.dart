import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';
import 'package:infrastrucktor/core/viewmodels/update-profile.dart';
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
    return StreamBuilder(
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
          double _intRating = 0;
          double _rating = 0;
          if (data["feedback"].isNotEmpty) {
            for (var i = 0; i < data["feedback"].length; i++) {
              _intRating += data["feedback"][i]["rating"];
            }
            _rating = _intRating / data["feedback"].length;
          }
          return Scaffold(
              key: _scaffoldKey,
              drawer: Navigator.of(context).canPop()
                  ? null
                  : data["permission"] == 0
                      ? _menu.adminDrawer()
                      : data["permission"] == 1
                          ? _menu.contractorDrawer()
                          : _menu.publicDrawer(),
              floatingActionButton: StreamBuilder(
                  stream: widget.db
                      .collection("accounts")
                      .where("uid", isEqualTo: widget.userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData ||
                        ConnectionState.waiting == snapshot.connectionState) {
                      return Container();
                    }
                    var _data = snapshot.data.documents[0];
                    return Navigator.of(context).canPop() &&
                            _data["permission"] == 0
                        ? FloatingActionButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => UpdateProfile(
                                        auth: widget.auth,
                                        db: widget.db,
                                        document: data,
                                        fs: widget.fs,
                                        logoutCallback: widget.logoutCallback,
                                        userEmail: widget.userEmail,
                                        userId: widget.userId,
                                      )));
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          )
                        : !Navigator.of(context).canPop()
                            ? FloatingActionButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => UpdateProfile(
                                            auth: widget.auth,
                                            db: widget.db,
                                            document: data,
                                            fs: widget.fs,
                                            logoutCallback:
                                                widget.logoutCallback,
                                            userEmail: widget.userEmail,
                                            userId: widget.userId,
                                          )));
                                },
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              )
                            : Container();
                  }),
              body: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
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
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(data["prefix"] +
                              " " +
                              data["firstname"] +
                              " " +
                              data["middlename"] +
                              " " +
                              data["lastname"]),
                          Text(data["suffix"].isNotEmpty
                              ? ", " + data["suffix"]
                              : ""),
                        ],
                      ),
                      centerTitle: true,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 30.0),
                        Text(
                          "Profile Info",
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
                          title: Text(data["contact"].toString().isNotEmpty &&
                                  data["contact"] != 0
                              ? "+63" + data["contact"].toString()
                              : "+63"),
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
                              RatingBar(
                                initialRating: _rating,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding:
                                    EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: null,
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
                              StreamBuilder(
                                  stream: widget.db
                                      .collection("projects")
                                      .where("completed", isEqualTo: false)
                                      .where("start",
                                          isLessThan: DateTime.now())
                                      .where("contractor",
                                          isEqualTo: widget.document["uid"])
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    var data = snapshot.data == null
                                        ? []
                                        : snapshot.data.documents;

                                    return InkWell(
                                      onTap: () {},
                                      splashColor:
                                          Theme.of(context).primaryColor,
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
                                      .where("contractor",
                                          isEqualTo: widget.document["uid"])
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    var data = snapshot.data == null
                                        ? []
                                        : snapshot.data.documents;

                                    return InkWell(
                                      onTap: () {},
                                      splashColor:
                                          Theme.of(context).primaryColor,
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
                                      .where("deadline",
                                          isLessThan: DateTime.now())
                                      .where("contractor",
                                          isEqualTo: widget.document["uid"])
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    var data = snapshot.data == null
                                        ? []
                                        : snapshot.data.documents;

                                    return InkWell(
                                      onTap: () {},
                                      splashColor:
                                          Theme.of(context).primaryColor,
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
                              StreamBuilder(
                                  stream: widget.db
                                      .collection("projects")
                                      .where("contractor",
                                          isEqualTo: widget.document["uid"])
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    var data = snapshot.data == null
                                        ? []
                                        : snapshot.data.documents;

                                    return InkWell(
                                      onTap: () {},
                                      splashColor:
                                          Theme.of(context).primaryColor,
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.teal,
                                          child: Text(data.length.toString()),
                                        ),
                                        trailing: Icon(Icons.chevron_right),
                                        title: Text(
                                          "Total Projects",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  }),
                              Divider(
                                color: Colors.black45,
                              ),
                              SizedBox(
                                height: 50.0,
                              ),
                            ],
                          ),
                        )
                      : SliverToBoxAdapter(
                          child: Container(),
                        ),
                  Navigator.of(context).canPop() && data["permission"] == 1
                      ? SliverToBoxAdapter(
                          child: Column(
                            children: <Widget>[
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
                        )
                ],
              ));
        });
  }
}
