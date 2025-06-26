import 'package:attendease/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profprofile extends StatefulWidget {
  final String name;
  const Profprofile({super.key, required this.name});

  @override
  State<Profprofile> createState() => _ProfprofileState();
}

class _ProfprofileState extends State<Profprofile> {
  var _fullnamecontroller = TextEditingController();
  var _emailidcontroller = TextEditingController();
  var _dobcontroller = TextEditingController();
  var _mobilecontroller = TextEditingController();
  var _details;
  var _isuploading = false;
  var _edit = false;
  @override
  void initState() {
    super.initState();
    loaduserdetails();
  }

  @override
  Widget build(BuildContext context) {
    if (_details == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back)),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 104, 86, 165),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    _edit = true;
                    _fullnamecontroller =
                        TextEditingController(text: _details['prof_name']);
                    _emailidcontroller =
                        TextEditingController(text: _details['emailid']);
                    _dobcontroller =
                        TextEditingController(text: _details['dob']);
                    _mobilecontroller =
                        TextEditingController(text: _details['mobile']);
                  });
                },
                icon: Icon(Icons.edit)),
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirm Logout?'),
                          content: Text('Are you sure want to Logout'),
                          actions: [
                            TextButton(
                              child: Text('NO'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            TextButton(
                              child: Text('YES'),
                              onPressed: () async {
                                await Supabase.instance.client.auth.signOut();
                                var prefs =
                                    await SharedPreferences.getInstance();
                                setState(() {
                                  prefs.setString('loggedinuserid', "");
                                });

                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => loginpage()),
                                  (route) => false,
                                );
                              },
                            ),
                          ],
                        );
                      });
                },
                icon: Icon(Icons.logout))
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 203, 210, 240),
        body: ListView(
          children: [
            SizedBox(
              height: 15,
            ),
            Center(
              child: Container(
                height: 120,
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: _isuploading == true
                      ? CircularProgressIndicator()
                      : Image.network(
                          '${_details['imageurla']}',
                          fit: BoxFit.fill,
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Center(
                child: Text(
              widget.name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            )),
            SizedBox(
              height: 20,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text('Full Name')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextField(
                controller: _fullnamecontroller,
                enabled: _edit,
                decoration: InputDecoration(
                  hintText: _details['prof_name'],
                  isDense: true,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text('Email Id')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextField(
                controller: _emailidcontroller,
                enabled: _edit,
                decoration: InputDecoration(
                  hintText: _details['emailid'],
                  isDense: true,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text('DOB')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextField(
                controller: _dobcontroller,
                enabled: _edit,
                decoration: InputDecoration(
                  hintText: _details['dob'],
                  isDense: true,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text('Mobile No.')),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextField(
                controller: _mobilecontroller,
                enabled: _edit,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: _details['mobile'],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            _edit == true
                ? Center(
                    child: Container(
                        width: 150,
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () {
                              updateRow();
                              setState(() {
                                _edit = false;
                              });
                            },
                            child: Text(
                              'Save details',
                              style: TextStyle(fontSize: 16),
                            ))),
                  )
                : SizedBox(),
          ],
        ));
  }

  Future loaduserdetails() async {
    try {
      final response = await Supabase.instance.client
          .from("profdetails")
          .select()
          .eq('prof_id', widget.name);
      setState(() {
        _details = response[0];
      });
    } catch (e) {
      print("Error fetching details: $e");
    }
  }

  Future<void> updateRow() async {
    final response = await Supabase.instance.client.from('profdetails').update({
      'prof_name': _fullnamecontroller.text.trim(),
      'emailid': _emailidcontroller.text.trim(),
      'dob': _dobcontroller.text.trim(),
      'mobile': _mobilecontroller.text.trim(),
    }).eq('prof_id', widget.name);

    if (response != null) {
      print('Error: ${response.error?.message}');
    } else {
      print('Row updated successfully');
    }
  }
}
