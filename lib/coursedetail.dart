import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Coursedetail extends StatefulWidget {
  final courseid, studentid;
  final VoidCallback onBack;
  const Coursedetail(
      {super.key,
      required this.courseid,
      required this.studentid,
      required this.onBack});

  @override
  State<Coursedetail> createState() => _CoursedetailState();
}

class _CoursedetailState extends State<Coursedetail> {
  var course = [];
  @override
  void initState() {
    super.initState();
    loadcoursedetails();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          title: Text(widget.courseid),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 205, 204, 204),
        ),
        Expanded(
          child: course.isEmpty
              ? Center(
                  child: Text('No classes found.'),
                )
              : ListView.builder(
                  itemCount: course.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(course[index]['date'],
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                  SizedBox(height: 4),
                                  Text(
                                      '${course[index]['start']}-${course[index]['end']}',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.black)),
                                ],
                              ),
                            ),
                            IconButton(
                                icon: Icon(Icons.circle_sharp),
                                color: course[index]['attendance'].isEmpty
                                    ? Colors.red
                                    : Colors.green,
                                onPressed: () {})
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future loadcoursedetails() async {
    final response = await Supabase.instance.client
        .from('activeclasses')
        .select('*,attendance(*)')
        .eq('course_id', widget.courseid)
        .eq('attendance.student_id', widget.studentid);
    if (response.isNotEmpty) {
      setState(() {
        course = response;
      });
    }
  }
}
