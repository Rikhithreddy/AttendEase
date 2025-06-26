import 'package:attendease/coursedetail.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Studentclassdetail extends StatefulWidget {
  final courseid;
  final VoidCallback onBack;
  const Studentclassdetail(
      {super.key, required this.courseid, required this.onBack});

  @override
  State<Studentclassdetail> createState() => _StudentclassdetailState();
}

class _StudentclassdetailState extends State<Studentclassdetail> {
  var course = [];
  var selectedcourse = -1;
  @override
  void initState() {
    super.initState();
    loaddata();
  }

  @override
  Widget build(BuildContext context) {
    return selectedcourse == -1
        ? Column(
            children: [
              AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                ),
                title: Text(
                  widget.courseid,
                ),
                centerTitle: true,
                backgroundColor: const Color.fromARGB(255, 205, 204, 204),
              ),
              Expanded(
                child: course.isEmpty
                    ? Center(
                        child: Text('No students enrolled yet.'),
                      )
                    : ListView.builder(
                        itemCount: course.length,
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
                                        Text(course[index]['student_id'],
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                        SizedBox(height: 4),
                                        Text(course[index]['studentdetails']['student_name'],
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.arrow_forward_ios),
                                      onPressed: () {
                                        setState(() {
                                          selectedcourse = index;
                                        });
                                      })
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          )
        : Coursedetail(
            courseid: widget.courseid,
            studentid: course[selectedcourse]['student_id'],
            onBack: () {
              setState(() {
                selectedcourse = -1;
              });
            },
          );
  }

  Future loaddata() async {
    final response = await Supabase.instance.client
        .from('data')
        .select('*,studentdetails!data_student_id_fkey(student_name)')
        .eq('course_id', widget.courseid);
    if (response.isNotEmpty) {
      print(response);
      setState(() {
        course = response;
      });
    }
  }
}
