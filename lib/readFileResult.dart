import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

class AppInfo {
  final bool sha256Hash;
  final bool sha1Hash;
  final bool md5Hash;
  final Map<String, dynamic> appMetadata;
  final List<dynamic> permission;
  final List<dynamic> actions;
  final Map<String, dynamic> dynamic_data;
  final int size;
  final String result;
  final int MaliciousScore;
  final int SuspicousScore;

  AppInfo({
    required this.sha256Hash,
    required this.sha1Hash,
    required this.md5Hash,
    required this.appMetadata,
    required this.permission,
    required this.actions,
    required this.dynamic_data,
    required this.size,
    required this.result,
    required this.MaliciousScore,
    required this.SuspicousScore,
  });

  factory AppInfo.fromJson(Map<String, dynamic> json) {
    return AppInfo(
      sha256Hash: json['sha256'],
      sha1Hash: json['sha1'],
      md5Hash: json['md5'],
      appMetadata: json['App_metadata'],
      permission: json['Permission'],
      actions: json['Actions'],
      dynamic_data: json['Dynamic_data'],
      MaliciousScore: json['malScore'],
      SuspicousScore: json['susScore'],
      size: json['size'],
      result: json['Result'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sha256Hash': sha256Hash,
      'sha1Hash': sha1Hash,
      'md5Hash': md5Hash,
      'App metadata': appMetadata,
      'Permission': permission,
      'Actions': actions,
      'size': size,
      'Dynamic data': dynamic_data,
      'Malicious Score': MaliciousScore,
      'Suspicous Score': SuspicousScore,
      'Result': result,
    };
  }
}

class MetadataScreen extends StatelessWidget {
  const MetadataScreen({super.key, required this.data});
  final data;

// {App metadata:
  @override
  Widget build(BuildContext context) {
    print(data.runtimeType);

    final mp = AppInfo.fromJson(data);
//  print(appInfo.appMetadata);
//           print(appInfo.permission);
//           print(appInfo.actions);
//           print(appInfo.result);
    bool sha256Hash = mp.sha256Hash;
    bool sha1Hash = mp.sha1Hash;
    bool md5Hash = mp.md5Hash;
    var appMetadata = mp.appMetadata;
    var permissions = mp.permission;
    var dynaData = mp.dynamic_data;
    var size = mp.size;
    var actions = mp.actions;
    var result = mp.result;
    int mlscore = mp.MaliciousScore;
    int susscore = mp.SuspicousScore;

    return Scaffold(
      appBar: AppBar(
        title: Text('${appMetadata['Package Name:']} Metadata'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            //sha256Matching
            _getHashMatchContainer('SHA256', sha256Hash),
            //sha1Matching
            _getHashMatchContainer('SHA1', sha1Hash),
            // md5matching
            _getHashMatchContainer('MD5', md5Hash),
            _getMetaData('MetaData', appMetadata),

            _getListData('Permissions', permissions),

            _getListData('Actions', actions),

            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              padding: const EdgeInsets.symmetric(vertical: 8),
              // alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                color: Colors.white, // Change this to your desired color
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              width: double.infinity,
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Size',style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
                    ),
                    Text('$size Bytes',style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300))
                  ],
                ),
              ),
            ),
            _getScore(mlscore, susscore),
            // result for file
            if (mp.result.endsWith('benign'))
              _getResultSafe()
            else
              _getResultMal()
          ],
        )),
      )),
    );
  }
}
Widget _getScore(mlscore,susscore){
  return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      padding: const EdgeInsets.symmetric(vertical: 8),
      // alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        color: Colors.white, // Change this to your desired color
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
    child: Column(
      children: [
        Text('Scores',style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white, // Change this to your desired color
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text('Malicous',style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                  Container(
                    padding: const EdgeInsets.all( 20),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(

                        color: Colors.redAccent, // Change this to your desired color

                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text('$mlscore', style: TextStyle(fontSize: 20,color: Colors.white, fontWeight: FontWeight.w500))),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white, // Change this to your desired color
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text('Malicous',style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                  Container(
                      padding: const EdgeInsets.all( 20),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(

                        color: Colors.amber, // Change this to your desired color

                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text('$susscore', style: TextStyle(fontSize: 20,color: Colors.white, fontWeight: FontWeight.w500))),
                ],
              ),
            ),

          ],
        ),
      ],
    )
  );
}

Widget _getHashMatchContainer(hash, isMatched) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    alignment: Alignment.topLeft,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: Colors.black,
        width: 0,
      ),
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        if (isMatched)
          BoxShadow(
            color: Colors.red.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 0), // changes position of shadow
          )
        else
          BoxShadow(
            color: Colors.green.withOpacity(0.8),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 0), // changes position of shadow
          ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text('$hash Hash Matching',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
          ),
          if (isMatched) _getHashMatch() else _getHashNotMatch()
        ],
      ),
    ),
  );
}

Widget _buildList(List<dynamic> items) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((item) => Text(item,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500, height: 1.5)))
            .toList()),
  );
}

Widget _buildMetadata(Map<String, dynamic> data) {
  return SingleChildScrollView(
    child: Column(
      children: [
        SizedBox(height: 14.0),
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries
                .map((entry) => Text("${entry.key}: ${entry.value}",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.5)))
                .toList()),
        SizedBox(height: 14.0)
      ],
    ),
  );
}

Widget _getListData(String title, List<dynamic> items) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 15),
    padding: const EdgeInsets.symmetric(vertical: 8),
    // alignment: Alignment.topLeft,
    decoration: BoxDecoration(
      color: Colors.white, // Change this to your desired color
      border: Border.all(
        color: Colors.grey,
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    width: double.infinity,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(title,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
          ),
          _buildList(items),
        ],
      ),
    ),
  );
}

Widget _getMetaData(String title, Map<String, dynamic> data) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 15),
    padding: const EdgeInsets.symmetric(vertical: 8),
    // alignment: Alignment.topLeft,
    decoration: BoxDecoration(
      color: Colors.white, // Change this to your desired color
      border: Border.all(
        color: Colors.grey,
        width: 1.0,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    width: double.infinity,
    child: Column(
      children: [
        Text(title,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
        _buildMetadata(data),
      ],
    ),
  );
}

Widget _getHashNotMatch() {
  return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.white),
        color: Colors.green,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Icon(Icons.security),
          ),
          const Text(
            'No History of Malware!!',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ));
}

Widget _getHashMatch() {
  return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.white),
        color: Colors.red,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: const Icon(Icons.warning_rounded)),
          const Text(
            'Malcicous File detected',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ));
}

Widget _getResultMal() {
  return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.white),
        color: Colors.red,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: const Icon(Icons.android)),
          const Text('This Application is Malicous',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1)),
        ],
      ));
}

Widget _getResultSafe() {
  return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.white),
        color: Colors.green,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Icon(Icons.security),
          ),
          const Text('This Application is Benign',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1))
        ],
      ));
}
