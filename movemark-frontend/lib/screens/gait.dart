import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:collection/collection.dart';

class GaitRecognition extends StatefulWidget {
  @override
  _GaitRecognitionState createState() => _GaitRecognitionState();
}

class _GaitRecognitionState extends State<GaitRecognition> {
  bool _isLoading = false;
  Map<String, dynamic>? _similarityResults;
  String? _errorMessage;
  String? _successMessage;
  PlatformFile? _selectedFile;
  Map<String, dynamic>? _topMatch;
  bool _isRegistration = false;
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
          _errorMessage = null;
          _successMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error selecting file: Please try again';
        _successMessage = null;
        print('File selection error: $e');
      });
    }
  }

  Future<void> _startRecognition() async {
    if (_selectedFile == null) {
      setState(() {
        _errorMessage = 'Please select a video file';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final uri = Uri.parse(
          "https://3c0c-115-246-244-174.ngrok-free.app/api/gait/recognize");

      var request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        if (_selectedFile!.bytes == null) {
          throw Exception('No file data available');
        }
        request.files.add(
          http.MultipartFile.fromBytes(
            'video',
            _selectedFile!.bytes!,
            filename: _selectedFile!.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'video',
            _selectedFile!.path!,
            filename: _selectedFile!.name,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final results = jsonResponse['data']['similarity_results']
              as Map<String, dynamic>;

          var highestSimilarity = 0.0;
          Map<String, dynamic>? topMatch;
          String? topKey;

          results.forEach((key, value) {
            if (value['similarity'] > highestSimilarity) {
              highestSimilarity = value['similarity'];
              topMatch = value;
              topKey = key;
            }
          });

          setState(() {
            _similarityResults = results;
            _topMatch = topMatch;
          });
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error processing request: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerGait() async {
    if (_selectedFile == null) {
      setState(() {
        _errorMessage = 'Please select a video file';
        _successMessage = null;
      });
      return;
    }

    if (_nameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a name';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final uri = Uri.parse(
          'https://3c0c-115-246-244-174.ngrok-free.app/register?name=${_nameController.text}');

      var request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        if (_selectedFile!.bytes == null) {
          throw Exception('No file data available');
        }
        request.files.add(
          http.MultipartFile.fromBytes(
            'video',
            _selectedFile!.bytes!,
            filename: _selectedFile!.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'video',
            _selectedFile!.path!,
            filename: _selectedFile!.name,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          setState(() {
            _successMessage = 'Gait pattern registered successfully';
            _errorMessage = null;
            _selectedFile = null;
            _nameController.clear();
          });
        } else {
          throw Exception(jsonResponse['message'] ?? 'Registration failed');
        }
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error during registration: ${e.toString()}';
        _successMessage = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFF2A2A3A),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isRegistration ? Icons.app_registration : Icons.search,
                        color: Colors.blue.shade400,
                      ),
                      SizedBox(width: 12),
                      Text(
                        _isRegistration ? 'Registration' : 'Recognition',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _isRegistration = !_isRegistration;
                        _errorMessage = null;
                        _successMessage = null;
                        _selectedFile = null;
                        _similarityResults = null;
                        _topMatch = null;
                        _nameController.clear();
                      });
                    },
                    icon: Icon(
                      _isRegistration ? Icons.search : Icons.app_registration,
                      color: Colors.blue.shade400,
                    ),
                    label: Text(
                      _isRegistration
                          ? 'Switch to Recognition'
                          : 'Switch to Registration',
                      style: TextStyle(
                        color: Colors.blue.shade400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_isRegistration)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: TextField(
                    controller: _nameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Enter Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade400),
                      ),
                      filled: true,
                      fillColor: Colors.black12,
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFile != null
                          ? Icons.check_circle
                          : Icons.videocam,
                      size: 48,
                      color:
                          _selectedFile != null ? Colors.green : Colors.white38,
                    ),
                    SizedBox(height: 12),
                    Text(
                      _selectedFile != null
                          ? 'Selected: ${_selectedFile!.name}'
                          : _isRegistration
                              ? 'Upload a video to register new gait pattern'
                              : 'Upload a video to compare with registered patterns',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _uploadFile,
                icon: Icon(Icons.upload_file),
                label: Text('Upload File'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : (_isRegistration ? _registerGait : _startRecognition),
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(_isRegistration ? Icons.save : Icons.play_arrow),
                label: Text(_isLoading
                    ? 'Processing...'
                    : _isRegistration
                        ? 'Save'
                        : 'Start Recognition'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _isRegistration
                      ? Colors.orange.shade600
                      : Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade300,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _successMessage!,
                    style: TextStyle(
                      color: Colors.green.shade300,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (!_isRegistration &&
                  _similarityResults != null &&
                  _topMatch != null)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Best Match',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade400,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _topMatch!['name'],
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_topMatch!['similarity'].toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'All Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(
                              Colors.white.withOpacity(0.05),
                            ),
                            columns: [
                              DataColumn(
                                label: Text(
                                  'Name',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Distance',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Similarity',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                            rows: _similarityResults!.entries
                                .map((entry) {
                                  final data =
                                      entry.value as Map<String, dynamic>;
                                  return MapEntry(
                                    entry.key,
                                    data,
                                  );
                                })
                                .toList()
                                .sorted((a, b) => (b.value['similarity'] as num)
                                    .compareTo(a.value['similarity'] as num))
                                .map((entry) {
                                  final data =
                                      entry.value as Map<String, dynamic>;
                                  final isTopMatch = data['similarity'] ==
                                      _topMatch!['similarity'];

                                  return DataRow(
                                    color: isTopMatch
                                        ? MaterialStateProperty.all(
                                            Colors.green.withOpacity(0.1),
                                          )
                                        : null,
                                    cells: [
                                      DataCell(Text(
                                        data['name'],
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontWeight: isTopMatch
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      )),
                                      DataCell(Text(
                                        data['distance'].toStringAsFixed(2),
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontWeight: isTopMatch
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      )),
                                      DataCell(Text(
                                        '${data['similarity'].toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: isTopMatch
                                              ? Colors.green.shade400
                                              : Colors.white70,
                                          fontWeight: isTopMatch
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      )),
                                    ],
                                  );
                                })
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
