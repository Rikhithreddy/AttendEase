import 'dart:io';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;

class Activeattendance extends StatefulWidget {
  final user;
  const Activeattendance({super.key, required this.user});

  @override
  State<Activeattendance> createState() => _ActiveattendanceState();
}

class _ActiveattendanceState extends State<Activeattendance> {
  var activeattendance = [];
  var _isloading = true;
  var face = false, location = false;
  var latitude, longitude;
  @override
  void initState() {
    super.initState();
    loadactiveattendance();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isloading == true
          ? CircularProgressIndicator()
          : activeattendance.isNotEmpty
              ? Column(children: [
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
                      itemCount: activeattendance.length,
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
                                      Text(activeattendance[index]['course_id'],
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                      SizedBox(height: 4),
                                      Text(
                                          '${activeattendance[index]['activeclasses'][0]['start']}-${activeattendance[index]['activeclasses'][0]['end']}'),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.circle_sharp),
                                  color: activeattendance[index]['activeclasses'][0]['attendance']
                                          .isNotEmpty
                                      ? Colors.green
                                      : Colors.red,
                                  onPressed: () {
                                    activeattendance[index]['activeclasses'][0]['attendance']
                                            .isNotEmpty
                                        ? showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text('DONE'),
                                                content: Text(
                                                    'Already marked the attendance.'),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text('Ok'))
                                                ],
                                              );
                                            })
                                        : isTimeALessThanB(
                                                DateFormat.jm()
                                                    .format(DateTime.now()),
                                                activeattendance[index]
                                                        ['activeclasses'][0]
                                                    ['start'])
                                            ? showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text('Early.'),
                                                    content: Text(
                                                        'Class not started yet.Come back at ${activeattendance[index]['activeclasses'][0]['start']}.'),
                                                    actions: [
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text('Ok'))
                                                    ],
                                                  );
                                                })
                                            : isTimeALessThanB(
                                                    activeattendance[index]
                                                            ['activeclasses'][0]
                                                        ['end'],
                                                    DateFormat.jm()
                                                        .format(DateTime.now()))
                                                ? showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Text('Time Up.'),
                                                        content: Text(
                                                            'Class has completed.Sorry.'),
                                                        actions: [
                                                          ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Text('Ok'))
                                                        ],
                                                      );
                                                    })
                                                : showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Center(
                                                          child: Text(
                                                            'Mark Attendance',
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            TextButton.icon(
                                                              onPressed:
                                                                  () async {
                                                                final imageFromCamera =
                                                                    await pickImageFromCamera();
                                                                if (imageFromCamera ==
                                                                    null) {
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return AlertDialog(
                                                                          title:
                                                                              Text('Error!'),
                                                                          content:
                                                                              Text('Image capturing failed.Try again.'),
                                                                          actions: [
                                                                            ElevatedButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Text('Ok'))
                                                                          ],
                                                                        );
                                                                      });
                                                                } else {
                                                                  final imageFromUrl =
                                                                      await loadImageFromUrl(
                                                                          "https://jbuibwkzafvrnsnzjygt.supabase.co/storage/v1/object/public/profiles/pictures/${widget.user}");
                                                                  final face1 =
                                                                      await detectFace(
                                                                          imageFromCamera);
                                                                  final face2 =
                                                                      await detectFace(
                                                                          imageFromUrl);
                                                                  if (face1 ==
                                                                          null ||
                                                                      face2 ==
                                                                          null) {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text('Error!'),
                                                                            content:
                                                                                Text('No face detected.'),
                                                                            actions: [
                                                                              ElevatedButton(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Text('Ok'))
                                                                            ],
                                                                          );
                                                                        });
                                                                  } else {
                                                                    final isSame =
                                                                        areFacesRoughlySame(
                                                                            face1,
                                                                            face2);
                                                                    if (isSame ==
                                                                        false) {
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (context) {
                                                                            return AlertDialog(
                                                                              title: Text('Error!'),
                                                                              content: Text('Face doesn\'t match.'),
                                                                              actions: [
                                                                                ElevatedButton(
                                                                                    onPressed: () {
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: Text('Ok'))
                                                                              ],
                                                                            );
                                                                          });
                                                                    } else {
                                                                      setState(
                                                                          () {
                                                                        face =
                                                                            true;
                                                                      });
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (context) {
                                                                            return AlertDialog(
                                                                              title: Text('Done'),
                                                                              content: Text('Face matched.'),
                                                                              actions: [
                                                                                ElevatedButton(
                                                                                    onPressed: () {
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    child: Text('Ok'))
                                                                              ],
                                                                            );
                                                                          });
                                                                    }
                                                                  }
                                                                }
                                                              },
                                                              label: Text(
                                                                  'Recognize Face'),
                                                              icon: Icon(Icons
                                                                  .camera_alt),
                                                              style: ButtonStyle(
                                                                  iconSize:
                                                                      WidgetStatePropertyAll(
                                                                          25)),
                                                            ),
                                                            TextButton.icon(
                                                              onPressed:
                                                                  () async {
                                                                Position? loac =
                                                                    await getCurrentLocation(
                                                                        context);
                                                                if (loac !=
                                                                    null) {
                                                                  setState(() {
                                                                    latitude = loac
                                                                        .latitude;
                                                                    longitude =
                                                                        loac.longitude;
                                                                  });
                                                                  double precise = _calculateDistance(
                                                                      latitude,
                                                                      longitude,
                                                                      double.parse(activeattendance[index]['activeclasses']
                                                                              [
                                                                              0]
                                                                          [
                                                                          'latitude']),
                                                                      double.parse(activeattendance[index]
                                                                              [
                                                                              'activeclasses'][0]
                                                                          [
                                                                          'longitude']));
                                                                  if (precise <=
                                                                      50) {
                                                                    setState(
                                                                        () {
                                                                      location =
                                                                          true;
                                                                    });
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text('Done'),
                                                                            content:
                                                                                Text('Location is within the range.'),
                                                                            actions: [
                                                                              ElevatedButton(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Text('Ok'))
                                                                            ],
                                                                          );
                                                                        });
                                                                  } else {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text('Error!'),
                                                                            content:
                                                                                Text('Location is not in the range.'),
                                                                            actions: [
                                                                              ElevatedButton(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Text('Ok'))
                                                                            ],
                                                                          );
                                                                        });
                                                                  }
                                                                } else {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) =>
                                                                            AlertDialog(
                                                                      title: Text(
                                                                          'Error!!'),
                                                                      content: Text(
                                                                          'Location fetching failed.Try again.'),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed: () =>
                                                                                Navigator.of(context).pop(),
                                                                            child: Text('OK')),
                                                                      ],
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              label: Text(
                                                                  'Check Location'),
                                                              icon: Icon(Icons
                                                                  .location_history_rounded),
                                                              style: ButtonStyle(
                                                                  iconSize:
                                                                      WidgetStatePropertyAll(
                                                                          25)),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Container(
                                                              width: 80,
                                                              height: 50,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15),
                                                                  color: Colors
                                                                      .black),
                                                              child: TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  if (face ==
                                                                      false) {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text('Error!'),
                                                                            content:
                                                                                Text('Face not verified.'),
                                                                            actions: [
                                                                              ElevatedButton(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Text('Ok'))
                                                                            ],
                                                                          );
                                                                        });
                                                                  } else if (location ==
                                                                      false) {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text('Error!'),
                                                                            content:
                                                                                Text('Location is not in the range.'),
                                                                            actions: [
                                                                              ElevatedButton(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Text('Ok'))
                                                                            ],
                                                                          );
                                                                        });
                                                                  } else {
                                                                    await Supabase
                                                                        .instance
                                                                        .client
                                                                        .from(
                                                                            'attendance')
                                                                        .insert({
                                                                      'student_id':
                                                                          widget
                                                                              .user,
                                                                      'course_id':
                                                                          activeattendance[index]
                                                                              [
                                                                              'course_id'],
                                                                      'date': DateFormat(
                                                                              'yyyy-MM-dd')
                                                                          .format(
                                                                              DateTime.now()),
                                                                      'time': DateFormat
                                                                              .jm()
                                                                          .format(
                                                                              DateTime.now())
                                                                    });
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                Text('Done'),
                                                                            content:
                                                                                Text('Attendance marked successfully.'),
                                                                            actions: [
                                                                              ElevatedButton(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Text('Ok'))
                                                                            ],
                                                                          );
                                                                        });
                                                                  }
                                                                },
                                                                child: Text(
                                                                  'MARK',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      );
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
              : Text('No Active Classes right now.'),
    );
  }

  Future loadactiveattendance() async {
    String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response = await Supabase.instance.client
  .from('courses')
  .select('''
    *,
    data:data_course_id_fkey!inner(*),
    activeclasses:activeclasses_course_id_fkey!inner(
      *,
      attendance(*)
    )
  ''')
  .eq('data.student_id', widget.user)
  .eq('activeclasses.date', _selectedDate);





    print(response);
    if (response.isNotEmpty) {
      setState(() {
        activeattendance = response;
        _isloading = false;
      });
    } else {
      setState(() {
        _isloading = false;
      });
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Radius of Earth in meters
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double degree) {
    return degree * pi / 180;
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
          content:
              Text('Please enable location services in your device settings.'),
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

  bool isTimeALessThanB(String a, String b) {
    final format = DateFormat('h:mm a');

    a = a.replaceAll(RegExp(r'\s+'), ' ').replaceAll('\u202F', ' ').trim();
    b = b.replaceAll(RegExp(r'\s+'), ' ').replaceAll('\u202F', ' ').trim();

    try {
      final timeA = format.parse(a);
      final timeB = format.parse(b);
      return timeA.isBefore(timeB);
    } catch (e) {
      print('Time parsing error: $e');
      return false;
    }
  }

  Future<InputImage> loadImageFromUrl(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) throw Exception('Failed to load image');
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/url_image.jpg');
    await file.writeAsBytes(response.bodyBytes);
    return InputImage.fromFilePath(file.path);
  }

  Future<InputImage?> pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return null;
    return InputImage.fromFilePath(pickedFile.path);
  }

  Future<Face?> detectFace(InputImage image) async {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    final faces = await faceDetector.processImage(image);
    await faceDetector.close();
    return faces.isNotEmpty ? faces.first : null;
  }

  double euclidean(Offset p1, Offset p2) =>
      ((p1.dx - p2.dx).abs() + (p1.dy - p2.dy).abs());

  double? normalizedDist(
      Face face, FaceLandmarkType a, FaceLandmarkType b, double normalizeBy) {
    final p1Raw = face.landmarks[a]?.position;
    final p2Raw = face.landmarks[b]?.position;
    if (p1Raw == null || p2Raw == null) return null;

    final p1 = Offset(p1Raw.x.toDouble(), p1Raw.y.toDouble());
    final p2 = Offset(p2Raw.x.toDouble(), p2Raw.y.toDouble());

    return (p1 - p2).distance / normalizeBy;
  }

  bool areFacesRoughlySame(Face face1, Face face2) {
    final double width1 = face1.boundingBox.width;
    final double width2 = face2.boundingBox.width;

    List<bool> matchedMetrics = [];

    // Eye distance (left ↔ right)
    final eyeDist1 = normalizedDist(
        face1, FaceLandmarkType.leftEye, FaceLandmarkType.rightEye, width1);
    final eyeDist2 = normalizedDist(
        face2, FaceLandmarkType.leftEye, FaceLandmarkType.rightEye, width2);
    if (eyeDist1 != null && eyeDist2 != null) {
      matchedMetrics.add((eyeDist1 - eyeDist2).abs() < 0.04);
    }

    // Nose to left eye
    final noseLeft1 = normalizedDist(
        face1, FaceLandmarkType.noseBase, FaceLandmarkType.leftEye, width1);
    final noseLeft2 = normalizedDist(
        face2, FaceLandmarkType.noseBase, FaceLandmarkType.leftEye, width2);
    if (noseLeft1 != null && noseLeft2 != null) {
      matchedMetrics.add((noseLeft1 - noseLeft2).abs() < 0.04);
    }

    // Nose to right eye
    final noseRight1 = normalizedDist(
        face1, FaceLandmarkType.noseBase, FaceLandmarkType.rightEye, width1);
    final noseRight2 = normalizedDist(
        face2, FaceLandmarkType.noseBase, FaceLandmarkType.rightEye, width2);
    if (noseRight1 != null && noseRight2 != null) {
      matchedMetrics.add((noseRight1 - noseRight2).abs() < 0.04);
    }

    // Face width-to-height ratio
    final faceRatio1 = face1.boundingBox.width / face1.boundingBox.height;
    final faceRatio2 = face2.boundingBox.width / face2.boundingBox.height;
    matchedMetrics.add((faceRatio1 - faceRatio2).abs() < 0.04);

    // Count how many metrics matched
    int matches = matchedMetrics.where((match) => match).length;

    // You can tweak the threshold (e.g., require at least 3 of 4 to match)
    return matches >= 3;
  }
