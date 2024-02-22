
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginRegisterPage extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  LoginRegisterPage({Key? key, this.onLoginSuccess}) : super(key: key);
  @override
  _LoginRegisterPageState createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _message = '';
  bool _isRegistering = false;

  void _register() async {
    if (_isRegistering && _password == _confirmPassword) {
      try {
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        setState(() {
          _message = "Registered as: ${userCredential.user?.email}";
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          _message = "Failed to register: ${e.message}";
        });
      } catch (e) {
        setState(() {
          _message = "Error: $e";
        });
      }
    } else if (_isRegistering && _password != _confirmPassword) {
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
                    obscureText: true,
                    validator: (value) {
                      if (_isRegistering && value!.isEmpty) {
                        return 'Confirm password can\'t be empty';
                      } else if (_isRegistering && _password != value) {
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
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
