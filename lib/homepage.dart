import 'package:attendease/profprofile.dart';
import 'package:attendease/studentprofile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  var _user = "";
  @override
  void initState() {
    super.initState();
    loadsigninid();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm Exit?'),
                      content: Text('Are you sure want to exit'),
                      actions: [
                        TextButton(
                          child: Text('NO'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: Text('YES'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            SystemNavigator.pop();
                          },
                        ),
                      ],
                    );
                  });
            },
            icon: Icon(Icons.exit_to_app)),
            title: Text('Attendance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 104, 86, 165),
            foregroundColor: Colors.white,
            actions: [
              IconButton(onPressed: (){}, icon: Icon(Icons.notifications)),
              IconButton(onPressed: (){
                Navigator.push(context, 
                MaterialPageRoute(builder: (context)=>_user[0]=="s"? Studentprofile(name: _user): Profprofile(name: _user,)));
              }, icon: Icon(Icons.person))
            ],
      ),
    );
  }
  Future loadsigninid() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      _user = prefs.getString('loggedinuserid') ?? "";
    });
    
  }
}
