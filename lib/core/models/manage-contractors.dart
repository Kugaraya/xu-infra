import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_fluid_slider/flutter_fluid_slider.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:infrastrucktor/core/services/auth-service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageContractors extends StatefulWidget {
  ManageContractors({this.auth, this.db, this.fs});

  final Firestore db;
  final FirebaseStorage fs;
  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => _AuthPageState();
}

const String MIN_DATETIME = '1970-01-01';

class _AuthPageState extends State<ManageContractors> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _ageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _format = 'yyyy-MMMM-dd';
  String _email, _prefix, _password, _errorMessage;
  String _fname, _mname, _lname, _suffix, _contact, _gender;
  String _license, _company, _category, _class, _region;
  DateTime _pcab, _govt;
  double _age;
  int _actualAge;

  bool _isLoading;
  bool _isObscure;

  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _formKey.currentState;
    print(_email);
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
        _errorMessage = "";
        _isLoading = true;
      });
      String userId = "";
      try {
        userId = await widget.auth.signUp(_email, _password);

        if (userId.isNotEmpty) {
          widget.db.collection("accounts").add({
            "age": _actualAge,
            "contact": _contact,
            "email": _email,
            "evaluate": [],
            "feedback": [],
            "gender": _gender,
            "firstname": _fname,
            "lastname": _lname,
            "middlename":
                _mname.length == 1 ? _mname.toUpperCase() + "." : _mname,
            "licensenumber": _license,
            "company": _company,
            "category": _category,
            "classification": _class,
            "region": _region,
            "pcab": _pcab,
            "govt": _govt,
            "permission": 1,
            "photo": "",
            "prefix": _prefix,
            "suffix": _suffix,
            "uid": userId,
          });

          Fluttertoast.showToast(
              msg: "Contractor registration success",
              backgroundColor: Colors.black54,
              textColor: Colors.white);
        }
        setState(() {
          _isLoading = false;
        });
        _formKey.currentState.reset();
        Navigator.of(context).pop();
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          _formKey.currentState.reset();
        });
      }
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _prefix = "Mr.";
    _gender = "Male";
    _region = "NCR";
    _age = 1.0;
    _actualAge = 1;
    _ageCtrl.text = _age.toInt().toString();
    _isLoading = false;
    _isObscure = true;
    super.initState();
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            _showForm(),
          ],
        ));
  }

  Widget _showForm() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                SizedBox(
                  height: 30.0,
                ),
                showLogo(),
                showEmailInput(),
                showPasswordInput(),
                showLicenseInput(),
                showCompanyInput(),
                showClassInput(),
                showCategoryInput(),
                showPrefixInput(),
                showFNameInput(),
                showMNameInput(),
                showLNameInput(),
                showSuffixInput(),
                showRegionInput(),
                showPCABInput(),
                showGovtInput(),
                showContactInput(),
                showGenderInput(),
                showAgeInput(),
                showPrimaryButton(),
                SizedBox(
                  height: 10.0,
                ),
                showErrorMessage(),
                SizedBox(
                  height: 30.0,
                ),
              ],
            ),
          ),
        ));
  }

  Widget showErrorMessage() {
    if (_errorMessage != null) {
      return Text(
        _errorMessage,
        textScaleFactor: 1.4,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }

  Widget showLogo() {
    return Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 48.0,
          child: Image.asset('assets/logo.png'),
        ),
      ),
    );
  }

  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
      child: TextFormField(
        enabled: _isLoading ? false : true,
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
            labelText: 'Email*',
            icon: Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value.trim(),
        onChanged: (value) => _email = value.trim(),
      ),
    );
  }

  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        enabled: _isLoading ? false : true,
        maxLines: 1,
        obscureText: _isObscure,
        autofocus: false,
        decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: Icon(
                Icons.remove_red_eye,
                color:
                    _isObscure ? Colors.grey : Theme.of(context).primaryColor,
              ),
              onPressed: () =>
                  setState(() => _isObscure = _isObscure ? false : true),
            ),
            hintText: 'Min. of 6 characters',
            labelText: 'Password*',
            icon: Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value.trim(),
        onChanged: (value) => _password = value.trim(),
      ),
    );
  }

  Widget showPrefixInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 35.0, 0.0, 0.0),
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
              textScaleFactor: 1.15, style: TextStyle(color: Colors.grey[600])),
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
                      child: Text("Prof."),
                      value: "Prof.",
                    ),
                    DropdownMenuItem(
                      child: Text("Engr."),
                      value: "Engr.",
                    ),
                    DropdownMenuItem(
                      child: Text("Atty."),
                      value: "Atty.",
                    ),
                  ]
                : null,
            value: _prefix,
            onChanged: (value) => setState(() => _prefix = value),
          ),
        ],
      ),
    );
  }

  Widget showLicenseInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
      child: TextFormField(
        enabled: _isLoading ? false : true,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
            labelText: 'License Number*',
            icon: Icon(
              FontAwesome.drivers_license,
              color: Colors.grey,
            )),
        validator: (value) =>
            value.isEmpty ? 'License Number can\'t be empty' : null,
        onSaved: (value) => _license = value.trim(),
        onChanged: (value) => _license = value.trim(),
      ),
    );
  }

  Widget showCompanyInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
      child: TextFormField(
        enabled: _isLoading ? false : true,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
            labelText: 'Company*',
            icon: Icon(
              Icons.location_city,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Company can\'t be empty' : null,
        onSaved: (value) => _company = value.trim(),
        onChanged: (value) => _company = value.trim(),
      ),
    );
  }

  Widget showCategoryInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
      child: TextFormField(
        enabled: _isLoading ? false : true,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
            labelText: 'Category*',
            icon: Icon(
              Icons.category,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Category can\'t be empty' : null,
        onSaved: (value) => _category = value.trim(),
        onChanged: (value) => _category = value.trim(),
      ),
    );
  }

  Widget showClassInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
      child: TextFormField(
        enabled: _isLoading ? false : true,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
            labelText: 'Primary Classification*',
            icon: Icon(
              Icons.library_books,
              color: Colors.grey,
            )),
        validator: (value) =>
            value.isEmpty ? 'Primary Classification can\'t be empty' : null,
        onSaved: (value) => _class = value.trim(),
        onChanged: (value) => _class = value.trim(),
      ),
    );
  }

  Widget showFNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
      child: TextFormField(
        enabled: _isLoading ? false : true,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
            labelText: 'First Name*',
            icon: Icon(
              Icons.text_fields,
              color: Colors.grey,
            )),
        validator: (value) =>
            value.isEmpty ? 'First Name can\'t be empty' : null,
        onSaved: (value) => _fname = value.trim(),
        onChanged: (value) => _fname = value.trim(),
      ),
    );
  }

  Widget showMNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        enabled: _isLoading ? false : true,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
            labelText: 'Middle Name/Initial*',
            icon: Icon(
              Icons.text_fields,
              color: Colors.transparent,
            )),
        validator: (value) =>
            value.isEmpty ? 'Middle Name/Initial can\'t be empty' : null,
        onSaved: (value) => _mname = value.trim(),
        onChanged: (value) => _mname = value.trim(),
      ),
    );
  }

  Widget showLNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        enabled: _isLoading ? false : true,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
            labelText: 'Last Name*',
            icon: Icon(
              Icons.text_fields,
              color: Colors.transparent,
            )),
        validator: (value) =>
            value.isEmpty ? 'Last Name can\'t be empty' : null,
        onSaved: (value) => _lname = value.trim(),
        onChanged: (value) => _lname = value.trim(),
      ),
    );
  }

  Widget showSuffixInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        enabled: _isLoading ? false : true,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
            labelText: 'Suffix',
            hintText: "i.e. (Sr./Jr./MBA), Leave blank if none",
            icon: Icon(
              Icons.text_fields,
              color: Colors.transparent,
            )),
        onSaved: (value) => _suffix = value.trim(),
        onChanged: (value) => _suffix = value.trim(),
      ),
    );
  }

  Widget showRegionInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 10.0),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.map,
            color: Colors.grey[600],
          ),
          SizedBox(
            width: 16.0,
          ),
          Text(
            "Region",
            textScaleFactor: 1.15,
            style: TextStyle(color: Colors.grey[600]),
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
                      child: Text("NCR"),
                      value: "NCR",
                    ),
                    DropdownMenuItem(
                      child: Text("CAR"),
                      value: "CAR",
                    ),
                    DropdownMenuItem(
                      child: Text("MIMAROPA"),
                      value: "MIMAROPA",
                    ),
                    DropdownMenuItem(
                      child: Text("Region I"),
                      value: "Region I",
                    ),
                    DropdownMenuItem(
                      child: Text("Region II"),
                      value: "Region II",
                    ),
                    DropdownMenuItem(
                      child: Text("Region III"),
                      value: "Region III",
                    ),
                    DropdownMenuItem(
                      child: Text("Region IV-A"),
                      value: "Region IV-A",
                    ),
                    DropdownMenuItem(
                      child: Text("Region V"),
                      value: "Region V",
                    ),
                    DropdownMenuItem(
                      child: Text("Region VI"),
                      value: "Region VI",
                    ),
                    DropdownMenuItem(
                      child: Text("Region VII"),
                      value: "Region VII",
                    ),
                    DropdownMenuItem(
                      child: Text("Region VIII"),
                      value: "Region VIII",
                    ),
                    DropdownMenuItem(
                      child: Text("Region IX"),
                      value: "Region IX",
                    ),
                    DropdownMenuItem(
                      child: Text("Region X"),
                      value: "Region X",
                    ),
                    DropdownMenuItem(
                      child: Text("Region XI"),
                      value: "Region XI",
                    ),
                    DropdownMenuItem(
                      child: Text("Region XII"),
                      value: "Region XII",
                    ),
                    DropdownMenuItem(
                      child: Text("Region XIII"),
                      value: "Region XIII",
                    ),
                  ]
                : null,
            value: _region,
            onChanged: (value) => setState(() => _region = value),
          ),
        ],
      ),
    );
  }

  Widget showPCABInput() {
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
                "PCAB License Validity",
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
            _pcab = dateTime;
          },
        ),
      ),
    );
  }

  Widget showGovtInput() {
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
                "Registration for Gov't Projects Validity",
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
            _govt = dateTime;
          },
        ),
      ),
    );
  }

  Widget showAgeInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: FluidSlider(
        min: 1.0,
        max: 100.0,
        start: Text("Age", style: TextStyle(color: Colors.white)),
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
            decoration:
                InputDecoration(border: InputBorder.none, counterText: ""),
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
                  _age = value > 4.85 ? value.roundToDouble() : value;
                  _ageCtrl.text = _age.toInt().toString();
                });
              },
        onChangeEnd: (value) {
          setState(() {
            _actualAge =
                value > 4.85 ? value.roundToDouble().toInt() : value.floor();
          });
          print(_actualAge);
        },
      ),
    );
  }

  Widget showContactInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        enabled: _isLoading ? false : true,
        maxLines: 1,
        keyboardType: TextInputType.number,
        autofocus: false,
        decoration: InputDecoration(
            labelText: 'Contact Number*',
            prefixText: "+63",
            icon: Icon(
              Icons.phone,
            )),
        validator: (value) =>
            value.length != 10 ? 'Contact number may be invalid' : null,
        onSaved: (value) => _contact = value.trim(),
        onChanged: (value) => _contact = value.trim(),
      ),
    );
  }

  Widget showGenderInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 10.0),
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
            style: TextStyle(color: Colors.grey[600]),
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
            onChanged: (value) => setState(() => _gender = value),
          ),
        ],
      ),
    );
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
            child: Text('Add Contractor',
                style: TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: validateAndSubmit,
          ),
        ));
  }
}
