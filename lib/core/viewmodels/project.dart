import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ProjectView extends StatefulWidget {
  ProjectView(
      {Key key, this.db, this.userEmail, this.userId, this.auth, this.document})
      : super(key: key);

  final DocumentSnapshot document;
  final Firestore db;
  final String userEmail;
  final String userId;
  final BaseAuth auth;

  @override
  _ProjectViewState createState() => _ProjectViewState();
}

class _ProjectViewState extends State<ProjectView> {
  PanelController _panelCtrl = PanelController();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
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
        ),
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
                    (widget.document["schedules"]["start"] as Timestamp)
                        .toDate(),
                    [DD, " - ", MM, " ", dd, ", ", yyyy])),
              ),
              ListTile(
                leading: Icon(Icons.date_range, size: 32),
                title: Text("Deadline"),
                subtitle: Text(formatDate(
                    (widget.document["schedules"]["deadline"] as Timestamp)
                        .toDate(),
                    [DD, " - ", MM, " ", dd, ", ", yyyy])),
              ),
            ],
          )),
        ));
  }
}
