import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddProject extends StatefulWidget {
  AddProject({Key key, this.db, this.userEmail, this.userId, this.auth})
      : super(key: key);

  final Firestore db;
  final String userEmail;
  final String userId;
  final BaseAuth auth;

  @override
  _AddProjectState createState() => _AddProjectState();
}

const String MIN_DATETIME = '1970-01-01';

class _AddProjectState extends State<AddProject> {
  String _format = 'yyyy-MMMM-dd';

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  LocationResult _pickedLocation;
  String _address, _projectName, _projectID, _projectDescription;
  DateTime _projectStart, _projectEnd;
  // ignore_for_file: unused_field
  String _lat, _lng;
  double _budget = 0.0;
  TextEditingController _lngCtrl, _latCtrl;
  bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _pickedLocation = LocationResult(address: "test", latLng: LatLng(0.0, 0.0));
  }

  @override
  Widget build(BuildContext context) {
    bool validateAndSave() {
      final form = _formKey.currentState;
      if (_lat == null || _lng == null) {
        print("Map?");
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text("Select a map location first")));
      } else if (_projectEnd.isBefore(_projectStart)) {
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text("Deadline should be after Date Started")));
      } else {
        if (form.validate()) {
          form.save();
          return true;
        }
      }
      return false;
    }

    void validateAndSubmit() async {
      if (validateAndSave()) {
        setState(() {
          _isLoading = true;
        });

        try {
          widget.db.collection("projects").add({
            "address": _address,
            "budget": _budget,
            "completed": false,
            "contractor": widget.userId,
            "desc": _projectDescription,
            "feedback": [],
            "hasUpdate": false,
            "id": _projectID,
            "location": GeoPoint(_pickedLocation.latLng.latitude,
                _pickedLocation.latLng.longitude),
            "name": _projectName,
            "ratings": [],
            "complete": DateTime.parse(MIN_DATETIME),
            "deadline": _projectEnd,
            "start": _projectStart,
            "updates": []
          });
          setState(() {
            _isLoading = false;
          });

          _formKey.currentState.reset();
          Fluttertoast.showToast(
              msg: "Project Added",
              backgroundColor: Colors.black87,
              textColor: Colors.white);
          Navigator.of(context).pop();
        } catch (e) {
          print('Error: $e');
          Fluttertoast.showToast(
              msg: "Unknown Error",
              backgroundColor: Colors.black87,
              textColor: Colors.white);
          setState(() {
            _isLoading = false;
            _formKey.currentState.reset();
          });
        }
      }
    }

    Widget showPrimaryButton() {
      if (_isLoading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
      return Padding(
          padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
          child: SizedBox(
            height: 40.0,
            child: RaisedButton(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              color: Theme.of(context).primaryColor,
              child: Text("Add Project",
                  style: TextStyle(fontSize: 20.0, color: Colors.white)),
              onPressed: validateAndSubmit,
            ),
          ));
    }

    Widget projectDeadline() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
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
                  "Project Deadline",
                ),
              ),
              cancel: null,
              confirm: null,
              itemTextStyle: TextStyle(color: Theme.of(context).primaryColor),
              pickerHeight: 100.0,
              titleHeight: 24.0,
              itemHeight: 30.0,
            ),
            onChange: (dateTime, selectedIndex) {
              _projectEnd = dateTime;
            },
          ),
        ),
      );
    }

    Widget projectStart() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
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
                  "Date Started",
                ),
              ),
              cancel: null,
              confirm: null,
              itemTextStyle: TextStyle(color: Theme.of(context).primaryColor),
              pickerHeight: 100.0,
              titleHeight: 24.0,
              itemHeight: 30.0,
            ),
            onChange: (dateTime, selectedIndex) {
              _projectStart = dateTime;
            },
          ),
        ),
      );
    }

    Widget projectBudget() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
        child: TextFormField(
          maxLines: 1,
          keyboardType: TextInputType.number,
          autofocus: false,
          decoration: InputDecoration(
              prefixText: 'Php ',
              labelText: 'Budget',
              icon: Icon(
                Icons.monetization_on,
                color: Colors.grey,
              )),
          validator: (value) => value.isEmpty ? 'Budget can\'t be empty' : null,
          onSaved: (value) =>
              _budget = value.isEmpty ? 0.0 : double.parse(value),
        ),
      );
    }

    Widget projectDescription() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
        child: TextFormField(
          maxLines: 3,
          keyboardType: TextInputType.text,
          autofocus: false,
          decoration: InputDecoration(
              labelText: 'Project Description',
              icon: Icon(
                Icons.edit,
                color: Colors.grey,
              )),
          validator: (value) =>
              value.isEmpty ? 'Description can\'t be empty' : null,
          onSaved: (value) => _projectDescription = value.trim(),
        ),
      );
    }

    Widget projectName() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
        child: TextFormField(
          maxLines: 1,
          keyboardType: TextInputType.text,
          autofocus: false,
          decoration: InputDecoration(
              labelText: 'Project Name',
              icon: Icon(
                Icons.library_books,
                color: Colors.grey,
              )),
          validator: (value) =>
              value.isEmpty ? 'Project Name can\'t be empty' : null,
          onSaved: (value) => _projectName = value.trim(),
        ),
      );
    }

    Widget projectID() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
        child: TextFormField(
          maxLines: 1,
          keyboardType: TextInputType.text,
          autofocus: false,
          decoration: InputDecoration(
              hintText: 'Leave blank if none',
              labelText: 'Project ID',
              icon: Icon(
                Icons.local_library,
                color: Colors.grey,
              )),
          onSaved: (value) => _projectID = value.trim(),
        ),
      );
    }

    Widget projectLocation() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
        child: TextFormField(
          maxLines: 1,
          keyboardType: TextInputType.text,
          autofocus: false,
          decoration: InputDecoration(
              hintText: 'Bldg Name/Actual Address',
              labelText: 'Location',
              icon: Icon(
                Icons.location_city,
                color: Colors.grey,
              ),
              suffixIcon: AvatarGlow(
                endRadius: 30.0,
                startDelay: Duration(milliseconds: 0),
                repeatPauseDuration: Duration(milliseconds: 0),
                curve: Curves.easeInOut,
                glowColor: _lat == null || _lng == null
                    ? Colors.red
                    : Theme.of(context).primaryColor,
                child: IconButton(
                  icon: Icon(
                    Icons.location_searching,
                    color: _lat == null || _lng == null
                        ? Colors.red
                        : Theme.of(context).primaryColor,
                  ),
                  onPressed: () async {
                    LocationResult result = await showLocationPicker(
                      context,
                      "AIzaSyBqyM3znR4wnnOcnjF_wG65nPBFx1B-O4M",
                      automaticallyAnimateToCurrentLocation: true,
                      myLocationButtonEnabled: true,
                      layersButtonEnabled: true,
                    );
                    if (result != null) {
                      setState(() {
                        _pickedLocation = result;
                        _lat = _pickedLocation.latLng.latitude.toString();
                        _lng = _pickedLocation.latLng.longitude.toString();
                        Fluttertoast.showToast(
                            msg: "$_lat, $_lng",
                            backgroundColor: Colors.black38,
                            gravity: ToastGravity.BOTTOM,
                            fontSize: 12.0,
                            textColor: Colors.white,
                            timeInSecForIos: 1,
                            toastLength: Toast.LENGTH_SHORT);
                      });
                    }
                  },
                ),
              )),
          onChanged: (value) {
            setState(() {});
          },
          validator: (value) =>
              value.isEmpty ? 'Address can\'t be empty' : null,
          onSaved: (value) => _address = value.trim(),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Add Project'),
      ),
      body: Builder(builder: (context) {
        print(_pickedLocation);
        return SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    projectID(),
                    projectName(),
                    projectDescription(),
                    projectLocation(),
                    projectBudget(),
                    projectStart(),
                    projectDeadline(),
                    showPrimaryButton()
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
