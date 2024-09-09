import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:euro_docs/home/upload_files.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class ViewFilesScreen extends StatelessWidget {
  const ViewFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UploadScreen())),
        child: const Icon(Icons.add, color: Colors.black,),
      ),
      appBar: AppBar(
        elevation: 0,
          backgroundColor: Colors.white,
          title: const Text('Files', style: TextStyle(color: Colors.black),),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('files').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.75,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              return Card(
                child: InkWell(
                  onTap: () => _openFile(doc['url'], doc['fileName']),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Center(
                            child: _getFileTypeImage(doc['fileName'], doc['url']),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          doc['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doc['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getFileTypeImage(String fileName, String url) {
    final extension = fileName.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return SvgPicture.asset(
              'assets/icons/image_icon.png',
              // width: 64,
              // height: 64,
            );
          },
        ),
      );
    }

    String imagePath;
    switch (extension) {
      case 'pdf':
        imagePath = 'assets/icons/pdf.svg';
        break;
      case 'doc':
      case 'docx':
        imagePath = 'assets/icons/google-docs.svg';
        break;
      case 'xls':
      case 'xlsx':
        imagePath = 'assets/icons/excel1.svg';
        break;
      case 'word':
        imagePath = 'assets/icons/word.svg';
        break;
      case 'ppt':
      case 'pptx':
        imagePath = 'assets/icons/powerpoint.svg';
      default:
        imagePath = 'assets/icons/image.svg';
    }

    return SvgPicture.asset(
      imagePath,
    );
  }


  void _openFile(String url, String fileName) async {
    try {
      // Download file to a temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);

      if (!await file.exists()) {
        await file.create(recursive: true);
        await FirebaseStorage.instance.refFromURL(url).writeToFile(file);
      }

      // Open the file
      await OpenFilex.open(filePath);
    } catch (e) {
      log('Error opening file: $e');
    }
  }
}
















