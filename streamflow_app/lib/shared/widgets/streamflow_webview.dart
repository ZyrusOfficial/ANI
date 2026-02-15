import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// StreamFlow WebView Controller
/// Handles local HTML rendering with platform-specific optimizations
class StreamFlowWebView extends StatefulWidget {
  final String page;
  final Function(String route)? onNavigate;
  final Function(String animeId, String? episodeId)? onPlay;
  final Function(String animeId)? onAddToList;

  const StreamFlowWebView({
    super.key,
    required this.page,
    this.onNavigate,
    this.onPlay,
    this.onAddToList,
  });

  @override
  State<StreamFlowWebView> createState() => _StreamFlowWebViewState();
}

class _StreamFlowWebViewState extends State<StreamFlowWebView> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    // Create controller with platform-specific settings
    final controller = WebViewController();

    // Common configuration
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(Colors.black);

    // Add Flutter bridge
    await controller.addJavaScriptChannel(
      'FlutterBridge',
      onMessageReceived: _handleBridgeMessage,
    );

    // Set navigation delegate
    await controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _isLoading = true);
        },
        onPageFinished: (_) {
          if (mounted) {
            setState(() => _isLoading = false);
            _injectPlatformInfo();
          }
        },
        onWebResourceError: (error) {
          debugPrint('WebView error: ${error.description}');
        },
      ),
    );

    // Load page
    await _loadPage(controller);

    if (mounted) {
      setState(() {
        _controller = controller;
        _isInitialized = true;
      });
    }
  }

  Future<void> _loadPage(WebViewController controller) async {
    try {
      // Load HTML from assets
      final htmlPath = 'assets/web/pages/${widget.page}.html';
      String html = await rootBundle.loadString(htmlPath);
      
      // Inject CSS and JS paths for local loading
      html = _preprocessHtml(html);
      
      // Load HTML string
      await controller.loadHtmlString(html, baseUrl: 'file:///');
    } catch (e) {
      debugPrint('Failed to load page: $e');
    }
  }

  String _preprocessHtml(String html) {
    // Add viewport meta for proper scaling
    if (!html.contains('viewport')) {
      html = html.replaceFirst('<head>', '''<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">''');
    }
    
    // Add platform class to body
    final platformClass = Platform.isAndroid ? 'platform-android' : 'platform-linux';
    html = html.replaceFirst('class="', 'class="$platformClass ');
    
    return html;
  }

  void _injectPlatformInfo() async {
    if (_controller == null) return;
    final platform = Platform.isAndroid ? 'android' : 'linux';
    await _controller!.runJavaScript('''
      if (window.StreamFlow) {
        window.StreamFlow.platform = '$platform';
        window.StreamFlow.optimizeForPlatform();
      }
    ''');
  }

  void _handleBridgeMessage(JavaScriptMessage message) {
    try {
      final data = json.decode(message.message) as Map<String, dynamic>;
      final action = data['action'] as String?;
      final payload = data['data'] as Map<String, dynamic>?;

      switch (action) {
        case 'navigate':
          widget.onNavigate?.call(payload?['route'] ?? '');
          break;
        case 'play':
          widget.onPlay?.call(
            payload?['animeId'] ?? '',
            payload?['episodeId'] as String?,
          );
          break;
        case 'addToList':
          widget.onAddToList?.call(payload?['animeId'] ?? '');
          break;
        default:
          debugPrint('Unknown bridge action: $action');
      }
    } catch (e) {
      debugPrint('Bridge message error: $e');
    }
  }

  /// Send data to WebView
  Future<void> sendToWebView(String action, Map<String, dynamic> payload) async {
    if (_controller == null) return;
    final message = json.encode({'action': action, 'payload': payload});
    await _controller!.runJavaScript(
      '''window.StreamFlow?.receiveFromFlutter($message);''',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Black background for OLED optimization
        Container(color: Colors.black),
        
        // WebView - only show when initialized
        if (_isInitialized && _controller != null)
          WebViewWidget(controller: _controller!),
        
        // Loading indicator
        if (_isLoading || !_isInitialized)
          Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD41142),
                strokeWidth: 2,
              ),
            ),
          ),
      ],
    );
  }
}

/// Platform-optimized WebView wrapper
class OptimizedWebViewPage extends StatelessWidget {
  final String page;
  final VoidCallback? onBack;

  const OptimizedWebViewPage({
    super.key,
    required this.page,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamFlowWebView(
        page: page,
        onNavigate: (route) {
          debugPrint('Navigate to: $route');
          switch (route) {
            case 'home':
              Navigator.of(context).pushReplacementNamed('/');
              break;
            case 'search':
              Navigator.of(context).pushNamed('/search');
              break;
            default:
              Navigator.of(context).pushNamed('/$route');
          }
        },
        onPlay: (animeId, episodeId) {
          debugPrint('Play: $animeId, episode: $episodeId');
          Navigator.of(context).pushNamed(
            '/player',
            arguments: {'animeId': animeId, 'episodeId': episodeId},
          );
        },
        onAddToList: (animeId) {
          debugPrint('Add to list: $animeId');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to My List'),
              backgroundColor: Color(0xFFD41142),
            ),
          );
        },
      ),
    );
  }
}
