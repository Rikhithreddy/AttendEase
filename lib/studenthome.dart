import 'package:attendease/coursedetail.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Studenthome extends StatefulWidget {
  final String user;
  const Studenthome({super.key, required this.user});

  @override
  State<Studenthome> createState() => _StudenthomeState();
}

class _StudenthomeState extends State<Studenthome> {
  var coursestaken = [];
  var isloading = true;
  var selectedcourse;
  @override
  void initState() {
    super.initState();
    loadstudentcourses();
  }

  @override
  Widget build(BuildContext context) {
    return isloading == true
        ? Center(child: CircularProgressIndicator())
        : coursestaken.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Center(
                      child: Text(
                    'You Haven\'t Joined Any Course Yet. Join Now.',
                    style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  )),
                ),
              )
            : selectedcourse == -1
                ? Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(
                        'Enrolled Courses',
                        style: TextStyle(
                            color: const Color.fromARGB(255, 33, 33, 36),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic),
                      )),
                    ),
                    Expanded(
                        child: ListView.builder(
                      itemCount: coursestaken.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Icon(Icons.book,
                                    size: 30, color: Colors.blueAccent),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(coursestaken[index]['course_id'],
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                      SizedBox(height: 4),
                                      Text(
                                          "Name: ${coursestaken[index]['courses']['course_name']}"),
                                      Text(
                                          "Prof: ${coursestaken[index]['courses']['profdetails']['prof_name']}"),
                                      Text(
                                          "Credits: ${coursestaken[index]['courses']['credits']}"),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_forward_ios),
                                  onPressed: () {
                                    setState(() {
                                      selectedcourse = index;
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ))
                  ])
                : Coursedetail(
                    courseid: coursestaken[selectedcourse]['course_id'],
                    studentid: widget.user,
                    onBack: () {
                      setState(() {
                        selectedcourse = -1;
                      });
                    },
                  );
  }

  Future loadstudentcourses() async {
    final response = await Supabase.instance.client
        .from('data')
        .select('course_id,courses!data_course_id_fkey(course_name,prof_id,credits,profdetails!courses_prof_id_fkey(prof_name))')
        .eq('student_id', widget.user);
    if (response.isNotEmpty) {
      setState(() {
        coursestaken = response;
        isloading = false;
        selectedcourse = -1;
      });
    } else {
      setState(() {
        isloading = false;
        selectedcourse = -1;
      });
    }
  }
}
