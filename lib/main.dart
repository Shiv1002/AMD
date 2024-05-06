import 'dart:io';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:amd/readFileResult.dart';
import 'package:amd/readDir.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:localstorage/localstorage.dart';

final LocalStorage store =  LocalStorage('AMD');
String? data = store.getItem('cachedApps');

void main() {
  debugPrint(store.getItem('cachedApps'));
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android Malware Detection',
      debugShowCheckedModeBanner: false,
      home: FlutterSplashScreen.gif(
        gifPath: 'assets/example.gif',
        gifWidth: 269,
        gifHeight: 474,
        nextScreen: MyHomePage(title: 'Android Malware Detection'),
        duration: const Duration(milliseconds: 3000),
        onInit: () async {
          debugPrint("onInit");
        },
        onEnd: () async {
          debugPrint("onEnd 1");
        },
      ),
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          displayLarge: TextStyle(color: Colors.black), // Customize text colors
          displayMedium: TextStyle(color: Colors.black),
        ),
        appBarTheme: const AppBarTheme(
            color: Colors.black, // Customize app bar color
            iconTheme: IconThemeData(
                color: Colors.white), // Customize app bar icon colors
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20)),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.black, // Customize button color
          textTheme: ButtonTextTheme.primary,
        ),
      ),
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

const String server =  "https://mds-hr2e.onrender.com";

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
void _getHashDetail(String hash256, context) async{

  final hashUrl =  '$server/hash/$hash256';
  try{
    debugPrint('Fetching data from server');
    final res = await http.get(Uri.parse(hashUrl));
    if(res.statusCode == 200){
      final rs = jsonDecode(res.body);
      debugPrint('Fetch successfull!');
      _dataSaveInLocalStorage(rs,context);


    }else{
      throw Exception(res.statusCode);
    }

  }catch(e){
    debugPrint(e.toString());
  }

}
void _getVTAnalysis(String filename, context) async {
  const url = "https://www.virustotal.com/api/v3/files";
  Map<String, String> _heads = {
    "x-apikey":
        "791704300a91001bb0b3d8f806079067088a38bf04fcc3305f51f5462c3ea080",
    "accept": "application/json",
    "content-type": "multipart/form-data"
  };

  try {
    var req = await http.MultipartRequest('POST', Uri.parse(url));
    req.files.add(http.MultipartFile('file',
        File(filename).readAsBytes().asStream(), File(filename).lengthSync(),
        filename: filename.split("/").last));

    _heads.forEach((key, value) {
      req.headers[key] = value;
    });

    final res = await req.send();

    if (res.statusCode == 200) {
      _tshow('request successful', context);
      Future<String> data = res.stream.bytesToString();
      data
          .then((val) => print(data))
          .catchError((err) => {throw Exception(err)});
    } else {
      throw Exception('Request failed!');
    }
  } catch (e) {
    print('Error ${e.toString()}');
  } finally {}
}

void _readDir(context) async {
  try {
    String? dir = await FilePicker.platform.getDirectoryPath();
    if (dir != null) {
      final directory = Directory(dir);
      if (await directory.exists()) {
        _tshow('uploading ${directory.path}',context);

        // String url = "https://mds-hr2e.onrender.com/dir/testAPK";
        // final res = await http.get(Uri.parse(url));
        // if(res.statusCode == 200){
        //   final list = jsonDecode(res.body);
        //
        //   List<AppInfo> parseAppInfo(String jsonString) {
        //     final Map<String, dynamic> jsonData = jsonDecode(jsonString);
        //     return jsonData.entries.map((entry) {
        //       return AppInfo.fromJson(entry.value);
        //     }).toList();
        //   }

        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => AppListWidget(appInfos:parseAppInfo(res.body)),
        //   ),
        // );
        // }
        // else{
        //   showToast('${res.statusCode}', context: context);
        // }
      }
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}

void _readFile(context) async {
  try {
    _tshow('Reading file..', context);
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null) {
      PlatformFile filemeta = result.files.first;
      // _fetchData(filemeta.name);
      File file = File(filemeta.path!);
      if (await file.exists()) {
        if (!file.path.endsWith(".apk")) {
          _tshow('Choose APK file', context);
          return;
        }
        //get hashes of file
        _getAllHashes(file.path)
            .then((hashes) =>
                {
                  print('hashes: $hashes'),
                  _getHashDetail(hashes['sha256Hash']!,context)
                })
            .catchError((e) => print('error $e'));

        // try to retrieve cached information of file from server
        //ping to MDS/hash/{hash}
        // _fetchHashDetail()

        // otherwise retrive new information from server

        // _getVTAnalysis(file.path, context);



      } else {
        _tshow('File does not exist', context);
      }
    } else {
      _tshow('Cancel', context);
    }
  } catch (e) {
    debugPrint('err');
    debugPrint(e.toString());
  }
}

void _tshow(msg, context) {
  showToast(msg,
      textStyle: TextStyle(fontSize: 15, color: Colors.white),
      textPadding: EdgeInsets.all(20),
      backgroundColor: Colors.black,
      borderRadius: BorderRadius.circular(50),
      context: context,
      animation: StyledToastAnimation.slideFromBottom,
      reverseAnimation: StyledToastAnimation.slideToBottom,
      startOffset: Offset(0.0, 3.0),
      reverseEndOffset: Offset(0.0, 3.0),
      position: StyledToastPosition.bottom,
      duration: Duration(seconds: 4),
//Animation duration   animDuration * 2 <= duration
      animDuration: Duration(seconds: 1),
      curve: Curves.elasticOut,
      reverseCurve: Curves.fastOutSlowIn);
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = false;
  int _currentIndex = 0;

  final List<Widget> _navpage = [SingleChildScrollView(child:HomeScreen()), History(), Profile()];
  void _onNavigationTap(index) {
    setState(() {
      _currentIndex = index;
    });
  }


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
              builder: (context) => MetadataScreen(data: appInfo),
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
        debugPrint(
            '${res.statusCode}-${getmd5Match.statusCode}-${getsha256Match.statusCode}-${getsha1Match.statusCode}');
        _tshow(
            'Request failed with status: ${res.statusCode}-${getmd5Match.statusCode}-${getsha256Match.statusCode}-${getsha1Match.statusCode}',
            context);
      }
    } catch (e) {
      _tshow('error $e', context);
    } finally {
      setState(() {
        _isLoading = false;
      });
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
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Loading data from server!!'),
                    CircularProgressIndicator(),
                  ],
                )
              : Column(
                  children: [_navpage[_currentIndex]],
                )),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: QuickActions(),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ScannedFile(),
          )
        ],
      ),
    );
  }
}

