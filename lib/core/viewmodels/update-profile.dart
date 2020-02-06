import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fluid_slider/flutter_fluid_slider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';
import 'package:infrastrucktor/ui/widgets/menu.dart';

class UpdateProfile extends StatefulWidget {
  UpdateProfile(
      {Key key,
      this.userEmail,
      this.userId,
      this.auth,
      this.logoutCallback,
      this.db,
      this.fs,
      this.document})
      : super(key: key);

  final Firestore db;
  final FirebaseStorage fs;
  final String userEmail;
  final String userId;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final DocumentSnapshot document;
  @override
  _AccountProfileState createState() => _AccountProfileState();
}

class _AccountProfileState extends State<UpdateProfile> {
  final _ageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController(keepScrollOffset: true);
  final _formKey = GlobalKey<FormState>();

  String _prefix;
  String _fname, _mname, _lname, _suffix, _contact, _gender;
  double _age;
  int _actualAge;

  bool _isLoading;

  @override
  void initState() {
    _prefix = "Mr.";
    _gender = "Male";
    _age = double.parse(widget.document.data["age"].toString());
    _actualAge = widget.document.data["age"];
    _ageCtrl.text = _age.toInt().toString();
    _isLoading = false;
    super.initState();
  }

  // Check if form is valid before perform login or signup
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
            .collection("accounts")
            .document(widget.document.documentID)
            .updateData({
          "age": _actualAge,
          "contact": _contact,
          "evaluate": [],
          "feedback": {},
          "gender": _gender,
          "firstname": _fname,
          "lastname": _lname,
          "middlename":
              _mname.length == 1 ? _mname.toUpperCase() + "." : _mname,
          "photo": "",
          "prefix": _prefix,
          "suffix": _suffix,
        });

