import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthForm extends StatefulWidget {
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _isLoading = false;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  var _department = '';
  var _semester = '';

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isLogin) {
          await Provider.of<AuthProvider>(context, listen: false)
              .signInWithEmail(_userEmail.trim(), _userPassword);
        } else {
          await Provider.of<AuthProvider>(context, listen: false)
              .signUpWithEmail(_userEmail.trim(), _userPassword, _userName.trim(),
              _department.trim(), _semester.trim());
        }
      } catch (error) {
        var message = 'An error occurred, please check your credentials!';
        if (error.toString().contains('EMAIL_EXISTS')) {
          message = 'This email address is already in use.';
        } else if (error.toString().contains('INVALID_EMAIL')) {
          message = 'This is not a valid email address.';
        } else if (error.toString().contains('WEAK_PASSWORD')) {
          message = 'This password is too weak.';
        } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
          message = 'Could not find a user with that email.';
        } else if (error.toString().contains('INVALID_PASSWORD')) {
          message = 'Invalid password.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).signInWithGoogle();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Academic Assistant',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    key: ValueKey('email'),
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email address',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) {
                      _userEmail = value!;
                    },
                  ),
                  SizedBox(height: 10),
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('username'),
                      validator: (value) {
                        if (value!.isEmpty || value.length < 4) {
                          return 'Please enter at least 4 characters.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) {
                        _userName = value!;
                      },
                    ),
                  if (!_isLogin) SizedBox(height: 10),
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('department'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your department.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Department',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) {
                        _department = value!;
                      },
                    ),
                  if (!_isLogin) SizedBox(height: 10),
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('semester'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your current semester.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Semester',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) {
                        _semester = value!;
                      },
                    ),
                  if (!_isLogin) SizedBox(height: 10),
                  TextFormField(
                    key: ValueKey('password'),
                    validator: (value) {
                      if (value!.isEmpty || value.length < 7) {
                        return 'Password must be at least 7 characters long.';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    onSaved: (value) {
                      _userPassword = value!;
                    },
                  ),
                  SizedBox(height: 20),
                  if (_isLoading)
                    CircularProgressIndicator()
                  else
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: _submit,
                          child: Text(_isLogin ? 'Login' : 'Sign Up'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                        SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: _signInWithGoogle,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.network(
                                'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png',
                                height: 24,
                              ),
                              SizedBox(width: 10),
                              Text('Sign in with Google'),
                            ],
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin
                                ? 'Create new account'
                                : 'I already have an account',
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}