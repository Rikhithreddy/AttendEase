import 'package:attendease/activeattendance.dart';
import 'package:attendease/activeclasses.dart';
import 'package:attendease/profhome.dart';
import 'package:attendease/profprofile.dart';
import 'package:attendease/studenthome.dart';
import 'package:attendease/studentprofile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedindex = 0;
  var _isloading = true;
  var _refreshKey;

  void refresh() {
    setState(() {
      _refreshKey = DateTime.now().toIso8601String();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedindex = index;
    });
  }

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
        title: Text(
          'Attendance',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 104, 86, 165),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => _user[0] == "s"
                            ? Studentprofile(name: _user)
                            : Profprofile(
                                name: _user,
                              )));
              },
              icon: Icon(Icons.person))
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 183, 182, 182),
      body: _isloading == true
          ? CircularProgressIndicator()
          : _user[0] == 's'
              ? (_selectedindex == 0
                  ? Studenthome(
                      key: ValueKey(_refreshKey),
                      user: _user,
                    )
                  : Activeattendance(user: _user,))
              : (_selectedindex == 0
                  ? Profhome(
                      key: ValueKey(_refreshKey),
                      user: _user,
                    )
                  : Activeclasses(prof: _user,)),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 104, 86, 165),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedindex,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.calendar_month_sharp,
              ),
              label: "Active Classes")
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _user[0]=='s'? (_selectedindex==0?joincourse(context):()):(_selectedindex==0?addcourse(context):addclass());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future loadsigninid() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      _user = prefs.getString('loggedinuserid') ?? "";
      _isloading = false;
    });
  }

  joincourse(BuildContext oldcont) {
    var courseidcontroller = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
                child: Text(
              'JOIN COURSE',
              style: TextStyle(
                  fontSize: 20,
                  color: const Color.fromARGB(255, 119, 126, 188)),
            )),
            titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Course Id'),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                    controller: courseidcontroller,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black),
                    child: TextButton(
                        onPressed: () async {
                          if (courseidcontroller.text.trim() == "") {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Empty Field!'),
                                    content: Text('Course Id can\'t be empty.'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Ok')),
                                    ],
                                  );
                                });
                          } else {
                            final user =
                                Supabase.instance.client.auth.currentUser;
                            try {
                              await Supabase.instance.client
                                  .from('data')
                                  .insert({
                                'course_id': courseidcontroller.text.trim(),
                                'student_id': _user,
                                'user_id': user!.id,
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(oldcont).showSnackBar(
                                SnackBar(
                                  content: Text('Joined Course Successfully.'),
                                ),
                              );
                              refresh();
                            } catch (e) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(oldcont).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Course Joining Failed.Already Joined or not Available.Check the Course ID.'),
                                ),
                              );
                              print('Insert error: $e');
                            }
                          }
                        },
                        child: Text(
                          'JOIN',
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                )
              ],
            ),
          );
        });
  }

  addcourse(BuildContext oldcont) {
    var courseidcontroller = TextEditingController();
    var coursenamecontroller = TextEditingController();
    var creditcontroller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'ADD COURSE',
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 119, 126, 188),
              ),
            ),
          ),
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('Course Id'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  controller: courseidcontroller,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('Course Name'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  controller: coursenamecontroller,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('Credits'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  controller: creditcontroller,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black,
                  ),
                  child: TextButton(
                    onPressed: () async {
                      if (courseidcontroller.text.trim() == "") {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Empty Field!'),
                                content: Text('Course Id can\'t be empty.'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Ok')),
                                ],
                              );
                            });
                      } else if (coursenamecontroller.text.trim() == "") {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Empty Field!'),
                                content: Text('Course name can\'t be empty.'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Ok')),
                                ],
                              );
                            });
                      } else {
                        final user = Supabase.instance.client.auth.currentUser;

                        try {
                          await Supabase.instance.client
                              .from('courses')
                              .insert({
                            'course_id': courseidcontroller.text.trim(),
                            'course_name': coursenamecontroller.text.trim(),
                            'prof_id': _user,
                            'user_id': user!.id,
                            'credits': creditcontroller.text.trim()
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(oldcont).showSnackBar(
                            SnackBar(
                                content: Text('Course Added Successfully.')),
                          );
                          refresh();
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(oldcont).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Course Adding Unsuccessful. Try Again.')),
                          );
                          print('Insert error: $e');
                        }
                      }
                    },
                    child: Text(
                      'ADD',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  addclass() {
    var courseidcontroller = TextEditingController();
    var datecontroller = TextEditingController();
    var starttimecontroller = TextEditingController();
    var endtimecontroller = TextEditingController();
    var latitude, longitude;
    String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String _selectedTime =
        TimeOfDay.fromDateTime(DateTime.now()).format(context).toString();
    datecontroller.text = _selectedDate;
    starttimecontroller.text =
        TimeOfDay.fromDateTime(DateTime.now()).format(context).toString();
    endtimecontroller.text =
        TimeOfDay.fromDateTime(DateTime.now()).format(context).toString();
    Future<void> _pickDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null &&
          DateFormat('yyyy-MM-dd').format(picked) != _selectedDate) {
        setState(() {
          _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
          datecontroller.text = _selectedDate;
        });
        print(_selectedDate);
      }
    }

    Future<void> _selectStartTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (picked != null && picked != _selectedTime) {
        setState(() {
          _selectedTime = picked.format(context).toString();
          starttimecontroller.text = _selectedTime;
        });
      }
    }

    Future<void> _selectEndTime(BuildContext context) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (picked != null && picked != _selectedTime) {
        setState(() {
          _selectedTime = picked.format(context).toString();
          endtimecontroller.text = _selectedTime;
        });
      }
    }

    Future<Position?> getCurrentLocation(BuildContext context) async {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Location Disabled'),
            content: Text(
                'Please enable location services in your device settings.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK')),
            ],
          ),
        );
        return null;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Permission Denied'),
              content: Text(
                  'Location permission denied. Please allow location access.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK')),
              ],
            ),
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Permission Denied Permanently'),
            content: Text(
                'Location permission is permanently denied. Please enable it manually from app settings.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK')),
            ],
          ),
        );
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    }

    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: SingleChildScrollView(
              child: AlertDialog(
                title: Center(
                    child: Text(
                  'Add Class',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                )),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Course Id'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        controller: courseidcontroller,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Date'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  _pickDate(context);
                                },
                                icon: Icon(Icons.calendar_month_sharp))),
                        readOnly: true,
                        controller: datecontroller,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Start Time'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  _selectStartTime(context);
                                },
                                icon: Icon(Icons.access_time_sharp))),
                        readOnly: true,
                        controller: starttimecontroller,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('End Time'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  _selectEndTime(context);
                                },
                                icon: Icon(Icons.access_time_sharp))),
                        readOnly: true,
                        controller: endtimecontroller,
                      ),
                    ),
                    Center(
                        child: TextButton.icon(
                      onPressed: () async {
                        Position? loac = await getCurrentLocation(context);
                        if (loac != null) {
                          setState(() {
                            latitude = loac.latitude;
                            longitude = loac.longitude;
                          });
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Error!!'),
                              content: Text('Location fetching failed.Try again.'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: Text('OK')),
                              ],
                            ),
                          );
                        }
                      },
                      label: Text(
                        'get location',
                        style: TextStyle(fontSize: 16),
                      ),
                      icon: Icon(
                        Icons.location_on,
                      ),
                      style: ButtonStyle(
                        iconSize: WidgetStatePropertyAll(25),
                      ),
                    )),
                    Center(
                      child: Padding(
                          padding: const EdgeInsets.all(
                            8.0,
                          ),
                          child: Container(
                            height: 40,
                            width: 75,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.black),
                            child: TextButton(
                                onPressed: () async {
                                  if (courseidcontroller.text == "") {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Error!!'),
                                        content: Text('CourseId can\'t be empty.'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text('OK')),
                                        ],
                                      ),
                                    );
                                  } else {
                                    final data = await Supabase.instance.client
                                        .from('courses')
                                        .select()
                                        .eq('course_id',
                                            courseidcontroller.text.trim())
                                        .eq('prof_id', _user);
                                    if (data.isEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Error!!'),
                                          content: Text(
                                              'You haven\'t offered the course ${courseidcontroller.text.trim()}'),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: Text('OK')),
                                          ],
                                        ),
                                      );
                                    } else if (latitude == null ||
                                        longitude == null) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Error!!'),
                                          content: Text('Invalid loaction.'),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: Text('OK')),
                                          ],
                                        ),
                                      );
                                    } else {
                                      try {
                                        await Supabase.instance.client
                                            .from('activeclasses')
                                            .insert({
                                          'course_id':
                                              courseidcontroller.text.trim(),
                                          'prof_id': _user,
                                          'start': starttimecontroller.text.trim(),
                                          'end': endtimecontroller.text.trim(),
                                          'latitude': latitude,
                                          'longitude': longitude,
                                          'date': datecontroller.text.trim()
                                        });
                                        Navigator.pop(context);
                                      } catch (e) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Error!!'),
                                            content: Text('Adding class failed.Try again.'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context).pop(),
                                                  child: Text('OK')),
                                            ],
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: Text(
                                  'ADD',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                )),
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
