import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:infrastrucktor/core/models/manage-admin.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';
import 'package:infrastrucktor/core/viewmodels/profile.dart';
import 'package:infrastrucktor/ui/widgets/menu.dart';

class AdminAdministrators extends StatefulWidget {
  AdminAdministrators(
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
  _AdminAdministratorsState createState() => _AdminAdministratorsState();
}

class _AdminAdministratorsState extends State<AdminAdministrators> {
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
      drawer: _menu.adminDrawer(),
      appBar: AppBar(
        title: Text("Administrators"),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ManageAdmin(
                    auth: widget.auth,
                    db: widget.db,
                    fs: widget.fs,
                  )));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(children: <Widget>[
          StreamBuilder(
            stream: widget.db
                .collection("accounts")
                .where("permission", isEqualTo: 0)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              var data = snapshot.data.documents;
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, i) {
                  if (_searchCtrl.text.isNotEmpty) {
                    if (data[i]['firstname'].contains(_searchCtrl.text) ||
                        data[i]['middlename'].contains(_searchCtrl.text) ||
                        data[i]['lastname'].contains(_searchCtrl.text)) {
                      return Card(
                        elevation: 5.0,
                        child: InkWell(
                          splashColor: Theme.of(context).primaryColor,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AccountProfile(
                                      auth: widget.auth,
                                      db: widget.db,
                                      fs: widget.fs,
                                      logoutCallback: widget.logoutCallback,
                                      userEmail: widget.userEmail,
                                      userId: data[i]["uid"],
                                      document: data[i],
                                    )));
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 18.0),
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
                                data[i]["firstname"] +
                                    " " +
                                    data[i]["middlename"] +
                                    " " +
                                    data[i]["lastname"],
                                textScaleFactor: 1.5,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  } else {
                    return Card(
                      elevation: 5.0,
                      child: InkWell(
                        splashColor: Theme.of(context).primaryColor,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AccountProfile(
                                    auth: widget.auth,
                                    db: widget.db,
                                    fs: widget.fs,
                                    logoutCallback: widget.logoutCallback,
                                    userEmail: widget.userEmail,
                                    userId: data[i]["uid"],
                                    document: data[i],
                                  )));
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 18.0),
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
                              data[i]["firstname"] +
                                  " " +
                                  data[i]["middlename"] +
                                  " " +
                                  data[i]["lastname"],
                              textScaleFactor: 1.5,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return Text(
                    "No results",
                    textAlign: TextAlign.center,
                  );
                },
              );
            },
          ),
        ]),
      ),
    );
  }
}
