import 'package:euro_docs/home/show_files.dart';
import 'package:euro_docs/home/upload_files.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
          backgroundColor: Colors.white,
          title: const Text('File Upload App', style: TextStyle(color: Colors.black),),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Upload File'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadScreen()));
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('View Files'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewFilesScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}





