import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:infrastrucktor/core/models/admin-dashboard.dart';
import 'package:infrastrucktor/core/models/admin-delayed.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';
import 'package:infrastrucktor/core/viewmodels/about.dart';
import 'package:infrastrucktor/ui/widgets/menu.dart';

class AdminViewModel extends StatefulWidget {
  AdminViewModel(
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
  _AdminViewModelState createState() => _AdminViewModelState();
}

class _AdminViewModelState extends State<AdminViewModel> {
  PageController _pageController;
  int _currentIndex;
  @override
  void initState() {
    super.initState();

    _currentIndex = 0;
    _pageController =
        PageController(initialPage: _currentIndex, keepPage: true);
  }

  @override
  Widget build(BuildContext context) {
    final _menu = Menu(widget.db, widget.fs, widget.userEmail, widget.userId,
        widget.auth, widget.logoutCallback, context);

    return Scaffold(
      drawer: _menu.adminDrawer(),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        animationDuration: Duration(milliseconds: 350),
        height: 50.0,
        buttonBackgroundColor: Theme.of(context).accentColor,
        backgroundColor: Colors.black26,
        color: Theme.of(context).primaryColor,
        onTap: (index) {
          setState(() {
            _pageController.jumpToPage(index);
          });
        },
        items: <Widget>[
          Icon(Icons.local_library, size: 30, color: Colors.white),
          Icon(Icons.help, size: 30, color: Colors.white),
        ],
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(_currentIndex == 0 ? "Dashboard" : "About"),
        actions: <Widget>[
          StreamBuilder(
              stream: widget.db
                  .collection("projects")
                  .where("hasUpdate", isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                var data = snapshot.data == null ? [] : snapshot.data.documents;

                return data == null || data.length == 0
                    ? StreamBuilder(
                        stream: widget.db
                            .collection("projects")
                            .where("completed", isEqualTo: false)
                            .where("deadline", isLessThan: DateTime.now())
                            .snapshots(),
                        builder: (context, snapshot) {
                          data = snapshot.data == null
                              ? []
                              : snapshot.data.documents;

                          return data == null || data.length == 0
                              ? IconButton(
                                  icon: Icon(Icons.notifications),
                                  onPressed: () {},
                                )
                              : AvatarGlow(
                                  endRadius: 30.0,
                                  startDelay: Duration(milliseconds: 0),
                                  repeatPauseDuration:
                                      Duration(milliseconds: 0),
                                  curve: Curves.easeInOut,
                                  glowColor: Colors.red[700],
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.notifications_active,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NotifiedProjects(
                                                    auth: widget.auth,
                                                    db: widget.db,
                                                    fs: widget.fs,
                                                    userEmail: widget.userEmail,
                                                    userId: widget.userId,
                                                    logoutCallback:
                                                        widget.logoutCallback,
                                                  )));
                                    },
                                  ),
                                );
                        })
                    : AvatarGlow(
                        endRadius: 30.0,
                        startDelay: Duration(milliseconds: 0),
                        repeatPauseDuration: Duration(milliseconds: 0),
                        curve: Curves.easeInOut,
                        glowColor: Colors.red[700],
                        child: IconButton(
                          icon: Icon(
                            Icons.notifications_active,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => NotifiedProjects(
                                      auth: widget.auth,
                                      db: widget.db,
                                      fs: widget.fs,
                                      userEmail: widget.userEmail,
                                      userId: widget.userId,
                                      logoutCallback: widget.logoutCallback,
                                    )));
                          },
                        ),
                      );
              }),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: <Widget>[
          AdminDashboard(
            auth: widget.auth,
            db: widget.db,
            fs: widget.fs,
            logoutCallback: widget.logoutCallback,
            userEmail: widget.userEmail,
            userId: widget.userId,
          ),
          AboutApp(
            auth: widget.auth,
            db: widget.db,
            fs: widget.fs,
            logoutCallback: widget.logoutCallback,
            userEmail: widget.userEmail,
            userId: widget.userId,
          ),
        ],
      ),
    );
  }
}
