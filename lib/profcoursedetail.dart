import 'package:attendease/studentclassdetail.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profcoursedetail extends StatefulWidget {
  final courseid, profid;
  final VoidCallback onBack;
  const Profcoursedetail(
      {super.key,
      required this.courseid,
      required this.profid,
      required this.onBack});

  @override
  State<Profcoursedetail> createState() => _ProfcoursedetailState();
}

class _ProfcoursedetailState extends State<Profcoursedetail> {
  var course = [];
  var selectedcourse = -1;
  @override
  void initState() {
    super.initState();
    loadcoursedetails();
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
                                        Text(course[index]['date'],
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                        SizedBox(height: 4),
                                        Text(
                                            '${course[index]['start']}-${course[index]['end']}',
                                            style: TextStyle(
                                                fontSize: 15,
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
        : Studentclassdetail(
            courseid: widget.courseid,
            onBack: () {
              setState(() {
                selectedcourse = -1;
              });
            },
          );
  }

  Future loadcoursedetails() async {
    final response = await Supabase.instance.client
        .from('activeclasses')
        .select()
        .eq('course_id', widget.courseid)
        .eq('prof_id', widget.profid);
    if (response.isNotEmpty) {
      print(response);
      setState(() {
        course = response;
      });
    }
  }
}
