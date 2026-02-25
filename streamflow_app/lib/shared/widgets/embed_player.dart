import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// WebView-based Embed Player
/// 
/// Used as a fallback when direct M3U8 streaming is not available.
/// Loads embed URLs (like embtaku.pro) in a fullscreen WebView.
class EmbedPlayer extends StatefulWidget {
  final String embedUrl;
  final String? title;
  final VoidCallback? onBack;
  final Map<String, String>? headers;

  const EmbedPlayer({
    super.key,
    required this.embedUrl,
    this.title,
    this.onBack,
    this.headers,
  });

  @override
  State<EmbedPlayer> createState() => _EmbedPlayerState();
}

class _EmbedPlayerState extends State<EmbedPlayer> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
    // Lock to landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Hide system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _initWebView() async {
    final controller = WebViewController();

    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(Colors.black);
    
    // Note: setMediaPlaybackRequiresUserGesture is only available on Android/iOS
    // For Linux, media playback works without this setting

    await controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _isLoading = true);
        },
        onPageFinished: (_) {
          if (mounted) {
            setState(() => _isLoading = false);
            // Auto-hide controls after page loads
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) setState(() => _showControls = false);
            });
          }
        },
        onWebResourceError: (error) {
          debugPrint('[EmbedPlayer] WebView error: ${error.description}');
        },
      ),
    );

    // Load the embed URL
    final uri = Uri.parse(widget.embedUrl);
    await controller.loadRequest(
      uri,
      headers: widget.headers ?? {'Referer': 'https://anitaku.to'},
    );

    if (mounted) {
      setState(() => _controller = controller);
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // WebView
            if (_controller != null)
              WebViewWidget(controller: _controller!),
            
            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFFD41142),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading player...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Top bar with back button
            if (_showControls)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: widget.onBack ?? () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.title ?? 'Playing',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Fullscreen indicator badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.web, color: Colors.white70, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'EMBED',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