class ScannedFile extends StatelessWidget{
  @override
Widget build(BuildContext context){
    if(data == null ){
      return Text('Null');
    }

    return Column(
      children: [
    Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            shape: BoxShape.rectangle,
            color: const Color.fromARGB(10, 23, 10, 10)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text('${jsonDecode(data!).length} file scanned')),
        )),
        _buildFiledata(jsonDecode(data!), context),
      ],
    );


  }
}

Widget _buildFiledata(Map<String, dynamic> data, context) {
  return Column(
    children: [

      Center(
        child: SingleChildScrollView(
          child: Column(
              children: data.entries
                  .map((entry) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                    style: ButtonStyle(

                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      padding:  MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(10)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              side: BorderSide(color: Colors.black12))),
                    ),
                child : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        margin: const EdgeInsets.all(1),
                        // height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Text(entry.key,style: TextStyle(color: Colors.black),)),
                ),
                onPressed: ()=> navtofiledata(entry.value ,context)),
                  ))
                  .toList()),
        ),
      ),

    ],
  );
}
void navtofiledata(dta, context){
  Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MetadataScreen(data: dta),
        ),
      );
}

class QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Quick Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  padding:
                      MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(5)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.blueAccent))),
                ),
                onPressed: () => {
                  _readFile(context)

                },
                child: Container(
                  margin: const EdgeInsets.all(0),
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.file_open_sharp,
                        color: Colors.lightBlue,
                      ),
                      Text(
                        'Read file',
                        style: TextStyle(fontSize: 15, color: Colors.lightBlue),
                      ),
                    ],
                  ),
                )),
            ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  padding:
                      MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(5)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.blueAccent))),
                ),
                onPressed: () => _readDir(context),
                child: Container(
                  margin: const EdgeInsets.all(0),
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_copy,
                        color: Colors.lightBlue,
                      ),
                      Text(
                        'Choose a directory',
                        style: TextStyle(fontSize: 15, color: Colors.lightBlue),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ],
    );
  }
}
void _dataSaveInLocalStorage(dt,context){

  Map<String, dynamic> f = {
    "sha256":false,
    "md5":false,
    "sha1":false,
    "App_metadata":dt["App_metadata"],
    "Permission":dt['Permission'],
    "Actions":dt['Actions'],
    "Dynamic_data":dt['Dynamic_data'],
    "malScore":dt['Dynamic_data']['stats']['malicious'],
    "susScore":dt['Dynamic_data']['stats']['suspicious'],
    "size":dt['Dynamic_data']['size'],
    "Result":dt['Result']
  };

// AppInfo d = AppInfo.fromJson(f);
//  store:{   cachedApps:{   "appname":{...}  }    }
  Map<String, dynamic> applist;
  if(data == null){
     applist = {};
  }else{
    applist = json.decode(data!);
  }
  applist[f['App_metadata']['Package Name:']] = f;

  store.setItem('cachedApps', json.encode(applist));


  Navigator.of(context).push(
    MaterialPageRoute(

      builder: (context) => MetadataScreen(data: f),
    ),
  );


}


class History extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScannedFile(),
    );
  }
}

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/profile_image.jpg'),
          ),
          SizedBox(height: 16),
          Text(
            'SP',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'sp@example.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'About Me',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'I am a Flutter developer with a passion for building beautiful and intuitive mobile applications. In my free time, I enjoy hiking, playing the guitar, and reading about the latest technology trends.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'My Skills',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text('Flutter'),
                backgroundColor: Colors.blue[200],
              ),
              Chip(
                label: Text('Dart'),
                backgroundColor: Colors.green[200],
              ),
              Chip(
                label: Text('Firebase'),
                backgroundColor: Colors.red[200],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
