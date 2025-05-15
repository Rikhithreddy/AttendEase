import 'dart:io';
import 'package:attendease/loginpage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Studentdetails extends StatefulWidget {
  final signupid;
  final uid;
  const Studentdetails({super.key, required this.signupid, required this.uid});

  @override
  State<Studentdetails> createState() => _StudentdetailsState();
}

class _StudentdetailsState extends State<Studentdetails> {
  var _fullnamecontoller = TextEditingController();
  var _emailidcontroller = TextEditingController();
  var _dobcontroller = TextEditingController();
  var _programmecontroller = TextEditingController();
  var _branchnamecontroller = TextEditingController();
  var _mobilenocontroller = TextEditingController();
  final supabase = Supabase.instance.client;
  var _profileurla = "";
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'User Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 210, 177, 57),
        ),
        backgroundColor: const Color.fromARGB(255, 165, 170, 176),
        body: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: _fullnamecontoller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: 'Full Name'),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: _emailidcontroller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: 'EmailId'),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: _dobcontroller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: 'DOB'),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: _programmecontroller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: 'Programme'),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: _branchnamecontroller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: 'Branch'),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: _mobilenocontroller,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: 'MobileNo'),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Select Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _pickImage(ImageSource.gallery);
                  },
                  label: Text('Gallery'),
                  icon: Icon(Icons.image_outlined),
                ),
                SizedBox(
                  width: 20,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _pickImage(ImageSource.camera);
                  },
                  label: Text('Camera'),
                  icon: Icon(Icons.camera),
                )
              ],
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
                    onPressed: () {
                      insertStudentData();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => loginpage()),
                        (route) => false,
                      );
                    },
                    child: Text(
                      'Save Details',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    )),
              ),
            ),
          ],
        ));
  }

  Future<void> _pickImage(ImageSource src) async {
    final XFile? pickedFile = await _picker.pickImage(source: src);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadToSupabase(_image!);
    }
  }

  Future<void> _uploadToSupabase(File image) async {
    try {
      await supabase.storage
          .from('profiles')
          .upload('pictures/${widget.signupid}', image);
      setState(() {
        _profileurla = supabase.storage
            .from('profiles')
            .getPublicUrl('pictures/${widget.signupid}');
      });
    } catch (e) {
      print('Upload failed: $e');
    }
  }

  Future<void> insertStudentData() async {
    await supabase.from('studentdetails').insert({
      'id': widget.signupid,
      'fullname': _fullnamecontoller.text.trim(),
      'emailid': _emailidcontroller.text.trim(),
      'dob': _dobcontroller.text.trim(),
      'programme': _programmecontroller.text.trim(),
      'branch': _branchnamecontroller.text.trim(),
      'mobile': _mobilenocontroller.text.trim(),
      'imageurla': _profileurla,
      'uid': widget.uid,
    });
  }
}
