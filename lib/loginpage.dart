import 'package:attendease/homepage.dart';
import 'package:attendease/signuppage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class loginpage extends StatefulWidget {
  const loginpage({super.key});

  @override
  State<loginpage> createState() => _loginpageState();
}

class _loginpageState extends State<loginpage> {
  var _useridcontroller = TextEditingController();
  var _passwordcontroller = TextEditingController();
  bool _hider = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 131, 145, 160),
      body: Center(
        child: Container(
          height: 500,
          width: 275,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromARGB(255, 131, 172, 212),
          ),
          child: Center(
            child: ListView(
              children: [
                Center(
                  child: Container(
                    height: 75,
                    width: 75,
                    child: Image.asset(
                      'lib/images/profile.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'LOGIN',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    controller: _useridcontroller,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        hintText: 'UserId'),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    controller: _passwordcontroller,
                    obscureText: _hider,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hider = !_hider;
                            });
                          },
                          icon: Icon(
                              _hider ? Icons.visibility : Icons.visibility_off),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        hintText: 'Password'),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.black,
                    ),
                    child: TextButton(
                        onPressed: () async {
                          if (_useridcontroller.text.trim() == "") {
                            SnackBar profilesnack = SnackBar(
                                content: Text('UserId cant\'t be empty.'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(profilesnack);
                          } else if (_passwordcontroller.text.trim() == "") {
                            SnackBar profilesnack = SnackBar(
                                content: Text('Password cant\'t be empty.'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(profilesnack);
                          } else {
                            try {
                              final supabase = Supabase.instance.client;
                              final response =
                                  await supabase.auth.signInWithPassword(
                                email: '${_useridcontroller.text.trim()}@iitg.ac.in',
                                password: _passwordcontroller.text.trim(),
                              );

                              if (response.user != null) {
                                var prefs =
                                    await SharedPreferences.getInstance();
                                setState(() {
                                  prefs.setString('loggedinuserid',
                                      _useridcontroller.text.trim());
                                });

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Homepage()),
                                );

                                SnackBar profilesnack = SnackBar(
                                  content: Text('Successfully signed in'),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(profilesnack);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Login failed. Try again.')),
                                );
                              }
                            } on AuthException catch (e) {
                              String message = '';
                              if (e.message
                                  .contains('Invalid login credentials')) {
                                message = 'Incorrect UserId or Password';
                              } else if (e.message.contains('User not found')) {
                                message = 'Account not found. Register now.';
                              } else {
                                print(e);
                                message =
                                    'An error occurred. Please check your credentials.';
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Unexpected error: $e')),
                              );
                            }
                          }
                        },
                        child: Text(
                          'SIGN IN',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('or'),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Don\'t have an account?',
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.black,
                    ),
                    child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Signuppage()),
                          );
                        },
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
