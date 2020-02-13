import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:infrastrucktor/core/models/project-comments.dart';
import 'package:infrastrucktor/core/models/project-edit.dart';
import 'package:infrastrucktor/core/models/project-update.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ContractorProjectView extends StatefulWidget {
  ContractorProjectView(
      {Key key, this.db, this.userEmail, this.userId, this.auth, this.document})
      : super(key: key);

  final DocumentSnapshot document;
  final Firestore db;
  final String userEmail;
  final String userId;
  final BaseAuth auth;

  @override
  _ContractorProjectViewState createState() => _ContractorProjectViewState();
}

const String MIN_DATETIME = '1970-01-01';

class _ContractorProjectViewState extends State<ContractorProjectView> {
  PanelController _panelCtrl = PanelController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  DateTime _projectComplete;
  String _format = 'yyyy-MMMM-dd';
  double _rating = 0;
  double _initRating = 0;

  @override
  void initState() {
    super.initState();
    if (widget.document["ratings"] != null) {
      for (var i = 0; i < widget.document["ratings"].length; i++) {
        _initRating += widget.document["ratings"][i]["rating"].toDouble();
      }
      _rating = _initRating / widget.document["ratings"].length;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("IRate: " + _initRating.toString());
    print("Rate: " + _rating.toString());
    CameraPosition _kLocation = CameraPosition(
      target: LatLng(widget.document["location"].latitude,
          widget.document["location"].longitude),
      zoom: 18.4746,
    );
    Map<MarkerId, Marker> markers = <MarkerId, Marker>{
      MarkerId(widget.document.documentID): Marker(
          markerId: MarkerId(widget.document.documentID),
          position: LatLng(widget.document["location"].latitude,
              widget.document["location"].longitude),
          infoWindow: InfoWindow(
              title: widget.document["address"],
              snippet: widget.document["location"].latitude.toString() +
                  ", " +
                  widget.document["location"].longitude.toString()))
    };
    Widget mapLocation() {
      return Column(
        children: <Widget>[
          Expanded(
            child: GoogleMap(
              markers: Set<Marker>.of(markers.values),
              mapType: MapType.normal,
              initialCameraPosition: _kLocation,
              myLocationEnabled: true,
              compassEnabled: true,
              trafficEnabled: true,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          SizedBox(height: 155.0)
        ],
      );
    }

    Widget contractor() {
      return ListTile(
        leading: Icon(Icons.person, size: 32),
        title: StreamBuilder(
          stream: widget.db
              .collection("accounts")
              .where("uid", isEqualTo: widget.document["contractor"])
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            return Row(
              children: <Widget>[
                Text(snapshot.data.documents[0]["prefix"] +
                    " " +
                    snapshot.data.documents[0]["firstname"] +
                    " " +
                    snapshot.data.documents[0]["middlename"] +
                    " " +
                    snapshot.data.documents[0]["lastname"]),
                Text(snapshot.data.documents[0]["suffix"].isNotEmpty
                    ? ", " + snapshot.data.documents[0]["suffix"]
                    : "")
              ],
            );
          },
        ),
        subtitle: StreamBuilder(
          stream: widget.db
              .collection("accounts")
              .where("uid", isEqualTo: widget.document["contractor"])
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            return Text(snapshot.data.documents[0]["permission"] == 0
                ? "Administrator"
                : snapshot.data.documents[0]["permission"] == 1
                    ? "Contractor"
                    : "Public User");
          },
        ),
      );
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.document["name"]),
          actions: widget.document["completed"] == false
              ? <Widget>[
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProjectEdit(
                                auth: widget.auth,
                                db: widget.db,
                                document: widget.document,
                                userEmail: widget.userEmail,
                                userId: widget.userId,
                              )));
                    },
                    icon: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.white,
                              style: BorderStyle.solid,
                              width: 1.66),
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: Icon(Icons.edit, color: Colors.white)),
                  )
                ]
              : null,
        ),
        floatingActionButton: StreamBuilder(
            stream: widget.db
                .collection("accounts")
                .where("uid", isEqualTo: widget.userId)
                .snapshots(),
            builder: (context, snapshot) {
              var data = snapshot.data == null
                  ? {"permission": 2}
                  : snapshot.data.documents[0];
              return data["permission"] == 1
                  ? FloatingActionButton(
                      child: Icon(Icons.update, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProjectUpdate(
                                  auth: widget.auth,
                                  db: widget.db,
                                  document: widget.document,
                                  userEmail: widget.userEmail,
                                  userId: widget.userId,
                                )));
                      },
                    )
                  : Container();
            }),
        body: SlidingUpPanel(
          parallaxEnabled: true,
          parallaxOffset: 0.6,
          controller: _panelCtrl,
          minHeight: 80.0,
          body: mapLocation(),
          panel: SingleChildScrollView(
              child: Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  _panelCtrl.isPanelOpen()
                      ? _panelCtrl.close()
                      : _panelCtrl.open();
                },
                splashColor: Theme.of(context).primaryColor,
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                  leading: Icon(
                    Icons.arrow_drop_up,
                    size: 32.0,
                  ),
                  trailing: Icon(
                    Icons.arrow_drop_up,
                    size: 32.0,
                  ),
                  title: Text(
                    "Project Details",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textScaleFactor: 1.4,
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Text(
                    "Tap to open/close",
                    textScaleFactor: 1.1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Divider(
                thickness: 1.2,
              ),
              contractor(),
              Divider(
                thickness: 1.2,
              ),
              widget.document["id"].isNotEmpty
                  ? ListTile(
                      leading: Icon(Icons.local_library, size: 32),
                      title: Text("Project ID"),
                      subtitle: Text(widget.document["id"]),
                    )
                  : Container(),
              ListTile(
                leading: Icon(Icons.library_books, size: 32),
                title: Text("Project Name"),
                subtitle: Text(widget.document["name"]),
              ),
              ListTile(
                leading: Icon(Icons.edit, size: 32),
                title: Text("Project Description"),
                subtitle: Text(widget.document["desc"]),
              ),
              ListTile(
                leading: Icon(Icons.location_city, size: 32),
                title: Text("Project Location"),
                subtitle: Text(widget.document["address"]),
              ),
              ListTile(
                leading: Icon(Icons.attach_money, size: 32),
                title: Text("Project Budget"),
                subtitle: Text("Php " + widget.document["budget"].toString()),
              ),
              ListTile(
                leading: Icon(Icons.calendar_today, size: 32),
                title: Text("Date Started"),
                subtitle: Text(formatDate(
                    (widget.document["start"] as Timestamp).toDate(),
                    [DD, " - ", MM, " ", dd, ", ", yyyy])),
              ),
              ListTile(
                leading: Icon(
                  Icons.date_range,
                  size: 32,
                  color: (widget.document["deadline"] as Timestamp)
                          .toDate()
                          .isBefore(DateTime.now())
                      ? Colors.red
                      : Colors.grey,
                ),
                title: Text(
                  "Deadline",
                  style: TextStyle(
                    color: (widget.document["deadline"] as Timestamp)
                            .toDate()
                            .isBefore(DateTime.now())
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
                subtitle: Text(
                  formatDate(
                      (widget.document["deadline"] as Timestamp).toDate(),
                      [DD, " - ", MM, " ", dd, ", ", yyyy]),
                  style: TextStyle(
                    color: (widget.document["deadline"] as Timestamp)
                            .toDate()
                            .isBefore(DateTime.now())
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
              ),
              widget.document["completed"] == true
                  ? ListTile(
                      leading: Icon(Icons.check,
                          size: 32,
                          color: (widget.document["complete"] as Timestamp)
                                  .toDate()
                                  .isAfter(
                                      (widget.document["deadline"] as Timestamp)
                                          .toDate())
                              ? Colors.red
                              : Colors.green),
                      title: Text(
                        "Completed",
                        style: TextStyle(
                            color: (widget.document["complete"] as Timestamp)
                                    .toDate()
                                    .isAfter((widget.document["deadline"]
                                            as Timestamp)
                                        .toDate())
                                ? Colors.red
                                : Colors.green),
                      ),
                      subtitle: Text(
                        formatDate(
                            (widget.document["complete"] as Timestamp).toDate(),
                            [DD, " - ", MM, " ", dd, ", ", yyyy]),
                        style: TextStyle(
                            color: (widget.document["complete"] as Timestamp)
                                    .toDate()
                                    .isAfter((widget.document["deadline"]
                                            as Timestamp)
                                        .toDate())
                                ? Colors.red
                                : Colors.green),
                      ),
                    )
                  : Container(),
              widget.document["completed"] == false
                  ? Column(
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
                          child: Card(
                            elevation: 5.0,
                            child: DatePickerWidget(
                              dateFormat: _format,
                              initialDateTime: DateTime.now(),
                              minDateTime: DateTime.parse(MIN_DATETIME),
                              pickerTheme: DateTimePickerTheme(
                                showTitle: true,
                                title: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Date Completed",
                                  ),
                                ),
                                cancel: null,
                                confirm: null,
                                itemTextStyle: TextStyle(
                                    color: Theme.of(context).primaryColor),
                                pickerHeight: 100.0,
                                titleHeight: 24.0,
                                itemHeight: 30.0,
                              ),
                              onChange: (dateTime, selectedIndex) {
                                _projectComplete = dateTime;
                              },
                            ),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 15.0),
                            child: SizedBox(
                              height: 40.0,
                              child: RaisedButton(
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0)),
                                color: Theme.of(context).primaryColor,
                                child: Text("Project Complete",
                                    style: TextStyle(
                                        fontSize: 20.0, color: Colors.white)),
                                onPressed: () {
                                  if (_projectComplete.isBefore(
                                      (widget.document["start"] as Timestamp)
                                          .toDate())) {
                                    _scaffoldKey.currentState
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          "Please review date of completion"),
                                      duration: Duration(seconds: 1),
                                    ));
                                  } else {
                                    showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        child: AlertDialog(
                                          elevation: 5.0,
                                          title: Text("Confirm Date"),
                                          content: Text(formatDate(
                                              _projectComplete, [
                                            DD,
                                            " - ",
                                            MM,
                                            " ",
                                            dd,
                                            ", ",
                                            yyyy
                                          ])),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text("Confirm",
                                                  style: TextStyle(
                                                      color: Colors.green)),
                                              onPressed: () async {
                                                await widget.db
                                                    .collection("projects")
                                                    .document(widget
                                                        .document.documentID)
                                                    .updateData({
                                                  "complete": _projectComplete,
                                                  "completed": true,
                                                  "deadline": widget
                                                      .document["deadline"],
                                                  "start":
                                                      widget.document["start"]
                                                });
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                            ),
                                            FlatButton(
                                              child: Text("Cancel",
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ));
                                  }
                                },
                              ),
                            )),
                      ],
                    )
                  : Container(),
              _rating != 0 &&
                      !_rating.isNaN &&
                      !_rating.isNegative &&
                      _rating != null
                  ? RatingBar(
                      initialRating: _rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: null,
                    )
                  : Container(),
              Divider(),
              InkWell(
                splashColor: Theme.of(context).primaryColor,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProjectComments(
                            auth: widget.auth,
                            db: widget.db,
                            document: widget.document,
                            userEmail: widget.userEmail,
                            userId: widget.userId,
                          )));
                },
                child: ListTile(
                  leading: Icon(Icons.mode_edit),
                  title: Text(
                    "Comments",
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.5,
                  ),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
            ],
          )),
        ));
  }
}
