import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/anime_providers.dart';
import '../../../../core/models/anime_models.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/glass_container.dart';

class SeriesDetailsPage extends ConsumerStatefulWidget {
  final String? seriesId;
  final String? title;

  const SeriesDetailsPage({
    super.key,
    this.seriesId,
    this.title,
  });

  @override
  ConsumerState<SeriesDetailsPage> createState() => _SeriesDetailsPageState();
}

class _SeriesDetailsPageState extends ConsumerState<SeriesDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  int _selectedSeason = 1;
  Anime? _animeData;
  List<Episode> _episodes = [];
  bool _isLoading = true;

  // Fallback data (shown only during loading or when API fails)
  Map<String, dynamic> get _seriesData => {
    'title': widget.title ?? 'Loading...',
    'backdrop': '',
    'poster': '',
    'year': '',
    'rating': 0.0,
    'genres': <String>[],
    'description': 'Loading details...',
    'seasons': 1,
    'episodes': 0,
    'duration': '',
    'studio': 'Unknown',
    'status': 'Unknown',
  };

  // Data from API
  List<Map<String, dynamic>> _characters = [];
  List<Anime> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
    _fetchAnimeData();
  }

  Future<void> _fetchAnimeData() async {
    if (widget.seriesId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final api = ref.read(jikanApiProvider);
      final anime = await api.getAnimeInfo(widget.seriesId!);
      final episodes = await api.getEpisodes(widget.seriesId!);
      final characters = await api.getCharacters(widget.seriesId!);
      final recommendations = await api.getRecommendations(widget.seriesId!);
      
      if (mounted) {
        setState(() {
          _animeData = anime;
          // Fix for Movies: Jikan often returns 0 episodes for movies
          if (episodes.isEmpty && (anime?.type == 'Movie' || anime?.type == 'Special')) {
             _episodes = [
               Episode(
                 id: '1',
                 number: 1,
                 title: 'Movie',
                 description: anime?.description,
                 thumbnail: anime?.cover,
               )
             ];
          } else {
            _episodes = episodes;
          }
          _characters = characters;
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth < 1200;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero Section
              SliverToBoxAdapter(
                child: _buildHeroSection(context, isMobile),
              ),
              
              // Content Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48),
                  child: isMobile || isTablet
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEpisodesSection(),
                            const SizedBox(height: 48),
                            _buildSidebar(),
                            const SizedBox(height: 80),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Episodes (Main Content)
                            Expanded(
                              flex: 3,
                              child: _buildEpisodesSection(),
                            ),
                            const SizedBox(width: 48),
                            // Sidebar
                            SizedBox(
                              width: 320,
                              child: _buildSidebar(),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          
          // Fixed Header
          _buildFixedHeader(isMobile),
        ],
      ),
    );
  }

  Widget _buildFixedHeader(bool isMobile) {
    final isScrolled = _scrollOffset > 100;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: isScrolled ? Colors.black.withValues(alpha: 0.9) : Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 48,
            vertical: 12,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 16),
                  ),
                ),
              ),
              if (isScrolled) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _seriesData['title'],
                    style: AppTextStyles.heading.copyWith(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else
                const Spacer(),
              GestureDetector(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.share, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    final height = MediaQuery.of(context).size.height * 0.65;
    
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Backdrop image
          ( _animeData?.cover?.isNotEmpty == true || _animeData?.image?.isNotEmpty == true || (_seriesData['backdrop'] as String).isNotEmpty) 
              ? CachedNetworkImage(
                  imageUrl: _animeData?.cover ?? _animeData?.image ?? _seriesData['backdrop'],
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
                )
              : Container(color: Colors.grey[900]),
          
          // Gradient overlays
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black,
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Content
          Positioned(
            left: isMobile ? 16 : 48,
            right: isMobile ? 16 : 48,
            bottom: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badges
                Row(
                  children: [
                    _buildBadge('SERIES', AppColors.primary),
                    const SizedBox(width: 8),
                    _buildBadge('4K HDR', Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(width: 8),
                    _buildBadge('DOLBY ATMOS', Colors.white.withValues(alpha: 0.2)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  _animeData?.title ?? _seriesData['title'],
                  style: AppTextStyles.heroTitle.copyWith(
                    fontSize: isMobile ? 36 : 56,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Meta info
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          (_animeData?.rating ?? _seriesData['rating']).toString(),
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    _buildDivider(),
                    Text(
                      (_animeData?.releaseYear ?? _seriesData['year']).toString(),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    _buildDivider(),
                    Text(
                      '${_animeData?.totalEpisodes ?? _seriesData['episodes']} Episodes',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    _buildDivider(),
                    Text(
                      '${_seriesData['episodes']} Episodes',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Description
                SizedBox(
                  width: isMobile ? double.infinity : 600,
                  child: Text(
                    _animeData?.description ?? _seriesData['description'],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[300],
                      height: 1.6,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    // Play button with pulse effect
                    _buildPlayButton(),
                    const SizedBox(width: 16),
                    _buildSecondaryButton(Icons.add, 'My List'),
                    const SizedBox(width: 12),
                    _buildIconButton(Icons.thumb_up_outlined),
                    const SizedBox(width: 12),
                    _buildIconButton(Icons.thumb_down_outlined),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 12,
      color: Colors.white.withValues(alpha: 0.2),
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Widget _buildPlayButton() {
    final hasEpisodes = _episodes.isNotEmpty;
    final firstEpisode = hasEpisodes ? _episodes.first : null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: (hasEpisodes ? AppColors.primary : Colors.grey).withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: hasEpisodes ? () {
          if (firstEpisode != null) {
              Navigator.of(context).pushNamed('/player', arguments: {
                'seriesId': widget.seriesId,
                'episodeId': firstEpisode.id,
                'episodeNumber': firstEpisode.number,
                'seriesTitle': _animeData?.title ?? widget.title ?? 'Unknown',
                'episodeTitle': firstEpisode.title,
            });
          }
        } : null,
        icon: const Icon(Icons.play_arrow, size: 24),
        label: Text(hasEpisodes ? 'Play S1:E1' : 'Not Available'),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasEpisodes ? AppColors.primary : Colors.grey.withValues(alpha: 0.2),
          foregroundColor: hasEpisodes ? Colors.white : Colors.white.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(IconData icon, String label) {
    if (_animeData == null) return const SizedBox.shrink();
    
    final storage = ref.watch(storageServiceProvider);
    final isInList = storage.isInMyList(_animeData!.id);
    
    return OutlinedButton.icon(
      onPressed: () async {
        if (isInList) {
          await storage.removeFromMyList(_animeData!.id);
        } else {
          await storage.addToMyList(_animeData!);
        }
        setState(() {}); // Trigger rebuild to update button state
      },
      icon: Icon(isInList ? Icons.check : Icons.add, size: 18),
      label: Text(isInList ? 'In List' : 'My List'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(
          color: isInList ? AppColors.primary : Colors.white.withValues(alpha: 0.2),
        ),
        backgroundColor: isInList ? AppColors.primary.withValues(alpha: 0.1) : null,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: const StadiumBorder(),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildEpisodesSection() {
    // Fetch progress for all episodes
    final storage = ref.watch(storageServiceProvider);
    final progressMap = widget.seriesId != null 
        ? storage.getAnimeEpisodesProgress(widget.seriesId!) 
        : <String, double>{};

    // Convert Episode objects to map format for display
    final episodesToShow = _episodes.map((ep) {
      final progress = progressMap[ep.id.toString()] ?? 0.0;
      final isWatched = progress > 0.9;
      
      return {
        'number': ep.number,
        'title': ep.title ?? 'Episode ${ep.number}',
        'description': ep.description ?? '',
        'thumbnail': ep.thumbnail ?? _animeData?.image ?? '',
        'duration': ep.duration ?? '24:00',
        'progress': progress,
        'watched': isWatched,
        'id': ep.id,
      };
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with episode count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Episodes (${episodesToShow.length})',
              style: AppTextStyles.displayMedium.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_episodes.isEmpty && _isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Episodes list or empty state
        if (episodesToShow.isEmpty && !_isLoading)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No episodes available',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: episodesToShow.length,
            itemBuilder: (context, index) => _EpisodeCard(
              episode: episodesToShow[index],
              onTap: () async {
                final episodeId = episodesToShow[index]['id']?.toString() ?? '';
                final episodeTitle = episodesToShow[index]['title']?.toString() ?? '';
                
                await Navigator.of(context).pushNamed('/player', arguments: {
                  'seriesId': widget.seriesId,
                  'episodeId': episodeId,
                  'episodeNumber': episodesToShow[index]['number'],
                  'seriesTitle': _animeData?.title ?? widget.title ?? 'Unknown',
                  'episodeTitle': episodeTitle,
                });
                
                // Refresh state to update progress bars after returning
                if (mounted) setState(() {});
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSeasonDropdown() {
    return GlassContainer(
      color: Colors.white.withValues(alpha: 0.05),
      blur: 10,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedSeason,
          dropdownColor: const Color(0xFF1A1A1A),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          style: AppTextStyles.labelMedium,
          items: List.generate(
            _seriesData['seasons'],
            (i) => DropdownMenuItem(
              value: i + 1,
              child: Text('Season ${i + 1}'),
            ),
          ),
          onChanged: (value) {
            if (value != null) setState(() => _selectedSeason = value);
          },
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cast & Crew
        Text(
          'Cast & Crew',
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _characters.map((person) => _buildCastItem(person)).toList(),
        ),
        const SizedBox(height: 32),
        
        // About
        Text(
          'About',
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _buildInfoRow('Studio', _animeData?.studio ?? _seriesData['studio']),
        _buildInfoRow('Status', _animeData?.status ?? _seriesData['status']),
        _buildInfoRow('Duration', _animeData?.duration ?? _seriesData['duration']),
        _buildInfoRow('Genres', _animeData?.genres.isNotEmpty == true 
            ? _animeData!.genres.join(', ') 
            : (_seriesData['genres'] as List).join(', ')),
        const SizedBox(height: 32),
        
        // More Like This
        Text(
          'More Like This',
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2 / 3,
          children: _recommendations.map((anime) => _buildSimilarCard(anime)).toList(),
        ),
      ],
    );
  }

  Widget _buildCastItem(Map<String, dynamic> person) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(person['image']),
          ),
          const SizedBox(height: 8),
          Text(
            person['name'],
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            person['role'],
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarCard(Anime anime) {
    return GestureDetector(
      onTap: () {
        // Navigate to details of recommended anime
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeriesDetailsPage(
              seriesId: anime.id,
              title: anime.title,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[900],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: anime.image,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: Colors.grey[800]),
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                    ),
                  ),
                  child: Text(
                    anime.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EpisodeCard extends StatefulWidget {
  final Map<String, dynamic> episode;
  final VoidCallback? onTap;

  const _EpisodeCard({
    required this.episode,
    this.onTap,
  });

  @override
  State<_EpisodeCard> createState() => _EpisodeCardState();
}

class _EpisodeCardState extends State<_EpisodeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final episode = widget.episode;
    final progress = episode['progress'] as double;
    final watched = episode['watched'] as bool;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered 
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered 
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 160,
                      height: 90,
                      transform: Matrix4.identity()
                        ..scale(_isHovered ? 1.05 : 1.0),
                      child: (episode['thumbnail'] != null && (episode['thumbnail'] as String).isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: episode['thumbnail'],
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(color: Colors.grey[800]),
                            )
                          : Container(
                              color: Colors.grey[900],
                              child: Center(
                                child: Icon(Icons.movie, color: Colors.white.withValues(alpha: 0.2)),
                              ),
                            ),
                    ),
                  ),
                  
                  // Progress bar
                  if (progress > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.only(
                                bottomLeft: const Radius.circular(8),
                                bottomRight: progress >= 1.0 
                                    ? const Radius.circular(8) 
                                    : Radius.zero,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Play icon on hover
                  if (_isHovered)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  
                  // Duration badge
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        episode['duration'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  // Watched indicator
                  if (watched)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Episode info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'E${episode['number']}',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            episode['title'],
                            style: AppTextStyles.titleSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      episode['description'],
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Download button
              if (_isHovered)
                Container(
                  margin: const EdgeInsets.only(left: 12),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.download_outlined),
                    color: Colors.white,
                    iconSize: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
