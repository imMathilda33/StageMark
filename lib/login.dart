import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginRegisterPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  TabController tabController;
  LoginRegisterPage({Key? key, this.onLoginSuccess, required this.tabController}) : super(key: key);
  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

void saveInformation(String term, String? info) async {
  SharedPreferences dataBase = await SharedPreferences.getInstance();
  dataBase.setString(term, info!);
}

Future<String?> getInformation(String term) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(term) ?? "";
}

void saveInformationBool(String term, bool info) async {
  SharedPreferences dataBase = await SharedPreferences.getInstance();
  dataBase.setBool(term, info);
}

Future<bool> getInformationBool(String term) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(term) ?? false;
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController confirmationController = TextEditingController();

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _message = '';
  bool _isRegistering = false;
  bool _isRegisteringSuccess = false;

  void _register() async {
    if (_isRegistering && passwordController.value == confirmationController.value && confirmationController.text != "") {
      try {
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        setState(() {
          _message = "Registered as: ${userCredential.user?.email}";
        });
        saveInformation("user", userCredential.user!.email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registered as: ${userCredential.user?.email}"),
            duration: Duration(seconds: 2),
          ),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          _message = "Failed to register: ${e.message}";
        });
      } catch (e) {
        setState(() {
          _message = "Error: $e";
        });
      }
    } else if (_isRegistering && passwordController.value != confirmationController.value && confirmationController.text != "") {
      setState(() {
        _message = "Error: Passwords do not match.";
      });
    }
  }

  void _login() async {
    if (!_isRegistering) {
      try {
        final UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        if (mounted) {
          if (userCredential.user != null) {
            widget.onLoginSuccess?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Logged in as: ${userCredential.user?.email}"),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() {
            _message = "Failed to sign in: ${e.message}";
          });

        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _message = "Error: $e";
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: null,
        title: Text('Log in to your account'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8.0, 20, 8.0),
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      value!.isEmpty ? 'Email can\'t be empty' : null,
                  onSaved: (value) => _email = value!,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8.0, 20, 8.0),
                child: TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Password can\'t be empty' : null,
                  onSaved: (value) => _password = value!,
                ),
              ),
              if (_isRegistering)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8.0, 20, 8.0),
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    controller: confirmationController,
                    obscureText: true,
                    validator: (value) {
                      if (_isRegistering && value!.isEmpty) {
                        return 'Confirm password can\'t be empty';
                      } else if (_isRegistering && passwordController.value != confirmationController.value && confirmationController.text != "") {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onSaved: (value) => _confirmPassword = value!,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 8.0, 40, 8.0),
                child: ElevatedButton(
                  child: Text('Register'),
                  onPressed: () {
                    setState(() {
                      _isRegistering = true;
                    });
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _register();
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 8.0, 40, 8.0),
                child: ElevatedButton(
                  child: Text('Login'),
                  onPressed: () {
                    setState(() {
                      _isRegistering = false;
                    });
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _login();
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _message,
                  style: _isRegisteringSuccess ? TextStyle(color: Colors.green) : TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
