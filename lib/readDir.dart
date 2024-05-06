import 'package:flutter/material.dart';
import 'readFileResult.dart';

class AppListWidget extends StatelessWidget {
  final List<AppInfo> appInfos;

  AppListWidget({required this.appInfos});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: appInfos.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('appInfos[index]'),
          subtitle: Text('appInfos[index].packageName'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MetadataScreen(data: appInfos[index]),
              ),
            );
          },
        );
      },
    );
  }
}
