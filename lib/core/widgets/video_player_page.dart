import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String? description;
  const VideoPlayerPage({super.key, required this.videoUrl, this.description});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        // Add other options like aspect ratio, error builder, etc.
        materialProgressColors: ChewieProgressColors(
          playedColor: Theme.of(context).primaryColor, // Use theme color
          handleColor: Theme.of(context).primaryColor,
          // ... other colors
        ),
        placeholder: Container(color: Colors.black),
        autoInitialize: true,
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error initializing video player: $e");
      setState(() {
        _isLoading = false;
      }); // Stop loading on error
      // Show error message if needed
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: widget.description != null && widget.description!.isNotEmpty
            ? Text(widget.description!, style: TextStyle(fontSize: 14))
            : null,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : (_chewieController != null &&
                      _chewieController!
                          .videoPlayerController
                          .value
                          .isInitialized
                  ? Chewie(controller: _chewieController!)
                  : Column(
                      // Show error message if controller failed
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 40),
                        SizedBox(height: 10),
                        Text(
                          'Could not load video.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    )),
      ),
    );
  }
}
