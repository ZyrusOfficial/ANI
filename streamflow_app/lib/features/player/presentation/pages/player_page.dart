import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../../shared/widgets/embed_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/anime_providers.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/anime_models.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../widgets/playback_speed_modal.dart';
import '../widgets/quality_selector_modal.dart';

class PlayerPage extends ConsumerStatefulWidget {
  final String? seriesId;
  final String? episodeId;
  final int? episodeNumber;
  final String? seriesTitle;
  final String? episodeTitle;

  const PlayerPage({
    super.key,
    this.seriesId,
    this.episodeId,
    this.episodeNumber,
    this.seriesTitle,
    this.episodeTitle,
  });

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage> with SingleTickerProviderStateMixin {
  // Media Kit
  late final Player _player;
  late final VideoController _controller;

  // UI State
  bool _controlsVisible = true;
  bool _isLoading = true;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isEmbedMode = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 100.0;
  
  Timer? _hideControlsTimer;
  Timer? _progressTimer;
  late AnimationController _fadeController;
  bool _isFullscreen = true; // starts fullscreen (immersive mode)
  
  // Dynamic data
  String _seriesTitle = 'Loading...';
  String _episodeTitle = 'Loading...';
  int _episodeNumber = 1;
  String? _streamUrl;
  Map<String, String>? _streamHeaders;
  StreamingInfo? _streamingInfo;
  StreamingSource? _currentSource;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    
    // Initialize Media Kit Player
    _player = Player(
      configuration: const PlayerConfiguration(
        logLevel: MPVLogLevel.info,
      ),
    );
    
    // Force software rendering — bypasses broken GPU texture sharing on Wayland (Linux only)
    // On other platforms, let media_kit decide (defaults to HW accel)
    _controller = VideoController(
      _player,
      configuration: VideoControllerConfiguration(
        enableHardwareAcceleration: !Platform.isLinux,
      ),
    );

    // Configure mpv to also use software decoding (Linux only)
    if (Platform.isLinux) {
      _configureMpv();
    }

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _startHideTimer();

    // Initialize from widget params
    _seriesTitle = widget.seriesTitle ?? 'Loading...';
    _episodeTitle = widget.episodeTitle ?? 'Episode ${widget.episodeNumber ?? 1}';
    _episodeNumber = widget.episodeNumber ?? 1;

    // Set up player listeners
    _setupPlayerListeners();

    // Fetch and play streaming data
    _fetchStreamingData();

    // Set fullscreen/immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// Force mpv to use software decoding (no GPU)
  void _configureMpv() {
    try {
      if (_player.platform is NativePlayer) {
        final mpv = _player.platform as NativePlayer;
        mpv.setProperty('hwdec', 'no');
        mpv.setProperty('vo', 'libmpv');
        mpv.setProperty('gpu-context', 'auto');
        print('[Player] mpv configured: hwdec=no, vo=libmpv');
      }
    } catch (e) {
      print('[Player] mpv config error (non-fatal): $e');
    }
  }

  void _setupPlayerListeners() {
    _player.stream.position.listen((position) {
      if (mounted) setState(() => _position = position);
    });

    _player.stream.duration.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });

    _player.stream.playing.listen((playing) {
      if (mounted) {
        setState(() => _isPlaying = playing);
        if (playing) _startHideTimer();
      }
    });

