import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';

class ProjectUpdates extends StatefulWidget {
  ProjectUpdates(
      {Key key, this.db, this.userEmail, this.userId, this.auth, this.document})
      : super(key: key);

  final DocumentSnapshot document;
  final Firestore db;
  final String userEmail;
  final String userId;
  final BaseAuth auth;

  @override
  _ProjectUpdatesState createState() => _ProjectUpdatesState();
}

class _ProjectUpdatesState extends State<ProjectUpdates> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Updates"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder(
                  stream: widget.db
                      .collection("projects")
                      .document(widget.document.documentID)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 100,
                          ),
                          CircularProgressIndicator(),
                        ],
                      ));
                    }
                    var data = snapshot.data;

                    return Column(
                      children: <Widget>[
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: data["updates"].length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            return Card(
                              color:
                                  widget.userId == data["updates"][index]["uid"]
                                      ? Colors.yellow[100]
                                      : Colors.white,
                              child: ListTile(
                                leading: Column(
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor: widget.userId ==
                                              data["updates"][index]["uid"]
                                          ? Colors.blue[200]
                                          : Theme.of(context).accentColor,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ),
                                    StreamBuilder(
                                        stream: widget.db
                                            .collection("accounts")
                                            .where("uid",
                                                isEqualTo: data["updates"]
                                                    [index]["uid"])
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData ||
                                              snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }

                                          var data = snapshot.data.documents[0];

                                          return Text(data["firstname"]);
                                        }),
                                  ],
                                ),
                                title: Text(data["updates"][index]["update"]),
                                subtitle: Text(formatDate(
                                    (data["updates"][index]["time"]
                                            as Timestamp)
                                        .toDate(),
                                    [
                                      hh,
                                      ":",
                                      mm,
                                      " ",
                                      am,
                                      " - ",
                                      MM,
                                      " ",
                                      dd,
                                      ", ",
                                      yyyy
                                    ])),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
