
/*
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_file/open_file.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:developer' as developer;
import '../Authentication/signin_screen.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class DocumentListScreen extends StatelessWidget {
  const DocumentListScreen({super.key});

  Future<void> _openDocument(String filePath, String fileName) async {
    try {
      if (kIsWeb) {
        html.window.open(filePath, '_blank');
      } else {
        final http.Response response = await http.get(Uri.parse(filePath));

        if (response.statusCode == 200) {
          final Directory tempDir = await getTemporaryDirectory();
          final String localPath = path.join(tempDir.path, fileName);
          final File localFile = File(localPath);
          await localFile.writeAsBytes(response.bodyBytes);

          final result = await OpenFilex.open(localPath);
          print(result.type);
          print(result.message);

          if (result.type != ResultType.done) {
            print("Couldn't open the file: ${result.message}");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to open file. Please try again.')),
            );
          }
        } else {
          print("Failed to download file: ${response.statusCode}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to download file. Please try again.')),
          );
        }
      }
    } catch (e) {
      print("Error opening file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while opening the file.')),
      );
    }
  }


  Future<void> _openPDF(BuildContext context, String filePath) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('PDF Viewer')),
          body: PDFView(
            filePath: filePath,
            defaultPage: 1,
            onRender: (pages) {
              // Optional: Perform any additional actions after the PDF has rendered
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openImage(BuildContext context, String url) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Image Viewer')),
          body: PhotoView(
            imageProvider: NetworkImage(url),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        ),
      ),
    );
  }


  Future<File?> _downloadFile(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.tmp');
      await tempFile.writeAsBytes(bytes);
      return tempFile;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building DocumentListScreen', name: 'DocumentListScreen');
    return Scaffold(
      appBar: AppBar(title: const Text('Document List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('documents').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          developer.log('StreamBuilder state: ${snapshot.connectionState}', name: 'DocumentListScreen');

          if (snapshot.hasError) {
            developer.log('StreamBuilder error: ${snapshot.error}', name: 'DocumentListScreen', error: snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            developer.log('Waiting for data', name: 'DocumentListScreen');
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            developer.log('No documents found', name: 'DocumentListScreen');
            return const Center(child: Text('No documents found'));
          }

          developer.log('Number of documents: ${snapshot.data!.docs.length}', name: 'DocumentListScreen');

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              final url = data['url'] ?? '';
              final thumbnailUrl = data['thumbnailUrl'] ?? '';
              final fileType = data['fileType'] ?? '';

              return ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: thumbnailUrl.isNotEmpty
                        ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        developer.log('Error loading thumbnail: $error', name: 'DocumentListScreen', error: error);
                        return const Icon(Icons.error);
                      },
                    )
                        : const Icon(Icons.insert_drive_file),
                  ),
                ),
                title: Text(data['title'] ?? 'No title'),
                subtitle: Text(data['description'] ?? 'No description'),
                onTap: () => _openDocument(context, url, fileType),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
*/



// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:open_file/open_file.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path/path.dart' as path; // Import for path operations
// import 'package:path_provider/path_provider.dart';
// import 'package:photo_view/photo_view.dart';
// import 'dart:developer' as developer;
// import 'package:http/http.dart' as http;
//
// class DocumentListScreen extends StatelessWidget {
//   const DocumentListScreen({super.key});
//
//   Future<void> _openDocument(BuildContext context, String url, String fileType) async {
//     developer.log('Attempting to open file: $url', name: 'DocumentListScreen');
//     try {
//       final file = await _downloadFile(url);
//       if (file != null) {
//         if (fileType.toLowerCase().contains('pdf')) {
//           await _openPDF(context, url);
//         } else if (fileType.toLowerCase().contains('image')) {
//           await _openImage(context, url);
//         } else {
//           await OpenFile.open(file.path);
//         }
//       }
//     } catch (e) {
//       developer.log('Error opening file: $e', name: 'DocumentListScreen', error: e);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error opening file: ${e.toString()}')),
//       );
//     }
//   }
//
//
//   Future<void> _openPDF(BuildContext context, String filePath) async {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => Scaffold(
//           appBar: AppBar(title: const Text('PDF Viewer')),
//           body: PDFView(
//             filePath: filePath,
//             defaultPage: 1,
//             onRender: (pages) {
//               // Optional: Perform any additional actions after the PDF has rendered
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _openImage(BuildContext context, String url) async {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => Scaffold(
//           appBar: AppBar(title: const Text('Image Viewer')),
//           body: PhotoView(
//             imageProvider: NetworkImage(url),
//             minScale: PhotoViewComputedScale.contained,
//             maxScale: PhotoViewComputedScale.covered * 2,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<File?> _downloadFile(String url) async {
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final bytes = response.bodyBytes;
//       final tempDir = await getTemporaryDirectory();
//       final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.tmp');
//       await tempFile.writeAsBytes(bytes);
//       return tempFile;
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     developer.log('Building DocumentListScreen', name: 'DocumentListScreen');
//     return Scaffold(
//       appBar: AppBar(title: const Text('Document List')),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('documents').orderBy('timestamp', descending: true).snapshots(),
//         builder: (context, snapshot) {
//           developer.log('StreamBuilder state: ${snapshot.connectionState}', name: 'DocumentListScreen');
//
//           if (snapshot.hasError) {
//             developer.log('StreamBuilder error: ${snapshot.error}', name: 'DocumentListScreen', error: snapshot.error);
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             developer.log('Waiting for data', name: 'DocumentListScreen');
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             developer.log('No documents found', name: 'DocumentListScreen');
//             return const Center(child: Text('No documents found'));
//           }
//
//           developer.log('Number of documents: ${snapshot.data!.docs.length}', name: 'DocumentListScreen');
//
//           return ListView(
//             children: snapshot.data!.docs.map((DocumentSnapshot document) {
//               Map<String, dynamic> data = document.data() as Map<String, dynamic>;
//               final url = data['url'] ?? '';
//               final thumbnailUrl = data['thumbnailUrl'] ?? '';
//               final fileType = data['fileType'] ?? '';
//
//               return ListTile(
//                 leading: Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: thumbnailUrl.isNotEmpty
//                         ? Image.network(
//                       url,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         developer.log('Error loading thumbnail: $error', name: 'DocumentListScreen', error: error);
//                         return const Icon(Icons.error);
//                       },
//                     )
//                         : const Icon(Icons.insert_drive_file),
//                   ),
//                 ),
//                 title: Text(data['title'] ?? 'No title'),
//                 subtitle: Text(data['description'] ?? 'No description'),
//                 onTap: () => _openDocument(context, url, fileType), // Pass context here
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }
//







import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:mime/mime.dart';  // Import mime package

class DocumentListScreen extends StatelessWidget {
  const DocumentListScreen({super.key});

  Future<void> _openDocument(BuildContext context, String url) async {
    developer.log('Attempting to open file: $url', name: 'DocumentListScreen');
    try {
      final file = await _downloadFile(url);
      if (file != null) {
        final fileType = _getFileType(file.path);
        switch (fileType) {
          case 'pdf':
            await _openPDF(context, file.path);
            break;
          case 'image':
            await _openImage(context, file.path);
            break;
          default:
            await _openWithSystemApp(context, file.path);
        }
      }
    } catch (e) {
      developer.log('Error opening file: $e', name: 'DocumentListScreen', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: ${e.toString()}')),
      );
    }
  }

  // Custom function to determine the file type
  String _getFileType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    if (extension == '.pdf') {
      return 'pdf';
    } else if (['.jpg', '.jpeg', '.png', '.gif'].contains(extension)) {
      return 'image';
    }
    return 'unknown';
  }

  Future<void> _openPDF(BuildContext context, String filePath) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('PDF Viewer')),
          body: PDFView(
            filePath: filePath,
            defaultPage: 1,
            onRender: (pages) {
              // Optional: Perform any additional actions after the PDF has rendered
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openImage(BuildContext context, String filePath) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Image Viewer')),
          body: PhotoView(
            imageProvider: FileImage(File(filePath)),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
        ),
      ),
    );
  }

  Future<void> _openWithSystemApp(BuildContext context, String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      developer.log('Error opening file with system app: $e', name: 'DocumentListScreen', error: e);
      // Consider using url_launcher to try opening the file in a web browser or other external app
      final url = 'file://$filePath';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: ${e.toString()}')),
        );
      }
    }
  }

  Future<File?> _downloadFile(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.tmp');
      await tempFile.writeAsBytes(bytes);
      return tempFile;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building DocumentListScreen', name: 'DocumentListScreen');
    return Scaffold(
      appBar: AppBar(title: const Text('Document List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('documents').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          developer.log('StreamBuilder state: ${snapshot.connectionState}', name: 'DocumentListScreen');

          if (snapshot.hasError) {
            developer.log('StreamBuilder error: ${snapshot.error}', name: 'DocumentListScreen', error: snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            developer.log('Waiting for data', name: 'DocumentListScreen');
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            developer.log('No documents found', name: 'DocumentListScreen');
            return const Center(child: Text('No documents found'));
          }

          developer.log('Number of documents: ${snapshot.data!.docs.length}', name: 'DocumentListScreen');

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              final url = data['url'] ?? '';
              final thumbnailUrl = data['thumbnailUrl'] ?? '';
              final fileType = data['fileType'] ?? '';

              return ListTile(
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: thumbnailUrl.isNotEmpty
                        ? Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        developer.log('Error loading thumbnail: $error', name: 'DocumentListScreen', error: error);
                        return const Icon(Icons.error);
                      },
                    )
                        : const Icon(Icons.insert_drive_file),
                  ),
                ),
                title: Text(data['title'] ?? 'No title'),
                subtitle: Text(data['description'] ?? 'No description'),
                onTap: () => _openDocument(context, url), // Pass context here
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