    _player.stream.buffering.listen((buffering) {
      if (mounted) setState(() => _isBuffering = buffering);
    });
  }

  Future<void> _fetchStreamingData() async {
    if (widget.episodeId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final StreamingInfo? streamingInfo = await ref.read(streamingSourcesProvider(
        (title: widget.seriesTitle ?? '', episode: widget.episodeNumber ?? 1)
      ).future);
      
      if (mounted && streamingInfo != null) {
        _streamingInfo = streamingInfo;
        final bestSource = streamingInfo.bestQuality;
        _streamHeaders = streamingInfo.headers;
        _currentSource = bestSource;
        
        if (bestSource != null && bestSource.url.isNotEmpty) {
          _streamUrl = bestSource.url;
          print('[Player] Stream URL: $_streamUrl');
          print('[Player] Is M3U8: ${bestSource.isM3U8}');
          
          final isNativePlayable = bestSource.isM3U8 || _isDirectVideoUrl(bestSource.url);
          
          if (isNativePlayable) {
            print('[Player] Playing natively via media_kit (${bestSource.isM3U8 ? "M3U8" : "MP4"})');
            await _player.open(Media(
              _streamUrl!, 
              httpHeaders: _streamHeaders,
            ));
            setState(() => _isLoading = false);
            _startProgressSaver();
          } else {
            if (Theme.of(context).platform == TargetPlatform.linux || 
                Theme.of(context).platform == TargetPlatform.windows ||
                Theme.of(context).platform == TargetPlatform.macOS) {
               print('[Player] Embeds not supported on Desktop: $_streamUrl');
               if (mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('This source type (Embed) is not supported on Desktop yet.'))
                 );
                 setState(() => _isLoading = false);
               }
            } else {
              setState(() {
                _isEmbedMode = true;
                _isLoading = false;
              });
            }
          }
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('[Player] Error fetching stream: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isDirectVideoUrl(String url) {
    final directDomains = [
      'tools.fast4speed.rsvp',
      'repackager.wixmp.com',
      'sharepoint.com',
    ];
    final videoExtensions = ['.mp4', '.mkv', '.avi', '.webm', '.ts'];
    if (directDomains.any((d) => url.contains(d))) return true;
    if (videoExtensions.any((ext) => url.toLowerCase().contains(ext))) return true;
    return false;
  }
  
  void _startProgressSaver() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!mounted || !_isPlaying) {
        timer.cancel();
        _progressTimer = null;
        return;
      }
      _saveProgress();
    });
  }

  Future<void> _saveProgress() async {
    if (_position.inSeconds < 10 || _duration.inSeconds < 10) return;
    try {
      final storage = ref.read(storageServiceProvider);
      final anime = Anime(
        id: widget.seriesId ?? '',
        title: widget.seriesTitle ?? 'Unknown',
        image: '',
      );
      await storage.saveWatchProgress(
        animeId: widget.seriesId ?? '',
        episodeId: widget.episodeId ?? '',
        episodeNumber: widget.episodeNumber ?? 1,
        position: _position,
        duration: _duration,
        animeData: anime,
      );
    } catch (e) {
      print('[Player] Error saving progress: $e');
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _progressTimer?.cancel();
    _fadeController.dispose();
    _player.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (_isPlaying && mounted) {
        setState(() => _controlsVisible = false);
        _fadeController.reverse();
      }
    });
  }

  void _showControls() {
    setState(() => _controlsVisible = true);
    _fadeController.forward();
    _startHideTimer();
  }

  void _togglePlayPause() {
    _player.playOrPause();
  }

  void _seekTo(Duration position) {
    _player.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showQualitySelector() {
    if (_streamingInfo == null || _streamingInfo!.sources.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => QualitySelectorModal(
        sources: _streamingInfo!.sources,
        currentSource: _currentSource,
        onSourceSelected: (source) async {
          if (source.url == _currentSource?.url) return;
          
          setState(() {
            _currentSource = source;
            _streamUrl = source.url;
            _isLoading = true;
          });

          // Re-open player with new source
          final isNativePlayable = source.isM3U8 || _isDirectVideoUrl(source.url);
          if (isNativePlayable) {
            await _player.open(Media(
              source.url,
              httpHeaders: _streamHeaders,
            ));
          }
          
          setState(() => _isLoading = false);
        },
      ),
    );
  }

  void _showPlaybackSpeed() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaybackSpeedModal(
        currentSpeed: _playbackSpeed,
        onSpeedSelected: (speed) {
          setState(() => _playbackSpeed = speed);
          _player.setRate(speed);
        },
      ),
    );
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _playNextEpisode() {
    // Navigate to same page with next episode
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerPage(
          seriesId: widget.seriesId,
          seriesTitle: widget.seriesTitle,
          episodeId: widget.episodeId, // Ideally need next episode ID
          episodeNumber: _episodeNumber + 1,
          episodeTitle: 'Episode ${_episodeNumber + 1}', // Placeholder
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isEmbedMode && _streamUrl != null) {
      return EmbedPlayer(
        embedUrl: _streamUrl!,
        title: '$_seriesTitle - Episode $_episodeNumber',
        headers: _streamHeaders,
        onBack: () => Navigator.pop(context),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: MouseRegion(
        onHover: (_) => _showControls(),
        child: GestureDetector(
          onTap: _showControls,
          onDoubleTapDown: (details) {
            final screenWidth = MediaQuery.of(context).size.width;
            final tapX = details.localPosition.dx;
            if (tapX < screenWidth / 3) {
              _seekTo(_position - const Duration(seconds: 10));
            } else if (tapX > screenWidth * 2 / 3) {
              _seekTo(_position + const Duration(seconds: 10));
            } else {
              _togglePlayPause();
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Media Kit Video Layer
              Video(
                controller: _controller,
                fill: Colors.black,
                fit: BoxFit.contain,
                controls: NoVideoControls,
              ),
              
              // Loading indicator
              if (_isLoading || _isBuffering)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              
              // Streaming unavailable message
              if (!_isLoading && _streamUrl == null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_off, color: Colors.grey[400], size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Streaming Unavailable',
                          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This episode is not available from any streaming provider.\nTry a different episode or anime.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Ambilight effect
              if (_streamUrl != null) 
                _buildAmbilightEffect(),
              
              // Controls overlay
              AnimatedBuilder(
                animation: _fadeController,
                builder: (context, child) => Opacity(
                  opacity: _fadeController.value,
                  child: _controlsVisible ? child : const SizedBox.shrink(),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildGradientOverlays(),
                    _buildTopBar(),
                    if (!_isPlaying && !_isBuffering && !_isLoading && _streamUrl != null) 
                      _buildCenterPlayButton(),
                    if (_streamUrl != null)
                      _buildBottomControls(),
                    if (_streamUrl != null)
                      _buildUpNextButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmbilightEffect() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 150,
                spreadRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlays() {
    return Stack(
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.8),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.9),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _seriesTitle,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        shadows: [const Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black)],
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'E$_episodeNumber: $_episodeTitle',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        shadows: [const Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black)],
                      ),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (_streamUrl != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'STREAM READY',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterPlayButton() {
    return Center(
      child: GestureDetector(
        onTap: _togglePlayPause,
        child: Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 48),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTimeline(),
              const SizedBox(height: 16),
              _buildControlBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final double percentage = _duration.inMilliseconds == 0 
        ? 0.0 
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);

    return Column(
      children: [
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final double percent = (details.localPosition.dx / box.size.width).clamp(0.0, 1.0);
            final newPos = Duration(milliseconds: (percent * _duration.inMilliseconds).round());
            _seekTo(newPos);
          },
          onTapDown: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final double percent = (details.localPosition.dx / box.size.width).clamp(0.0, 1.0);
            final newPos = Duration(milliseconds: (percent * _duration.inMilliseconds).round());
            _seekTo(newPos);
          },
          child: Container(
            height: 24,
            alignment: Alignment.center,
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          blurRadius: 8, spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: (percentage * (MediaQuery.of(context).size.width - 48)) - 6,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 8)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_position),
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white, fontWeight: FontWeight.w500,
                shadows: [const Shadow(color: Colors.black, blurRadius: 2)],
              ),
            ),
            Text(
              _formatDuration(_duration),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                shadows: [const Shadow(color: Colors.black, blurRadius: 2)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlBar() {
    return GlassContainer(
      color: Colors.black.withValues(alpha: 0.4),
      blur: 20,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildControlButton(Icons.replay_10, () => _seekTo(_position - const Duration(seconds: 10))),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 48, height: 48,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.black, size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _buildControlButton(Icons.forward_10, () => _seekTo(_position + const Duration(seconds: 10))),
            ],
          ),
          Row(
            children: [
              _buildControlButton(
                _volume == 0 ? Icons.volume_off : Icons.volume_up,
                () {
                  final newVol = _volume > 0 ? 0.0 : 100.0;
                  setState(() => _volume = newVol);
                  _player.setVolume(newVol);
                },
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: _volume,
                    min: 0, max: 100,
                    onChanged: (value) {
                      setState(() => _volume = value);
                      _player.setVolume(value);
                    },
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: _showQualitySelector,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _currentSource?.quality.toUpperCase() ?? 'AUTO',
                    style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // _buildControlButton(Icons.subtitles_outlined, () {}), // TODO: Subs
              // const SizedBox(width: 8),
              _buildControlButton(Icons.speed, _showPlaybackSpeed),
              const SizedBox(width: 8),
              _buildControlButton(Icons.fullscreen, () {
                 // Simple toggle for now
                 SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildUpNextButton() {
    return Positioned(
      bottom: 140, right: 24,
      child: GlassContainer(
        color: Colors.black.withValues(alpha: 0.6),
        blur: 20,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: GestureDetector(
          onTap: _playNextEpisode,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UP NEXT',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary, fontSize: 9, letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'E${_episodeNumber + 1}',
                    style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.skip_next, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
