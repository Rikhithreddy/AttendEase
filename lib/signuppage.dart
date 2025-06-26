import 'package:attendease/loginpage.dart';
import 'package:attendease/profdetails.dart';
import 'package:attendease/studentdetails.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Signuppage extends StatefulWidget {
  const Signuppage({super.key});

  @override
  State<Signuppage> createState() => _SignuppageState();
}

class _SignuppageState extends State<Signuppage> {
  var _useridcontroller = TextEditingController();
  var _passwordcontroller = TextEditingController();
  bool _hider = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 131, 145, 160),
      body: Center(
        child: Container(
          height: 450,
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
                  'SIGN UP',
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
                    width: 130,
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
                          } else if (_useridcontroller.text.trim()[0] != "p" &&
                              _useridcontroller.text.trim()[0] != "s") {
                            SnackBar profilesnack = SnackBar(
                                content: Text(
                                    'Invalid UserId. It should start with s or p'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(profilesnack);
                          } else if (_passwordcontroller.text.trim() == "") {
                            SnackBar profilesnack = SnackBar(
                                content: Text('Password cant\'t be empty.'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(profilesnack);
                          } else {
                            final supabase = Supabase.instance.client;

                            try {
                              final email = '${_useridcontroller.text.trim()}@iitg.ac.in';
                              final password = _passwordcontroller.text.trim();

                              final response = await supabase.auth.signUp(
                                email: email,
                                password: password,
                              );

                              if (response.user != null) {
                                var prefs =
                                    await SharedPreferences.getInstance();
                                setState(() {
                                  prefs.setString(
                                      'signupid', _useridcontroller.text.trim());
                                });
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => _useridcontroller.text.trim()[0]=="s"? Studentdetails(signupid: _useridcontroller.text.trim(),uid: response.user!.id.toString(),):Profdetails(signupid: _useridcontroller.text.trim(),uid: response.user!.id.toString(),)),
                                  (route) => false,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Signup failed.')),
                                );
                              }
                            } on AuthException catch (e) {
                              if (e.message.contains('password')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Password is too weak.')),
                                );
                              } else if (e.message
                                  .contains('already registered')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Account already exists.')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.message)),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                        child: Text(
                          'Create Account',
                          style: TextStyle(color: Colors.white, fontSize: 14),
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
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('or'),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Back to login?'),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => loginpage()),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Click here',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: const Color.fromARGB(255, 150, 66, 176)),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
