import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';

class ProfileComments extends StatefulWidget {
  ProfileComments(
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
  _ProfileCommentsState createState() => _ProfileCommentsState();
}

class _ProfileCommentsState extends State<ProfileComments> {
  final _formKey = GlobalKey<FormState>();
  String _comment;

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        _formKey.currentState.reset();
        await widget.db
            .collection("accounts")
            .document(widget.document.documentID)
            .updateData({
          "feedback": FieldValue.arrayUnion([
            {"content": _comment, "time": DateTime.now(), "uid": widget.userId}
          ])
        });

        Fluttertoast.showToast(
            msg: "Comment added",
            backgroundColor: Colors.black54,
            textColor: Colors.white);
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Unexpected error",
            backgroundColor: Colors.black54,
            textColor: Colors.white);
        setState(() {
          _formKey.currentState.reset();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Card(
                  elevation: 5.0,
                  child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                            child: TextFormField(
                              maxLines: 3,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              decoration: InputDecoration(
                                  labelText: 'Comment',
                                  icon: Icon(
                                    Icons.insert_comment,
                                    color: Colors.grey,
                                  )),
                              validator: (value) => value.isEmpty
                                  ? 'Comment can\'t be empty'
                                  : null,
                              onSaved: (value) => _comment = value.trim(),
                              onChanged: (value) => _comment = value.trim(),
                            ),
                          ),
                          FlatButton(
                            onPressed: validateAndSubmit,
                            color: Theme.of(context).primaryColor,
                            textColor: Colors.white,
                            child: Text("Add Comment"),
                          )
                        ],
                      ))),
              StreamBuilder(
                  stream: widget.db
                      .collection("accounts")
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
                          itemCount: data["feedback"].length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            return Card(
                              color: widget.userId ==
                                      data["feedback"][index]["uid"]
                                  ? Colors.yellow[100]
                                  : Colors.white,
                              child: ListTile(
                                leading: Column(
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundColor: widget.userId ==
                                              data["feedback"][index]["uid"]
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
                                                isEqualTo: data["feedback"]
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
                                title: Text(data["feedback"][index]["content"]),
                                subtitle: Text(formatDate(
                                    (data["feedback"][index]["time"]
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
