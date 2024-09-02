import 'dart:io';
import 'dart:typed_data';
import 'package:euro_docs/home/show_documents.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:developer' as developer;
import '../Authentication/signin_screen.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Manager'),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SignInScreen()));
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const UploadScreen())),
              child: const Text('Upload Document'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DocumentListScreen())),
              child: const Text('View Documents'),
            ),
          ],
        ),
      ),
    );
  }
}

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedFile;


  Future<String?> generateThumbnail(File file) async {
    try {
      final Uint8List bytes = await file.readAsBytes();
      final img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        return null;
      }

      final img.Image thumbnail = img.copyResize(image, width: 200, height: 200);

      final tempDir = await getTemporaryDirectory();
      final thumbnailFile = File('${tempDir.path}/thumbnail.jpg');
      await thumbnailFile.writeAsBytes(img.encodeJpg(thumbnail));

      return thumbnailFile.path;
    } catch (e) {
      developer.log('Error generating thumbnail: $e', name: 'UploadScreen', error: e);
      return null;
    }
  }

  Future<void> _pickFile() async {
    developer.log('Initiating file pick', name: 'UploadScreen');
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
      developer.log('File selected: ${_selectedFile!.path}', name: 'UploadScreen');
    } else {
      developer.log('No file selected', name: 'UploadScreen');
    }
  }

  Future<void> _uploadDocument() async {
    developer.log('Starting document upload process', name: 'UploadScreen');

    // Step 1: Validate form and check file
    developer.log('Step 1: Validating form and checking file', name: 'UploadScreen');
    if (_formKey.currentState!.validate() && _selectedFile != null) {
      try {
        // Step 2: Prepare file for upload
        developer.log('Step 2: Preparing file for upload', name: 'UploadScreen');
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        developer.log('Generated file name: $fileName', name: 'UploadScreen');

        // Step 3: Create Firebase Storage reference
        developer.log('Step 3: Creating Firebase Storage reference', name: 'UploadScreen');
        Reference ref = FirebaseStorage.instance.ref().child('documents/$fileName');
        developer.log('Storage reference created: ${ref.fullPath}', name: 'UploadScreen');

        // Step 4: Upload file to Firebase Storage
        developer.log('Step 4: Uploading file to Firebase Storage', name: 'UploadScreen');
        TaskSnapshot uploadTask = await ref.putFile(_selectedFile!);
        developer.log('Upload task completed. Bytes transferred: ${uploadTask.bytesTransferred}', name: 'UploadScreen');

        // Step 5: Get download URL
        developer.log('Step 5: Getting download URL', name: 'UploadScreen');
        String downloadURL = await ref.getDownloadURL();
        developer.log('Download URL obtained: $downloadURL', name: 'UploadScreen');

        // Step 6: Prepare document data for Firestore
        developer.log('Step 6: Preparing document data for Firestore', name: 'UploadScreen');
        String? thumbnailUrl;
        if (_selectedFile != null) {
          thumbnailUrl = await generateThumbnail(_selectedFile!);
        }

        Map<String, dynamic> documentData = {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'url': downloadURL,
          'thumbnailUrl': thumbnailUrl,
          'timestamp': FieldValue.serverTimestamp(),
        };


        developer.log('Document data prepared: $documentData', name: 'UploadScreen');

        // Step 7: Store document info in Firestore
        developer.log('Step 7: Storing document info in Firestore', name: 'UploadScreen');
        DocumentReference docRef = await FirebaseFirestore.instance.collection('documents').add(documentData);
        developer.log('Document stored in Firestore. Document ID: ${docRef.id}', name: 'UploadScreen');

        // Step 8: Upload process completed successfully
        developer.log('Step 8: Upload process completed successfully', name: 'UploadScreen');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully')),
        );

        // Step 9: Reset form and state
        developer.log('Step 9: Resetting form and state', name: 'UploadScreen');
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedFile = null;
        });
        developer.log('Form and state reset completed', name: 'UploadScreen');

      } catch (e) {
        developer.log('Error uploading document: $e', name: 'UploadScreen', error: e);
        if (e is FirebaseException) {
          developer.log('Firebase Exception Code: ${e.code}', name: 'UploadScreen');
          developer.log('Firebase Exception Message: ${e.message}', name: 'UploadScreen');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading document: ${e.toString()}')),
        );
      }
    } else {
      developer.log('Form validation failed or no file selected', name: 'UploadScreen');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a file')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Document')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Document Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Document Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Select Document'),
              ),
              if (_selectedFile != null)
                Text('Selected file: ${_selectedFile!.path}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _uploadDocument,
                child: const Text('Upload Document'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





