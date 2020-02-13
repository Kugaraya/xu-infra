import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';

class ProjectUpdate extends StatefulWidget {
  ProjectUpdate(
      {Key key, this.document, this.db, this.userEmail, this.userId, this.auth})
      : super(key: key);

  final DocumentSnapshot document;
  final Firestore db;
  final String userEmail;
  final String userId;
  final BaseAuth auth;

  @override
  _ProjectUpdateState createState() => _ProjectUpdateState();
}

class _ProjectUpdateState extends State<ProjectUpdate> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _comment = "";
  bool _isLoading;

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
      setState(() {
        _isLoading = true;
      });

      try {
        await widget.db
            .collection("projects")
            .document(widget.document.documentID)
            .updateData({
          "hasUpdate": true,
          "updates": FieldValue.arrayUnion([
            {"update": _comment, "uid": widget.userId, "time": DateTime.now()}
          ])
        });

        setState(() {
          _isLoading = false;
        });

        _formKey.currentState.reset();
        Fluttertoast.showToast(
            msg: "Added an update",
            textColor: Colors.white,
            backgroundColor: Colors.black54);
        Navigator.pop(context);
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _formKey.currentState.reset();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("Add Project Update")),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 150.0,
                    child: Card(
                      elevation: 5.0,
                      child: TextFormField(
                        enabled: _isLoading ? false : true,
                        onChanged: (text) {
                          setState(() {
                            _comment = text;
                          });
                        },
                        onEditingComplete: () {
                          print(_comment);
                        },
                        maxLines: null,
                        minLines: null,
                        expands: true,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 10.0),
                            labelText: "Update Content"),
                        validator: (value) => value.isEmpty
                            ? 'Update content can\'t be empty'
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  _isLoading
                      ? CircularProgressIndicator()
                      : RaisedButton(
                          onPressed: validateAndSubmit,
                          elevation: 5.0,
                          child: Text("Submit"),
                        ),
                  StreamBuilder(
                      stream: widget.db
                          .collection("projects")
                          .document(widget.document.documentID)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                                  color: widget.userId ==
                                          data["updates"][index]["uid"]
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

                                              var data =
                                                  snapshot.data.documents[0];

                                              return Text(data["firstname"]);
                                            }),
                                      ],
                                    ),
                                    title:
                                        Text(data["updates"][index]["update"]),
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
        ),
      ),
    );
  }
}