        Fluttertoast.showToast(
            msg: 'Profile Updated',
            textColor: Colors.white,
            backgroundColor: Colors.black87);
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    final _menu = Menu(widget.db, widget.fs, widget.userEmail, widget.userId,
        widget.auth, widget.logoutCallback, context);
    return Scaffold(
        key: _scaffoldKey,
        drawer: Navigator.of(context).canPop() ? null : _menu.adminDrawer(),
        floatingActionButton: !_isLoading
            ? FloatingActionButton(
                onPressed: !_isLoading ? validateAndSubmit : null,
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              )
            : null,
        body: CustomScrollView(
          controller: _scrollCtrl,
          slivers: <Widget>[
            SliverAppBar(
              leading: Navigator.of(context).canPop()
                  ? null
                  : IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _scaffoldKey.currentState.openDrawer();
                      },
                    ),
              expandedHeight: 200.0,
              pinned: true,
              actions: <Widget>[
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 24,
                  backgroundImage: AssetImage("assets/logo.png"),
                )
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Image.asset(
                  "assets/cover.png",
                  fit: BoxFit.cover,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(widget.document.data["prefix"] +
                        " " +
                        widget.document.data["firstname"] +
                        " " +
                        widget.document.data["middlename"] +
                        " " +
                        widget.document.data["lastname"]),
                    Text(widget.document.data["suffix"].isNotEmpty
                        ? ", " + widget.document.data["suffix"]
                        : ""),
                  ],
                ),
                centerTitle: true,
              ),
            ),
            !_isLoading
                ? SliverToBoxAdapter(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 30.0),
                        Text(
                          "Update Info",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.5,
                        ),
                        Divider(
                          color: Colors.blueGrey,
                          thickness: 2.0,
                        ),
                        Form(
                          key: _formKey,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 15.0, 0.0, 0.0),
                                  child: FluidSlider(
                                    min: 0.0,
                                    max: 100.0,
                                    start: Text("Age",
                                        style: TextStyle(color: Colors.white)),
                                    end: Container(
                                      width: 30.0,
                                      child: TextFormField(
                                        controller: _ageCtrl,
                                        enabled: _isLoading ? false : true,
                                        maxLines: 1,
                                        keyboardType: TextInputType.number,
                                        autofocus: false,
                                        maxLength: 2,
                                        style: TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            counterText: ""),
                                        onChanged: (value) {
                                          setState(() {
                                            _age = double.parse(_ageCtrl.text);
                                          });
                                        },
                                      ),
                                    ),
                                    value: _age,
                                    sliderColor: Theme.of(context).primaryColor,
                                    onChanged: _isLoading
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _age = value > 4.85
                                                  ? value.roundToDouble()
                                                  : value;
                                              _ageCtrl.text =
                                                  _age.toInt().toString();
                                            });
                                          },
                                    onChangeEnd: (value) {
                                      setState(() {
                                        _actualAge = value > 4.85
                                            ? value.roundToDouble().toInt()
                                            : value.floor();
                                      });
                                      print(_actualAge);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 25.0, 0.0, 0.0),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.title,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(
                                        width: 16.0,
                                      ),
                                      Text("Prefix",
                                          textScaleFactor: 1.15,
                                          style: TextStyle(
                                              color: Colors.grey[600])),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      DropdownButton(
                                        elevation: 8,
                                        isDense: true,
                                        underline: null,
                                        items: !_isLoading
                                            ? [
                                                DropdownMenuItem(
                                                  child: Text("Mr."),
                                                  value: "Mr.",
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("Ms."),
                                                  value: "Ms.",
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("Dr."),
                                                  value: "Dr.",
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("Engr."),
                                                  value: "Engr.",
                                                ),
                                              ]
                                            : null,
                                        value: _prefix,
                                        onChanged: (value) =>
                                            setState(() => _prefix = value),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 25.0, 0.0, 0.0),
                                  child: TextFormField(
                                    enabled: _isLoading ? false : true,
                                    maxLines: 1,
                                    keyboardType: TextInputType.text,
                                    autofocus: false,
                                    initialValue:
                                        widget.document.data["firstname"],
                                    decoration: InputDecoration(
                                        labelText: 'First Name*',
                                        icon: Icon(
                                          Icons.text_fields,
                                          color: Colors.grey,
                                        )),
                                    validator: (value) => value.isEmpty
                                        ? 'First Name can\'t be empty'
                                        : null,
                                    onSaved: (value) => _fname = value.trim(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 15.0, 0.0, 0.0),
                                  child: TextFormField(
                                    enabled: _isLoading ? false : true,
                                    maxLines: 1,
                                    keyboardType: TextInputType.text,
                                    autofocus: false,
                                    initialValue:
                                        widget.document.data["middlename"],
                                    decoration: InputDecoration(
                                        labelText: 'Middle Name/Initial*',
                                        icon: Icon(
                                          Icons.text_fields,
                                          color: Colors.transparent,
                                        )),
                                    validator: (value) => value.isEmpty
                                        ? 'Middle Name/Initial can\'t be empty'
                                        : null,
                                    onSaved: (value) => _mname = value.trim(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 15.0, 0.0, 0.0),
                                  child: TextFormField(
                                    enabled: _isLoading ? false : true,
                                    maxLines: 1,
                                    keyboardType: TextInputType.text,
                                    autofocus: false,
                                    initialValue:
                                        widget.document.data["lastname"],
                                    decoration: InputDecoration(
                                        labelText: 'Last Name*',
                                        icon: Icon(
                                          Icons.text_fields,
                                          color: Colors.transparent,
                                        )),
                                    validator: (value) => value.isEmpty
                                        ? 'Last Name can\'t be empty'
                                        : null,
                                    onSaved: (value) => _lname = value.trim(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 15.0, 0.0, 0.0),
                                  child: TextFormField(
                                    enabled: _isLoading ? false : true,
                                    maxLines: 1,
                                    keyboardType: TextInputType.text,
                                    autofocus: false,
                                    initialValue:
                                        widget.document.data["suffix"],
                                    decoration: InputDecoration(
                                        labelText: 'Suffix',
                                        hintText:
                                            "i.e. (Sr./Jr./MBA), Leave blank if none",
                                        icon: Icon(
                                          Icons.text_fields,
                                          color: Colors.transparent,
                                        )),
                                    onSaved: (value) => _suffix = value.trim(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 15.0, 0.0, 0.0),
                                  child: TextFormField(
                                    enabled: _isLoading ? false : true,
                                    maxLines: 1,
                                    keyboardType: TextInputType.number,
                                    autofocus: false,
                                    initialValue:
                                        widget.document.data["contact"],
                                    decoration: InputDecoration(
                                        labelText: 'Contact Number*',
                                        prefixText: "+63",
                                        icon: Icon(
                                          Icons.phone,
                                        )),
                                    validator: (value) => value.length != 10
                                        ? 'Contact number may be invalid'
                                        : null,
                                    onSaved: (value) => _contact = value.trim(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 25.0, 0.0, 0.0),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.people,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(
                                        width: 16.0,
                                      ),
                                      Text(
                                        "Gender",
                                        textScaleFactor: 1.15,
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      DropdownButton(
                                        elevation: 8,
                                        isDense: true,
                                        underline: null,
                                        items: !_isLoading
                                            ? [
                                                DropdownMenuItem(
                                                  child: Text("Male"),
                                                  value: "Male",
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("Female"),
                                                  value: "Female",
                                                ),
                                              ]
                                            : null,
                                        value: _gender,
                                        onChanged: (value) =>
                                            setState(() => _gender = value),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 30.0,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : SliverToBoxAdapter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 70.0,
                        ),
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    ),
                  )
          ],
        ));
  }
}
