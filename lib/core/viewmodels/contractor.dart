import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:infrastrucktor/core/models/contractor-dashboard.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';
import 'package:infrastrucktor/core/viewmodels/about.dart';
import 'package:infrastrucktor/ui/widgets/menu.dart';

class ContractorViewModel extends StatefulWidget {
  ContractorViewModel(
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
  _ContractorViewModelState createState() => _ContractorViewModelState();
}

class _ContractorViewModelState extends State<ContractorViewModel> {
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
      drawer: _menu.contractorDrawer(),
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
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: <Widget>[
          ContractorDashboard(
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
