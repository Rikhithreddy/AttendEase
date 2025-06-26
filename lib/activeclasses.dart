import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Activeclasses extends StatefulWidget {
  final prof;
  const Activeclasses({super.key,required this.prof});

  @override
  State<Activeclasses> createState() => _ActiveclassesState();
}

class _ActiveclassesState extends State<Activeclasses> {
  var activeclass=[];
  var _isloading=true;
  @override
  void initState() {
    super.initState();
    loadactiveclasses();
  }
  @override
  Widget build(BuildContext context) {
    return _isloading==true?Center(child: CircularProgressIndicator()): Center(
      child: activeclass.isNotEmpty? Column(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                    'Active Classes',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 33, 33, 36),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic),
                  )),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: activeclass.length,
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
                                    Text(activeclass[index]['course_id'],
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black)),
                                    SizedBox(height: 4),
                                    Text('${activeclass[index]['start']}-${activeclass[index]['end']}'),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_forward_ios),
                                onPressed: () {},
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ]):Text('No Active classes right now.'),
    );
  }
  
  Future loadactiveclasses() async{
    String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response=await Supabase.instance.client.from('activeclasses').select().eq('prof_id', widget.prof).eq('date', _selectedDate);
    if(response.isNotEmpty){
      setState(() {
        activeclass=response;
        _isloading=false;
      });
    }else{
      setState(() {
        _isloading=false;
      });
    }
  }
}