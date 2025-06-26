import 'package:attendease/studentclassdetail.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profhome extends StatefulWidget {
  final user;
  const Profhome({super.key, required this.user});

  @override
  State<Profhome> createState() => _ProfhomeState();
}

class _ProfhomeState extends State<Profhome> {
  var coursesoffered = [];
  var isloading = true;
  var selectedcourse = -1;
  @override
  void initState() {
    super.initState();
    loadprofcourses();
  }

  @override
  Widget build(BuildContext context) {
    return isloading == true
        ? Center(child: CircularProgressIndicator())
        : selectedcourse == -1
            ? coursesoffered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Center(
                          child: Text(
                        'You Haven\'t Offered Any Course Yet. Add Now.',
                        style: TextStyle(
                            fontSize: 20, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      )),
                    ),
                  )
                : Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(
                        'Offered Courses',
                        style: TextStyle(
                            color: const Color.fromARGB(255, 33, 33, 36),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.italic),
                      )),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: coursesoffered.length,
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
                                        Text(coursesoffered[index]['course_id'],
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                        SizedBox(height: 4),
                                        Text(
                                            "Name: ${coursesoffered[index]['course_name']}"),
                                        Text(
                                            "Credits: ${coursesoffered[index]['credits']}"),
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
                      ),
                    ),
                  ])
            : Studentclassdetail(
                courseid: coursesoffered[selectedcourse]['course_id'],
                onBack: () {
                  setState(() {
                    selectedcourse = -1;
                  });
                },
              );
  }

  Future loadprofcourses() async {
    final response = await Supabase.instance.client
        .from('courses')
        .select()
        .eq('prof_id',widget.user);
    if (response.isNotEmpty) {
      setState(() {
        coursesoffered = response;
        isloading = false;
      });
    } else {
      setState(() {
        isloading = false;
      });
    }
  }
}
