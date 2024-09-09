// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
//
// class UploadScreen extends StatefulWidget {
//   const UploadScreen({super.key});
//
//   @override
//   State<UploadScreen> createState() => _UploadScreenState();
// }
//
// class _UploadScreenState extends State<UploadScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   String? _filePath;
//
//   Future<void> _uploadFile() async {
//     if (_formKey.currentState!.validate() && _filePath != null) {
//       try {
//         // Upload file to Firebase Storage
//         final file = File(_filePath!);
//         final fileName = file.path.split('/').last;
//         final ref = FirebaseStorage.instance.ref().child('uploads/$fileName');
//         await ref.putFile(file);
//         final downloadUrl = await ref.getDownloadURL();
//
//         // Save metadata to Firestore
//         await FirebaseFirestore.instance.collection('files').add({
//           'title': _titleController.text,
//           'description': _descriptionController.text,
//           'url': downloadUrl,
//           'fileName': fileName,
//           'timestamp': FieldValue.serverTimestamp(),
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File uploaded successfully')));
//         Navigator.pop(context);
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading file: $e')));
//       }
//     }
//   }
//
//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       setState(() {
//         _filePath = result.files.single.path;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Upload File')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _titleController,
//                 decoration: InputDecoration(
//                     labelText: 'Title',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10)
//                     )
//                 ),
//                 validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
//               ),
//               const SizedBox(height: 8,),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: InputDecoration(
//                     labelText: 'Description',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10)
//                     )
//                 ),
//                 validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _pickFile,
//                 child: const Text('Pick File'),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _uploadFile,
//                 child: const Text('Upload'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

/*
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _filePath;

  Future<void> _uploadFile() async {
    if (_formKey.currentState!.validate() && _filePath != null) {
      try {
        // Upload file to Firebase Storage
        final file = File(_filePath!);
        final fileName = file.path.split('/').last;
        final ref = FirebaseStorage.instance.ref().child('uploads/$fileName');
        await ref.putFile(file);
        final downloadUrl = await ref.getDownloadURL();

        // Save metadata to Firestore
        await FirebaseFirestore.instance.collection('files').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'url': downloadUrl,
          'fileName': fileName,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: $e')),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload File')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Pick File'),
              ),
              const SizedBox(height: 10),
              _filePath != null
                  ? Text(
                'Selected file: ${_filePath!.split('/').last}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              )
                  : const Text(
                'No file selected',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadFile,
                child: const Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 */

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:euro_docs/home/show_files.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart'; // Add this package for mime type detection

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _filePath;

  Future<void> _uploadFile() async {
    if (_formKey.currentState!.validate() && _filePath != null) {
      try {
        // Upload file to Firebase Storage
        final file = File(_filePath!);
        final fileName = file.path.split('/').last;
        final ref = FirebaseStorage.instance.ref().child('uploads/$fileName');
        await ref.putFile(file);
        final downloadUrl = await ref.getDownloadURL();

        // Save metadata to Firestore
        await FirebaseFirestore.instance.collection('files').add({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'url': downloadUrl,
          'fileName': fileName,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully')),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewFilesScreen()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: $e')),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Upload File',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Pick File'),
              ),
              const SizedBox(height: 10),
              _filePath != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isImageFile(_filePath!)
                            ? Image.file(
                                File(_filePath!),
                                height: 150,
                                width: 150,
                                fit: BoxFit.cover,
                              )
                            : const Text('No image preview available'),
                        const SizedBox(height: 10),
                        Text(
                          'Selected file: ${_filePath!.split('/').last}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  : const Text(
                      'No file selected',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadFile,
                child: const Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isImageFile(String path) {
    final mimeType = lookupMimeType(path);
    return mimeType != null && mimeType.startsWith('image/');
  }
}