//   Future<bool> compareFaces(File face1, File face2) async {
//   final interpreter = await Interpreter.fromAsset('mobilefacenet.tflite');

//   Future<List<double>?> getEmbedding(File imageFile) async {
//     final bytes = await imageFile.readAsBytes();
//     final image = img.decodeImage(bytes);
//     if (image == null) return null;

//     final resized = img.copyResizeCropSquare(image, 112); // MobileFaceNet input size

//     var input = List.generate(1, (_) => List.generate(112, (i) => List.generate(112, (j) {
//       final pixel = resized.getPixel(j, i);
//       return [
//         (img.getRed(pixel) - 127.5) / 128,
//         (img.getGreen(pixel) - 127.5) / 128,
//         (img.getBlue(pixel) - 127.5) / 128
//       ];
//     })));

//     var output = List.generate(1, (_) => List.filled(192, 0.0));
//     interpreter.run(input, output);
//     return output[0];
//   }

//   double cosineSimilarity(List<double> a, List<double> b) {
//     double dot = 0.0, normA = 0.0, normB = 0.0;
//     for (int i = 0; i < a.length; i++) {
//       dot += a[i] * b[i];
//       normA += a[i] * a[i];
//       normB += b[i] * b[i];
//     }
//     return dot / (sqrt(normA) * sqrt(normB));
//   }

//   final emb1 = await getEmbedding(face1);
//   final emb2 = await getEmbedding(face2);

//   if (emb1 == null || emb2 == null) return false;

//   final similarity = cosineSimilarity(emb1, emb2);
//   return similarity > 0.5; // You can fine-tune this threshold
// }
}