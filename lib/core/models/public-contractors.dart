import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';
import 'package:infrastrucktor/core/viewmodels/profile.dart';
import 'package:infrastrucktor/ui/widgets/menu.dart';

class PublicContractors extends StatefulWidget {
  PublicContractors(
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
  _PublicContractorsState createState() => _PublicContractorsState();
}

class _PublicContractorsState extends State<PublicContractors> {
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
      drawer: Navigator.of(context).canPop() ? null : _menu.publicDrawer(),
      appBar: AppBar(
        title: Text("Contractors"),
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
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(children: <Widget>[
          StreamBuilder(
            stream: widget.db
                .collection("accounts")
                .where("permission", isEqualTo: 1)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              var data = snapshot.data.documents;
              return data.length > 0
                  ? ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: data.length,
                      itemBuilder: (context, i) {
                        if (_searchCtrl.text.isNotEmpty) {
                          if (data[i]['firstname'].contains(_searchCtrl.text) ||
                              data[i]['middlename']
                                  .contains(_searchCtrl.text) ||
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
                                            logoutCallback:
                                                widget.logoutCallback,
                                            userEmail: widget.userEmail,
                                            userId: widget.userId,
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
                                          userId: widget.userId,
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
                          "There are no registered contractors,",
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.1,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Register a contractor by pressing the button below",
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.1,
                        ),
                      ],
                    ));
            },
          ),
        ]),
      ),
    );
  }
}
