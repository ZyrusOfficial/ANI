import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/anime_models.dart';
import '../../../../shared/widgets/glass_container.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 48,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 40),
              
              // Profile Card
              _buildProfileCard(isMobile),
              const SizedBox(height: 40),
              
              // Stats Section
              _buildStatsSection(isMobile),
              const SizedBox(height: 40),
              
              // My List Section
              _buildMyListSection(isMobile),
              const SizedBox(height: 40),
              
              // Continue Watching
              _buildContinueWatchingSection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Profile',
              style: AppTextStyles.heading.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('/settings'),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Center(
              child: Icon(Icons.settings, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(bool isMobile) {
    return GlassContainer(
      color: Colors.white.withValues(alpha: 0.03),
      blur: 20,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      padding: const EdgeInsets.all(32),
      child: isMobile
          ? Column(
              children: [
                _buildAvatar(),
                const SizedBox(height: 24),
                _buildProfileInfo(),
              ],
            )
          : Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 32),
                Expanded(child: _buildProfileInfo()),
                _buildEditButton(),
              ],
            ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBl11RQunk9cK9Vev4hT4ZNqLzJ5s6R7UD3Nxs4JME0BKXw12pni76nVIbvkG0xCuzsZI52Gus7mCNL8rEPbQkCAHTcdwoiadtlrGe4wjvMAEEjm6VOEelQPwHisXZIsrnOE3D6xajC9pK6GLNsnrkAm0JHe5D47wb0RVz6VkGXmBK43w6rDDQ6dBcfOXq0sPKsmam3SgcXiR2P72unUj0vXq85zUAVFfuJEaSEv9mwQ-WeTEsBVOT6uuUrkKu2gKYT4kGD0NSI2VA',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zyrus',
          style: AppTextStyles.displayMedium.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@zyrus_watch',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Premium Member',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Since Jan 2024',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.edit, size: 16),
      label: const Text('Edit Profile'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: const StadiumBorder(),
      ),
    );
  }

  Widget _buildStatsSection(bool isMobile) {
    final storage = ref.watch(storageServiceProvider);
    
    // Calculate stats from real history
    final history = storage.getWatchHistory();
    // Count unique episodes
    int episodeCount = 0;
    // Calculate total duration
    int totalSeconds = 0;
    
    history.forEach((key, value) {
      episodeCount++;
      totalSeconds += (value['position'] as int? ?? 0);
    });
    
    final hoursWatched = (totalSeconds / 3600).round();
    final myListCount = storage.getMyList().length;
    
    // We don't have a reliable 'Completed' metric yet without tracking total episodes per anime in history more strictly
    // For now, let's assume if progress > 0.9 it's completed
    int completedCount = 0;
    history.forEach((key, value) {
      final progress = value['progress'] as double? ?? 0.0;
      if (progress > 0.9) completedCount++;
    });

    final stats = [
      {'icon': Icons.play_circle_fill, 'value': '$episodeCount', 'label': 'Episodes', 'color': AppColors.primary},
      {'icon': Icons.access_time, 'value': '$hoursWatched', 'label': 'Hours', 'color': const Color(0xFF5E5CE6)},
      {'icon': Icons.check_circle, 'value': '$completedCount', 'label': 'Completed', 'color': const Color(0xFF30D158)},
      {'icon': Icons.bookmark, 'value': '$myListCount', 'label': 'In List', 'color': const Color(0xFFFF9F0A)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Watch Stats',
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) => _buildStatCard(stats[index]),
        ),
      ],
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return GlassContainer(
      color: Colors.white.withValues(alpha: 0.03),
      blur: 10,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            stat['icon'] as IconData,
            color: stat['color'] as Color,
            size: 24,
          ),
          const Spacer(),
          Text(
            stat['value'] as String,
            style: AppTextStyles.displayMedium.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            stat['label'] as String,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyListSection(bool isMobile) {
    final storage = ref.watch(storageServiceProvider);
    final myList = storage.getMyList();

    if (myList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My List',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.bookmark_border, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(
                  'Your list is empty. Add anime to track them!',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My List',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: myList.length,
            itemBuilder: (context, index) {
              final item = myList[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _MyListCard(
                  title: item.title,
                  imageUrl: item.image,
                  onTap: () {
                     Navigator.of(context).pushNamed('/details', arguments: {
                      'id': item.id,
                      'title': item.title,
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContinueWatchingSection() {
    final storage = ref.watch(storageServiceProvider);
    final historyMap = storage.getWatchHistory();
    
    // Convert to list and sort by lastWatched (descending)
    final historyList = historyMap.entries.map((e) => e.value).toList();
    historyList.sort((a, b) {
      final dateA = DateTime.tryParse(a['lastWatched'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = DateTime.tryParse(b['lastWatched'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });

    if (historyList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Continue Watching',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final item = historyList[index];
              final anime = Anime.fromJson(item['anime']);
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _ContinueCard(
                  title: anime.title,
                  episode: 'E${item['episodeNumber']}',
                  progress: item['progress'] ?? 0.0,
                  imageUrl: anime.image.isNotEmpty ? anime.image : anime.cover ?? '',
                  onTap: () {
                    // Resume playback
                     Navigator.of(context).pushNamed('/player', arguments: {
                      'seriesId': anime.id,
                      'episodeId': item['episodeId'],
                      'episodeNumber': item['episodeNumber'],
                      'seriesTitle': anime.title,
                      'episodeTitle': 'Episode ${item['episodeNumber']}',
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MyListCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final VoidCallback? onTap;

  const _MyListCard({
    required this.title,
    required this.imageUrl,
    this.onTap,
  });

  @override
  State<_MyListCard> createState() => _MyListCardState();
}

class _MyListCardState extends State<_MyListCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 130,
          transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _isHovered ? 0.4 : 0.2),
                blurRadius: _isHovered ? 30 : 15,
                spreadRadius: _isHovered ? -5 : -10,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.imageUrl.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(color: Colors.grey[800]),
                  )
                else
                  Container(color: Colors.grey[800]),
                
                if (_isHovered)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final String title;
  final String episode;
  final double progress;
  final String imageUrl;
  final VoidCallback? onTap;

  const _ContinueCard({
    required this.title,
    required this.episode,
    required this.progress,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 120,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imageUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(color: Colors.grey[800]),
                      )
                    else 
                      Container(color: Colors.grey[800]),
                      
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        color: Colors.white.withValues(alpha: 0.2),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      episode,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toInt()}% watched',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
