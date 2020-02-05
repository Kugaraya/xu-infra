import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_fluid_slider/flutter_fluid_slider.dart';
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

class _AuthPageState extends State<ManageContractors> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _ageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _email, _prefix, _password, _errorMessage;
  String _fname, _mname, _lname, _suffix, _contact, _gender;
  double _age;
  int _actualAge;

  bool _isLoading;
  bool _isObscure;

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
        _errorMessage = "";
        _isLoading = true;
      });
      String userId = "";
      try {
        userId = await widget.auth.signUp(_email, _password);
        if (userId.isNotEmpty) {
          widget.db.collection("accounts").add({
            // TODO : Follow new data
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
            "permission": 1,
            "photo": "",
            "prefix": _prefix,
            "suffix": _suffix,
            "uid": userId,
          });
          print('Signed up user: $userId');
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Account registration success"),
          ));
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
                // TODO : Follow new inputs
                showEmailInput(),
                showPasswordInput(),
                showPrefixInput(),
                showFNameInput(),
                showMNameInput(),
                showLNameInput(),
                showSuffixInput(),
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
    if (_errorMessage.length > 0 && _errorMessage != null) {
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
                      child: Text("Engr."),
                      value: "Engr.",
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
      ),
    );
  }

  Widget showGenderInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
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
