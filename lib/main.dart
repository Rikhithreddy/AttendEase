import 'package:attendease/homepage.dart';
import 'package:attendease/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://jbuibwkzafvrnsnzjygt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpidWlid2t6YWZ2cm5zbnpqeWd0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDcxMDE3ODMsImV4cCI6MjA2MjY3Nzc4M30.eqqPvSS_OmGsp_kcP_ES_cQdHdyyJTfhRL7rvS9V7C4',
  );
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _loggedinuserid="";

  @override
  void initState() {
    super.initState();
    loaduser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _loggedinuserid==""? loginpage():Homepage(),
    );
  }

  Future loaduser() async{
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedinuserid = prefs.getString('loggedinuserid') ?? "";
    });
  }
}

