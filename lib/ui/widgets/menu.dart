import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:infrastrucktor/core/models/admin-administrators.dart';
import 'package:infrastrucktor/core/models/admin-contractors.dart';
import 'package:infrastrucktor/core/models/contractor-projects.dart';
import 'package:infrastrucktor/core/models/public-contractors.dart';
import 'package:infrastrucktor/core/models/public-projects.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';
import 'package:infrastrucktor/core/viewmodels/profile.dart';
import 'package:infrastrucktor/ui/views/dashboard.dart';
import 'package:infrastrucktor/ui/views/main-page.dart';
import 'package:infrastrucktor/ui/widgets/menuclipper.dart';
import 'package:flutter/material.dart';

class Menu {
  Menu(this.db, this.fs, this.userEmail, this.userId, this.auth,
      this.logoutCallback, this.context);

  final Firestore db;
  final FirebaseStorage fs;
  final String userEmail;
  final String userId;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final BuildContext context;
  String _img = "assets/logo.png";

  publicDrawer() {
    return ClipPath(
      clipper: MenuClipper(),
      child: Container(
        padding: EdgeInsets.only(left: 16.0, right: 40),
        decoration: BoxDecoration(
            color: Colors.teal[700],
            boxShadow: [BoxShadow(color: Colors.black45)]),
        width: 300.0,
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          child: StreamBuilder(
              stream: db
                  .collection("accounts")
                  .where("uid", isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                DocumentSnapshot data = snapshot.data.documents[0];

                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 40.0,
                      ),
                      Container(
                        height: 90,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                colors: [Colors.teal[200], Colors.teal[700]])),
                        child: CircleAvatar(
                          backgroundColor: Colors.teal[200],
                          radius: 40,
                          backgroundImage: AssetImage(_img),
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        data["firstname"] +
                            " " +
                            data["middlename"] +
                            " " +
                            data["lastname"],
                        style: TextStyle(color: Colors.white, fontSize: 18.0),
                      ),
                      Text(
                        data["email"],
                        style:
                            TextStyle(color: Colors.teal[200], fontSize: 16.0),
                      ),
                      SizedBox(height: 50.0),
                      _buildRow(
                          Icons.home,
                          "Dashboard",
                          DashboardMain(
                            auth: auth,
                            db: db,
                            fs: fs,
                            userId: userId,
                            userEmail: userEmail,
                            logoutCallback: logoutCallback,
                          )),
                      _buildDivider(),
                      _buildRow(
                          Icons.person_pin,
                          "Profile",
                          AccountProfile(
                            auth: auth,
                            db: db,
                            fs: fs,
                            userId: userId,
                            userEmail: userEmail,
                            logoutCallback: logoutCallback,
                            document: data,
                          )),
                      _buildDivider(),
                      _buildRow(
                          Icons.people,
                          "Contractors",
                          PublicContractors(
                            auth: auth,
                            db: db,
                            fs: fs,
                            userId: userId,
                            userEmail: userEmail,
                            logoutCallback: logoutCallback,
                          )),
                      _buildDivider(),
                      _buildRow(
                          Icons.library_books,
                          "Projects",
                          PublicProjects(
                            auth: auth,
                            db: db,
                            fs: fs,
                            userId: userId,
                            userEmail: userEmail,
                            logoutCallback: logoutCallback,
                          )),
                      _buildDivider(),
                      FlatButton(
                        onPressed: () {
                          auth.signOut();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DashboardScreen(
                                        auth: Auth(),
                                        db: Firestore.instance,
                                        fs: FirebaseStorage.instance,
                                      )));
                        },
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(children: [
                          Icon(Icons.exit_to_app, color: Colors.teal[200]),
                          SizedBox(width: 10.0),
                          Text(
                            "Logout",
                            style: TextStyle(
                                color: Colors.teal[200],
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                      ),
                      _buildDivider(),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  contractorDrawer() {
    return ClipPath(
      clipper: MenuClipper(),
      child: Container(
        padding: EdgeInsets.only(left: 16.0, right: 40),
        decoration: BoxDecoration(
            color: Colors.teal[700],
            boxShadow: [BoxShadow(color: Colors.black45)]),
        width: 300.0,
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          child: StreamBuilder(
              stream: db
                  .collection("accounts")
                  .where("uid", isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                DocumentSnapshot data = snapshot.data.documents[0];

                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 40.0,
                      ),
                      Container(
                        height: 90,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                colors: [Colors.teal[200], Colors.teal[700]])),
                        child: CircleAvatar(
                          backgroundColor: Colors.teal[200],
                          radius: 40,
                          backgroundImage: AssetImage(_img),
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        data["firstname"] +
                            " " +
                            data["middlename"] +
                            " " +
                            data["lastname"],
                        style: TextStyle(color: Colors.white, fontSize: 18.0),
                      ),
                      Text(
                        data["email"],
                        style:
                            TextStyle(color: Colors.teal[200], fontSize: 16.0),
                      ),
                      SizedBox(height: 50.0),
                      _buildRow(
                          Icons.home,
                          "Dashboard",
                          DashboardMain(
                            auth: auth,
                            db: db,
                            fs: fs,
                            userId: userId,
                            userEmail: userEmail,
                            logoutCallback: logoutCallback,
                          )),
                      _buildDivider(),
                      _buildRow(
                          Icons.person_pin,
                          "Profile",
                          AccountProfile(
                            auth: auth,
                            db: db,
                            fs: fs,
                            userId: userId,
                            userEmail: userEmail,
                            logoutCallback: logoutCallback,
                            document: data,
                          )),
                      _buildDivider(),
                      _buildRow(
                          Icons.list,
                          "Manage Projects",
                          ContractorProjects(
                            auth: auth,
                            db: db,
                            fs: fs,
                            userId: userId,
                            userEmail: userEmail,
                            logoutCallback: logoutCallback,
                          )),
                      _buildDivider(),
                      FlatButton(
                        onPressed: () {
                          auth.signOut();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DashboardScreen(
                                        auth: Auth(),
                                        db: Firestore.instance,
                                        fs: FirebaseStorage.instance,
                                      )));
                        },
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(children: [
                          Icon(Icons.exit_to_app, color: Colors.teal[200]),
                          SizedBox(width: 10.0),
                          Text(
                            "Logout",
                            style: TextStyle(
                                color: Colors.teal[200],
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                      ),
                      _buildDivider(),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  adminDrawer() {
    return ClipPath(
      clipper: MenuClipper(),
      child: Container(
        padding: EdgeInsets.only(left: 16.0, right: 40),
        decoration: BoxDecoration(
            color: Colors.teal[700],
            boxShadow: [BoxShadow(color: Colors.black45)]),
        width: 300.0,
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          child: StreamBuilder(
              stream: db
                  .collection("accounts")
                  .where("uid", isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                DocumentSnapshot data = snapshot.data.documents[0];

                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 40.0,
                      ),
                      Container(
                        height: 90,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                colors: [Colors.teal[200], Colors.teal[700]])),
                        child: CircleAvatar(
                          backgroundColor: Colors.teal[200],
                          radius: 40,
                          backgroundImage: AssetImage(_img),
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        data["firstname"] +
                            " " +
                            data["middlename"] +
                            " " +
                            data["lastname"],
                        style: TextStyle(color: Colors.white, fontSize: 18.0),
                      ),
                      Text(
                        data["email"],
                        style:
                            TextStyle(color: Colors.teal[200], fontSize: 16.0),
                      ),
                      SizedBox(height: 50.0),
                      _buildRow(
                          Icons.home,
                          "Dashboard",
                          DashboardMain(
                            auth: auth,
                            db: db,
                            fs: fs,
                            userId: userId,
                            userEmail: userEmail,
                            logoutCallback: logoutCallback,
                          )),
                      _buildDivider(),
                      _buildRow(
                          Icons.person_pin,
                          "Profile",
                          AccountProfile(
                            auth: auth,
                            db: db,
                            fs: fs,
                            userId: userId,
                            userEmail: userEmail,
                            logoutCallback: logoutCallback,
                            document: data,
                          )),
                      _buildDivider(),
                      _buildRow(
                          Icons.people,
                          "Contractors",
                          AdminContractors(
                            auth: auth,
                            db: db,
                            fs: fs,
                            userId: userId,
                            userEmail: userEmail,
                            logoutCallback: logoutCallback,
                          )),
                      _buildDivider(),
                      _buildRow(
                          Icons.supervised_user_circle,
                          "Administrators",
                          AdminAdministrators(
                            auth: auth,
                            db: db,
                            fs: fs,
                            userId: userId,
                            userEmail: userEmail,
                            logoutCallback: logoutCallback,
                          )),
                      _buildDivider(),
                      FlatButton(
                        onPressed: () {
                          auth.signOut();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DashboardScreen(
                                        auth: Auth(),
                                        db: Firestore.instance,
                                        fs: FirebaseStorage.instance,
                                      )));
                        },
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(children: [
                          Icon(Icons.exit_to_app, color: Colors.teal[200]),
                          SizedBox(width: 10.0),
                          Text(
                            "Logout",
                            style: TextStyle(
                                color: Colors.teal[200],
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ]),
                      ),
                      _buildDivider(),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  Divider _buildDivider() {
    return Divider(
      color: Colors.teal[200],
    );
  }

  Widget _buildRow(IconData icon, String title, Object page) {
    final TextStyle tStyle = TextStyle(color: Colors.teal[200], fontSize: 16.0);

    return FlatButton(
      onPressed: () {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) => page));
      },
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        Icon(icon, color: Colors.teal[200]),
        SizedBox(width: 10.0),
        Text(
          title,
          style: tStyle,
        ),
      ]),
    );
  }
}
