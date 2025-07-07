import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CreateContentWidget extends StatefulWidget {
  final bool isReel;
  final Function()? onPostCreated;
  final VoidCallback? onAuthRequired;

  const CreateContentWidget({
    Key? key,
    this.isReel = false,
    this.onPostCreated,
    this.onAuthRequired,
  }) : super(key: key);

  @override
  _CreateContentWidgetState createState() => _CreateContentWidgetState();
}

class _CreateContentWidgetState extends State<CreateContentWidget> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _mediaFiles = [];
  bool _isPosting = false;
  late bool _isReelMode;
  String? _lastError;
  String? _lastResponse;

  @override
  void initState() {
    super.initState();
    _isReelMode = widget.isReel;
  }

  void _debugPrint(String message) {
    debugPrint('[DEBUG] ${DateTime.now()}: $message');
    if (mounted) {
      setState(() {
        _lastResponse = '${_lastResponse ?? ''}\n$message';
      });
    }
  }

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      _debugPrint('Retrieved auth token: ${token != null ? 'exists' : 'null'}');
      return token;
    } catch (e) {
      _debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  Future<bool> _checkAndRequestGalleryPermission() async {
    try {
      PermissionStatus status;
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          status = await Permission.photos.request();
          _debugPrint('Android 33+ photos permission: $status');
        } else {
          status = await Permission.storage.request();
          _debugPrint('Android storage permission: $status');
        }
      } else {
        status = await Permission.photos.request();
        _debugPrint('iOS photos permission: $status');
      }

      if (status.isGranted) return true;

      if (status.isDenied || status.isPermanentlyDenied) {
        _debugPrint('Showing permission rationale');
        final shouldOpenSettings = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Permission Required'),
                content: const Text(
                    'We need access to your gallery to select media. Please grant permission in settings.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Settings'),
                  ),
                ],
              ),
            ) ??
            false;

        if (shouldOpenSettings) {
          _debugPrint('Opening app settings');
          await openAppSettings();
        }
      }
      return false;
    } catch (e) {
      _debugPrint('Permission error: $e');
      return false;
    }
  }

  Future<void> _pickMedia() async {
    try {
      _debugPrint('Starting media picker');
      final hasPermission = await _checkAndRequestGalleryPermission();
      if (!hasPermission) {
        _debugPrint('Permission denied for media access');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gallery permission denied.')),
          );
        }
        return;
      }

      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Source'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('Camera'),
            ),
          ],
        ),
      );

      if (source == null) return;

      if (_isReelMode) {
        final pickedFile = await _picker.pickVideo(
          source: source,
          maxDuration: const Duration(seconds: 60),
        );

        if (pickedFile != null) {
          _debugPrint('Picked video file');
          setState(() {
            _mediaFiles = [File(pickedFile.path)];
          });
        }
      } else {
        final pickedFiles = await _picker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 80,
        );

        if (pickedFiles != null && pickedFiles.isNotEmpty) {
          _debugPrint('Picked ${pickedFiles.length} media files');
          setState(() {
            _mediaFiles = pickedFiles.map((file) => File(file.path)).toList();
          });
        }
      }
    } catch (e) {
      _debugPrint('Media picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting media: ${e.toString()}')),
        );
      }
    }
  }

  bool _validateInput() {
    final hasTextContent = _textController.text.trim().isNotEmpty;
    final hasMedia = _mediaFiles.isNotEmpty;
    final isValid = hasTextContent || hasMedia;
    _debugPrint('Input validation: $isValid (Text: $hasTextContent, Media: $hasMedia)');
    return isValid;
  }

  Future<void> _submitContent() async {
    if (!_validateInput()) {
      _debugPrint('Validation failed - empty content and no media');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter content or add media')),
        );
      }
      return;
    }

    final token = await _getAuthToken();
    if (token == null || token.isEmpty) {
      _debugPrint('No auth token available');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication required')),
        );
        widget.onAuthRequired?.call();
      }
      return;
    }

    setState(() {
      _isPosting = true;
      _lastError = null;
      _lastResponse = null;
    });

    try {
      final endpoint = _isReelMode
          ? 'http://31.97.185.64:3000/reels/reels'
          : 'http://31.97.185.64:3000/post';

      _debugPrint('Preparing request to $endpoint');
      _debugPrint('Mode: ${_isReelMode ? 'REEL' : 'POST'}');
      _debugPrint('Content text: "${_textController.text}"');
      _debugPrint('Media files: ${_mediaFiles.length}');

      var request = http.MultipartRequest('POST', Uri.parse(endpoint))
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json';

      if (_isReelMode) {
        request.fields['caption'] = _textController.text.trim();
        _debugPrint('Adding field: caption=${_textController.text.trim()}');
      } else {
        request.fields['content'] = _textController.text.trim();
        _debugPrint('Adding field: content=${_textController.text.trim()}');
      }

      for (var file in _mediaFiles) {
        _debugPrint('Adding media file: ${file.path}');
        request.files.add(await http.MultipartFile.fromPath(
          'media',
          file.path,
        ));
      }

      _debugPrint('Sending request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _debugPrint('Response status: ${response.statusCode}');
      _debugPrint('Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _debugPrint('Post successful');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_isReelMode ? 'Reel posted!' : 'Post created!')),
          );
          widget.onPostCreated?.call();
          _clearForm();
        }
      } else {
        String errorMessage = 'Post failed';
        try {
          final responseData = json.decode(response.body);
          errorMessage = responseData['message'] ?? errorMessage;
        } catch (e) {
          _debugPrint('Could not parse error response: $e');
        }
        _debugPrint('Error response: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      _debugPrint('Error in _submitContent: $e');
      setState(() {
        _lastError = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  void _clearForm() {
    _debugPrint('Clearing form');
    _textController.clear();
    setState(() {
      _mediaFiles = [];
      _lastError = null;
      _lastResponse = null;
    });
  }

  Widget _buildMediaPreview() {
    if (_mediaFiles.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _mediaFiles.length,
        itemBuilder: (context, index) {
          final file = _mediaFiles[index];
          final isVideo = file.path.toLowerCase().endsWith('.mp4') ||
              file.path.toLowerCase().endsWith('.mov');

          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(4),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: isVideo
                    ? _VideoThumbnail(file: file)
                    : Image.file(file, fit: BoxFit.cover),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () {
                    setState(() => _mediaFiles.removeAt(index));
                  },
                ),
              ),
              if (isVideo)
                const Positioned(
                  bottom: 4,
                  left: 4,
                  child: Icon(Icons.videocam, color: Colors.white),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
      /*  if (kDebugMode) ...[
          ExpansionTile(
            title: const Text('Debug Information', style: TextStyle(color: Colors.blue)),
            initiallyExpanded: false,
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_lastError != null)
                      Text('Last Error: $_lastError', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    Text('Last Response:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(_lastResponse ?? 'No response yet'),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
        ],*/

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: () {
                _debugPrint('Toggling mode from ${_isReelMode ? 'REEL' : 'POST'}');
                setState(() => _isReelMode = !_isReelMode);
              },
              tooltip: _isReelMode ? 'Switch to Post' : 'Switch to Reel',
            ),
            ElevatedButton(
              onPressed: _validateInput() && !_isPosting ? _submitContent : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: _isPosting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isReelMode ? 'Post Reel' : 'Post'),
            ),
          ],
        ),

        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _textController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: _isReelMode ? 'Write a caption...' : 'What\'s on your mind?',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),

        if (!_validateInput() &&
            !_isPosting &&
            _textController.text.trim().isEmpty &&
            _mediaFiles.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Text(
              'Please enter content or add media.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        _buildMediaPreview(),

        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickMedia,
            tooltip: 'Add media',
          ),
        ),

        Center(
          child: Chip(
            label: Text(_isReelMode ? 'REEL MODE' : 'POST MODE'),
            backgroundColor: _isReelMode ? Colors.purple : Colors.blue,
            labelStyle: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debugPrint('Disposing CreateContentWidget');
    _textController.dispose();
    super.dispose();
  }
}

class _VideoThumbnail extends StatefulWidget {
  final File file;

  const _VideoThumbnail({required this.file});

  @override
  __VideoThumbnailState createState() => __VideoThumbnailState();
}

class __VideoThumbnailState extends State<_VideoThumbnail> {
  Uint8List? _thumbnail;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: widget.file.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 100,
      quality: 25,
    );

    if (mounted) {
      setState(() => _thumbnail = thumbnail);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _thumbnail != null
        ? Image.memory(_thumbnail!, fit: BoxFit.cover)
        : const Center(child: CircularProgressIndicator());
  }
}