import 'dart:io';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:amd/readFileResult.dart';
import 'package:amd/readDir.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AMD',
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Android Malware Detection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// {"App metadata": {"Package Name:": "com.optimesoftware.tictactoe.free", "App Name:": "Tic Tac Toe Free", "Version Name:": "1.50", "Version Code:": "19"}, "Permission": {"py/set":
// ["WRITE_EXTERNAL_STORAGE", "ACCESS_NETWORK_STATE", "READ_PHONE_STATE", "ACCESS_WIFI_STATE", "INTERNET"]}, "Actions": {"py/set": ["android.intent.action.MAIN",
// "com.android.DIALOG_ACTIVITY", "com.android.BOARD", "com.android.MOREGAMES", "com.android.TWO_PLAYER", "com.praumtech.tictactoe.WELCOME_ACTIVITY", "com.android.OPTIONS",
// "com.android.ONE_PLAYER"]}, "Result": "File is Benign"}

Future<Map<String, String>> _getAllHashes(String path) async {
  final sha256Hash = await sha256.bind(File(path).openRead()).first;
  final sha1Hash = await md5.bind(File(path).openRead()).first;
  final md5Hash = await sha1.bind(File(path).openRead()).first;
  return {
    'sha256Hash': sha256Hash.toString(),
    'sha1Hash': sha1Hash.toString(),
    'md5Hash': md5Hash.toString(),
  };
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;

  //https://mds-hr2e.onrender.com
  Future<void> _fetchData(String file, Map<String, String> hashes) async {
    print('fetching data');
    setState(() {
      _isLoading = true;
    });
    try {
      // test = https://randomuser.me/api/?results=2

      // String url = "http://127.0.0.1:8000/" + "tic-tac-toe";
      String url = "https://mds-hr2e.onrender.com/file/" + file;
      String urlsha256 = "https://mds-hr2e.onrender.com/db/findSHA256/" +
          hashes['sha256Hash']!;
      String urlsha1 =
          "https://mds-hr2e.onrender.com/db/findSHA1/" + hashes['sha1Hash']!;
      String urlmd5 =
          "https://mds-hr2e.onrender.com/db/findMD5/" + hashes['md5Hash']!;
      final res = await http.get(Uri.parse(url));
      final getsha256Match = await http.post(Uri.parse(urlsha256));
      final getsha1Match = await http.post(Uri.parse(urlsha1));
      final getmd5Match = await http.post(Uri.parse(urlmd5));

      if (res.statusCode == 200 &&
          getsha256Match.statusCode == 200 &&
          getsha1Match.statusCode == 200 &&
          getmd5Match.statusCode == 200) {
        // Successful response
        // print('Response data: ${response.body}');
        setState(() {
          final data = jsonDecode(res.body);

          // Map<String, dynamic> map = json.decode(data);
          data['sha256'] = int.parse(getsha256Match.body) > 0 ? true : false;
          data['sha1'] = int.parse(getsha1Match.body) > 0 ? true : false;
          data['md5'] = int.parse(getmd5Match.body) > 0 ? true : false;
          print(data.runtimeType);
          // print(data);
          // print(map.runtimeType);

          AppInfo appInfo = AppInfo.fromJson(data);

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MetadataScreen(data: data),
            ),
          );
          // print(map.runtimeType);
          // print(appInfo.appMetadata);
          // print(appInfo.permission);
          // print(appInfo.actions);
          // print(appInfo.result);
        });
      } else {
        // Handle errors (e.g., network issues, invalid URL, etc.)
        print(
            '${res.statusCode}-${getmd5Match.statusCode}-${getsha256Match.statusCode}-${getsha1Match.statusCode}');
        showToast(
            'Request failed with status: ${res.statusCode}-${getmd5Match.statusCode}-${getsha256Match.statusCode}-${getsha1Match.statusCode}',
            context: context);
      }
    } catch (e) {
      showToast('error $e', context: context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _readFile() async {
    try {
      showToast('Reading file..', context: context);
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(allowMultiple: false);
      if (result != null) {
        PlatformFile filemeta = result.files.first;
        // _fetchData(filemeta.name);
        File file = File(filemeta.path!);
        if (await file.exists()) {
          showToast('file exist', context: context);
          _getAllHashes(file.path)
              .then((hashes) =>
                  {print('hashes: $hashes'), _fetchData(filemeta.name, hashes)})
              .catchError((e) => print('error $e'));
        } else {
          showToast('file not exist..', context: context);
        }
      } else {
        showToast('Cancel', context: context);
      }
    } catch (e) {
      print('err');
      print(e);
    }
  }

  void _readDir() async {
    try {
      String? dir = await FilePicker.platform.getDirectoryPath();
      if (dir != null) {
        showToast(dir + ' Chose ', context: context);
        final directory = Directory(dir);
        if (await directory.exists()) {
          String url = "https://mds-hr2e.onrender.com/dir/testAPK";
          final res = await http.get(Uri.parse(url));
          if (res.statusCode == 200) {
            final list = jsonDecode(res.body);

            List<AppInfo> parseAppInfo(String jsonString) {
              final Map<String, dynamic> jsonData = jsonDecode(jsonString);
              return jsonData.entries.map((entry) {
                return AppInfo.fromJson(entry.value);
              }).toList();
            }

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    AppListWidget(appInfos: parseAppInfo(res.body)),
              ),
            );
          } else {
            showToast('${res.statusCode}', context: context);
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                // Column is also a layout widget. It takes a list of children and
                // arranges them vertically. By default, it sizes itself to fit its
                // children horizontally, and tries to be as tall as its parent.
                //
                // Column has various properties to control how it sizes itself and
                // how it positions its children. Here we use mainAxisAlignment to
                // center the children vertically; the main axis here is the vertical
                // axis because Columns are vertical (the cross axis would be
                // horizontal).
                //
                // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
                // action in the IDE, or press "p" in the console), to see the
                // wireframe for each widget.
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(15)),
                          shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.blueAccent))),
                        ),
                        onPressed: _readFile,
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.file_open_sharp,
                                  color: Colors.lightBlue,
                                ),
                              ),
                              Text(
                                'Read file',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.lightBlue),
                              ),
                            ],
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(15)),
                          shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.blueAccent))),
                        ),
                        onPressed: _readDir,
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.folder_copy,
                                  color: Colors.lightBlue,
                                ),
                              ),
                              Text(
                                'Choose a directory',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.lightBlue),
                              ),
                            ],
                          ),
                        )),
                  ),
                  // ElevatedButton(
                  //     style: ButtonStyle(
                  //       backgroundColor:
                  //           MaterialStateProperty.all<Color>(Colors.white),
                  //       padding: MaterialStateProperty.all<EdgeInsets>(
                  //           EdgeInsets.all(15)),
                  //       shape:
                  //           MaterialStateProperty.all<RoundedRectangleBorder>(
                  //               RoundedRectangleBorder(
                  //                   borderRadius: BorderRadius.circular(18.0),
                  //                   side:
                  //                       BorderSide(color: Colors.blueAccent))),
                  //     ),
                  //     onPressed: _readDir,
                  //     child: Row(
                  //       children: [
                  //         const Icon(Icons.folder,color: Colors.lightBlue,),
                  //         const Text(
                  //           'Choose a directory',
                  //           style: TextStyle(fontSize: 20, color: Colors.lightBlue),
                  //         ),
                  //       ],
                  //     )),
                ],
              ),
      ),
    );
  }
}
