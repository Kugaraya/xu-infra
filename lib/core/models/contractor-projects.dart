import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:infrastrucktor/core/models/contractor-project.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';
import 'package:infrastrucktor/core/viewmodels/add-project.dart';
import 'package:infrastrucktor/ui/widgets/menu.dart';

class ContractorProjects extends StatefulWidget {
  ContractorProjects(
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
  _ContractorProjects createState() => _ContractorProjects();
}

class _ContractorProjects extends State<ContractorProjects> {
  TextEditingController _searchCtrl = TextEditingController();
  bool _activeSearch = false;

  Widget _search() {
    return TextField(
      controller: _searchCtrl,
      autofocus: true,
      onChanged: (text) {
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: "Search name",
        border: OutlineInputBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.0),
                bottomLeft: Radius.circular(32.0))),
        prefixIcon: Icon(Icons.search, color: Colors.blueGrey),
        suffixIcon: IconButton(
          icon: Icon(Icons.cancel, color: Colors.black),
          onPressed: () => setState(() {
            _searchCtrl.clear();
            _activeSearch = false;
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _menu = Menu(widget.db, widget.fs, widget.userEmail, widget.userId,
        widget.auth, widget.logoutCallback, context);
    return Scaffold(
      drawer: Navigator.of(context).canPop() ? null : _menu.contractorDrawer(),
      appBar: AppBar(
        title: Text("Projects"),
        actions: <Widget>[
          _activeSearch
              ? Container(
                  width: MediaQuery.of(context).size.width * 0.60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32.0),
                        bottomLeft: Radius.circular(32.0)),
                    color: Colors.white,
                  ),
                  child: _search())
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => setState(() => _activeSearch = true),
                )
        ],
      ),
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
              stream: widget.db.collection("projects").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                var data = snapshot.data.documents;
                return data.length > 0
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (context, i) {
                          if (_searchCtrl.text.isNotEmpty) {
                            if (data[i]['name'].contains(_searchCtrl.text) ||
                                data[i]['id'].contains(_searchCtrl.text)) {
                              return Container(
                                height: 100.0,
                                child: Card(
                                  elevation: 5.0,
                                  child: InkWell(
                                    splashColor: Theme.of(context).primaryColor,
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ContractorProjectView(
                                                    auth: widget.auth,
                                                    db: widget.db,
                                                    document: data[i],
                                                    userEmail: widget.userEmail,
                                                    userId: widget.userId,
                                                  )));
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 14.0),
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
                                            ? Text(
                                                "Project ID: " + data[i]["id"])
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          } else {
                            return Container(
                              height: 100.0,
                              child: Card(
                                elevation: 5.0,
                                child: InkWell(
                                  splashColor: Theme.of(context).primaryColor,
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ContractorProjectView(
                                                  auth: widget.auth,
                                                  db: widget.db,
                                                  document: data[i],
                                                  userEmail: widget.userEmail,
                                                  userId: widget.userId,
                                                )));
                                  },
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 14.0),
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
                          }
                          return Text(
                            "No results",
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.3,
                          );
                        },
                      )
                    : Center(
                        child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            "There are no registered projects,",
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.1,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Add a project by pressing the button below",
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.1,
                          ),
                        ],
                      ));
              },
            ),
          ]),
        ),
      ),
    );
  }
}
