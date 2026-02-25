import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/providers/anime_providers.dart';
import '../../../../core/models/anime_models.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../widgets/trending_section.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _kenBurnsController;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _kenBurnsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _kenBurnsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    // Fetch live data
    final trendingAsync = ref.watch(trendingAnimeProvider);

    return Scaffold(
      backgroundColor: Colors.black, // HTML: bg-black
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Hero Section matches HTML: relative w-full h-[90vh]
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: trendingAsync.when(
                    data: (animeList) {
                      if (animeList.isEmpty) return _buildFallbackHero(isMobile);
                      // Use first trending item as Hero
                      return _HeroSection(
                        anime: animeList.first, 
                        kenBurnsController: _kenBurnsController, 
                        isMobile: isMobile
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    error: (err, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Error loading trending: $err', style: const TextStyle(color: Colors.red)),
                      ),
                    ),
                  ),
                ),

                // Content Section matches HTML: -mt-20 relative z-20
                Transform.translate(
                  offset: const Offset(0, -80), // -mt-20 (approx 80px)
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1800),
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 32 : 64), // px-8 md:px-16
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRecommendedSection(),
                        const SizedBox(height: 80),
                        const TrendingSection(), // Uses its own provider
                        const SizedBox(height: 80),
                        _buildContinueWatchingSection(),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Fixed Header matches HTML: fixed top-0 left-0 right-0 z-50
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _FixedHeader(scrollOffset: _scrollOffset, isMobile: isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackHero(bool isMobile) {
    // Fallback to the original "Eclipsed Horizons" hardcoded hero if API fails or loading
    return _HeroSection(
      anime: null, // Signals to use fallback data
      kenBurnsController: _kenBurnsController,
      isMobile: isMobile,
    );
  }

  Widget _buildRecommendedSection() {
    final popularAsync = ref.watch(popularAnimeProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          padding: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Recommended ',
                      style: AppTextStyles.displayMedium.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w200, // font-extralight
                        letterSpacing: -1.0, // tracking-tight
                      ),
                    ),
                    TextSpan(
                      text: 'for You',
                      style: AppTextStyles.displayMedium.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.bold, // font-bold
                        color: Colors.white.withValues(alpha: 0.4), // text-white/40
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _NavArrowButton(Icons.chevron_left),
                  const SizedBox(width: 8),
                  _NavArrowButton(Icons.chevron_right),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24), // gap-8 (header to list) isn't explicitly gap-8 but close

        // Horizontal List
        SizedBox(
          height: 600, // Sufficient height for card + reflection/shadow + text
          child: popularAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            error: (_, __) => const Center(child: Text('Failed to load', style: TextStyle(color: Colors.white54))),
            data: (animeList) {
              if (animeList.isEmpty) return const Center(child: Text('No recommendations', style: TextStyle(color: Colors.white54)));
              
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none, // Allow shadows to overflow
                itemCount: animeList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 40),
                itemBuilder: (context, index) {
                  final anime = animeList[index];
                  // Generate a deterministic color based on title length for variety
                  final colorIdx = anime.title.length % 5;
                  final colors = [
                    const Color.fromRGBO(255, 100, 30, 0.5), // Orange
                    const Color.fromRGBO(90, 40, 255, 0.5), // Indigo
                    const Color.fromRGBO(40, 90, 255, 0.5), // Blue
                    const Color.fromRGBO(40, 210, 255, 0.5), // Cyan
                    const Color.fromRGBO(255, 40, 140, 0.5), // Rose
                  ];
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/details', arguments: {
                        'id': anime.id,
                        'title': anime.title,
                      });
                    },
                    child: _AnimeCard(
                      title: anime.title,
                      genres: anime.genres.take(2).toList(),
                      imageUrl: (anime.image.isNotEmpty) ? anime.image : '',
                      shadowColor: colors[colorIdx],
                      hoverShadowColor: colors[colorIdx].withValues(alpha: 0.8),
                      badges: [
                        if (anime.rating != null) '${anime.rating} ★',
                        anime.type ?? 'TV'
                      ],
                      description: anime.description ?? 'No description available.',
                      meta: anime.releaseYear?.toString() ?? 'Unknown',
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContinueWatchingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Continue ',
                  style: AppTextStyles.displayMedium.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w200,
                    letterSpacing: -1.0,
                  ),
                ),
                TextSpan(
                  text: 'Watching',
                  style: AppTextStyles.displayMedium.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 300,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
             children: const [
              _ContinueWatchingCard(
                title: 'Lost Paradise',
                episode: 'S1:E4',
                remaining: '24m Remaining',
                progress: 0.7,
                imageUrl: 'https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?w=800',
              ),
              SizedBox(width: 48),
              _ContinueWatchingCard(
                title: 'Dark Matter',
                episode: 'S2:E8',
                remaining: '12m Remaining',
                progress: 0.45,
                imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800',
              ),
              SizedBox(width: 48),
              _ContinueWatchingCard(
                title: 'Quantum Leap',
                episode: 'S3:E2',
                remaining: '38m Remaining',
                progress: 0.15,
                imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ... existing _FixedHeader and _NavTextButton classes ...
// (We keep them as is, omitted for brevity if they are outside the range, but for replace_file_content we must be careful)
// Actually I need to include them or ensure I don't delete them.
// I will target up to _HeroSection and update it to accept data.

class _HeroSection extends StatelessWidget {
  final Anime? anime; // Null means use fallback
  final AnimationController kenBurnsController;
  final bool isMobile;

  const _HeroSection({
    required this.anime,
    required this.kenBurnsController, 
    required this.isMobile
  });

  @override
  Widget build(BuildContext context) {
    // Fallback data
    final title = anime?.title ?? 'Eclipsed Horizons';
    final image = anime?.cover ?? anime?.image ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuBm6FcaJNwjo8edNQHUuOh9_IF9nqKLI66JvYo8TPEBzIcit_hcWbDvQ871WoqbygkFBcoXi6-qRRuA3PvHOb07sRcp6NHJwW2LpJb9NvKg7IJXSEWVKwOtTC71xtVNhqDfLuGkFbtEQV6DiIMnbDQHf0U3pZU8yIhkZM3lLxrTlNe5NhJuMBcGlr-UKPA6st7ImMUn7J3AFFipcIp5K2cceuNWJEMjHzCbHqhOfWJp8ekkvUecKpQckAceiJwDZ9Asy3mNGK05CMg';
    final description = anime?.description ?? 'In a future where sunlight is a currency, a rogue pilot discovers a planet that never sets. The fight for the last dawn begins now.';
    final badges = anime != null 
        ? [anime!.type ?? 'TV', if (anime!.rating != null) '${anime!.rating} ★'] 
        : ['NEW SEASON', 'SCI-FI • ADVENTURE • 2024'];

    return Stack(
      fit: StackFit.expand,
      children: [
        // Image Ken Burns
        AnimatedBuilder(
          animation: kenBurnsController,
          builder: (context, child) => Transform.scale(
            scale: 1.0 + (kenBurnsController.value * 0.1),
            child: child,
          ),
          child: CachedNetworkImage( // Use CachedNetworkImage
            imageUrl: image,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorWidget: (_, __, ___) => Container(color: Colors.grey[900]),
          ),
        ),

        // Gradients (HTML Lines 130-132)
        // 1. .hero-gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.6, 1.0],
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.4),
                Colors.black,
              ],
            ),
          ),
        ),
        // 2. from-black via-black/30 to-transparent (Left to Right)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black,
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // 3. from-black to transparent (Bottom to Top)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black,
                Colors.transparent,
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Content
        Positioned(
          left: 0,
          right: 0,
          bottom: 128, // pb-32 = 128px
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 32 : 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        anime != null ? (anime!.status ?? 'TRENDING').toUpperCase() : 'NEW SEASON',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2, // tracking-[0.2em]
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Container(
                      height: 16,
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.2),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    Text(
                      anime != null 
                          ? '${anime!.releaseYear ?? "2024"} • ${anime!.genres.take(2).join(" • ")}'.toUpperCase()
                          : 'SCI-FI • ADVENTURE • 2024',
                      style: AppTextStyles.labelSmall.copyWith(
                         fontSize: 12,
                         fontWeight: FontWeight.w300, 
                         color: Colors.grey[300],
                         letterSpacing: 1.0, // tracking-wide
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  title,
                  style: AppTextStyles.heroTitle.copyWith(
                    fontSize: isMobile ? 40 : 80, // Slightly reduced for long anime titles
                    fontWeight: FontWeight.w900, // font-black
                    height: 0.9, // leading-[0.9]
                    letterSpacing: -4, // tracking-tighter
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                 const SizedBox(height: 16),
                
                // Description
                SizedBox(
                  width: 672, // max-w-2xl
                  child: Text( // Strip HTML tags if any
                    description.replaceAll(RegExp(r'<[^>]*>'), ''),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: isMobile ? 16 : 18, 
                      fontWeight: FontWeight.w200, 
                      color: Colors.grey[300],
                      height: 1.625, // leading-relaxed
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                         if (anime != null) {
                            Navigator.of(context).pushNamed('/details', arguments: {
                              'id': anime!.id,
                              'title': anime!.title,
                            });
                         }
                      },
                      icon: const Icon(Icons.play_arrow, color: Colors.black, size: 24),
                      label: const Text('PLAY NOW'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: const StadiumBorder(),
                        textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                         elevation: 10,
                         shadowColor: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 24),
                    OutlinedButton.icon(
                      onPressed: () {
                         if (anime != null) {
                            Navigator.of(context).pushNamed('/details', arguments: {
                              'id': anime!.id,
                              'title': anime!.title,
                            });
                         }
                      },
                       icon: const Icon(Icons.info_outline, color: Colors.white, size: 24),
                      label: const Text('MORE INFO'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        foregroundColor: Colors.white,
                         side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: const StadiumBorder(),
                         textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w500, letterSpacing: 1.0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NavArrowButton extends StatelessWidget {
  final IconData icon;

  const _NavArrowButton(this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 40, // size-10
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _AnimeCard extends StatefulWidget {
  final String title;
  final List<String> genres;
  final String imageUrl;
  final Color shadowColor;
  final Color hoverShadowColor;
  final List<String> badges;
  final String description;
  final String meta;

  const _AnimeCard({
    required this.title,
    required this.genres,
    required this.imageUrl,
    required this.shadowColor,
    required this.hoverShadowColor,
    this.badges = const [],
    this.description = '',
    this.meta = '',
  });

  @override
  State<_AnimeCard> createState() => _AnimeCardState();
}

class _AnimeCardState extends State<_AnimeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // aspect-[2/3] w-[240px] md:w-[280px]
    final double width = 280;
    final double height = width * 1.5;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            width: width,
            height: height,
            transform: Matrix4.identity()
              ..scale(_isHovered ? 1.05 : 1.0)
              ..translate(0.0, _isHovered ? -16.0 : 0.0), // -translate-y-4
            decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(16), // rounded-2xl
               boxShadow: [
                 BoxShadow(
                   color: _isHovered ? widget.hoverShadowColor : widget.shadowColor,
                   blurRadius: _isHovered ? 120 : 100,
                   spreadRadius: _isHovered ? -5 : -10,
                   offset: Offset(0, _isHovered ? 50 : 40),
                 )
               ]
            ),
             child: ClipRRect(
               borderRadius: BorderRadius.circular(16),
               child: Stack(
                 fit: StackFit.expand,
                 children: [
                   // Image
                   CachedNetworkImage(
                     imageUrl: widget.imageUrl,
                     fit: BoxFit.cover,
                   ),
                   
                   // Gradient (HTML Line 174)
                   Container(
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         begin: Alignment.bottomCenter,
                         end: Alignment.topCenter,
                         colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                          Colors.transparent,
                         ],
                       ),
                     ),
                   ),

                   // Hover Overlay (HTML Line 175)
                   AnimatedOpacity(
                     opacity: _isHovered ? 1.0 : 0.0,
                     duration: const Duration(milliseconds: 300),
                     child: Container(
                       color: Colors.black.withValues(alpha: 0.4), // bg-black/40
                       child: GlassContainer(
                         blur: 20, // backdrop-blur-md
                         color: Colors.transparent,
                         border: const Border.fromBorderSide(BorderSide.none), // Let container handle it
                         borderRadius: BorderRadius.zero,
                         padding: const EdgeInsets.all(24),
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.end,
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             // Badges
                             Row(
                               children: widget.badges.map((b) => Container(
                                 margin: const EdgeInsets.only(right: 8),
                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                 decoration: BoxDecoration(
                                   color: Colors.white.withValues(alpha: 0.2),
                                   borderRadius: BorderRadius.circular(4),
                                 ),
                                 child: Text(b, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                               )).toList(),
                             ),
                             const SizedBox(height: 8),
                             // Description
                             Text(
                               widget.description,
                               maxLines: 4,
                               overflow: TextOverflow.ellipsis,
                               style: TextStyle(color: Colors.grey[200], fontSize: 12, height: 1.5, fontWeight: FontWeight.w300),
                             ),
                             const SizedBox(height: 16),
                             // Footer
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('DURATION', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, letterSpacing: 1.5)),
                                      Text(widget.meta, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    child: const Icon(Icons.play_arrow, size: 20, color: Colors.black),
                                  ),
                               ],
                             ),
                           ],
                         ),
                       ),
                     ),
                   ),
                 ],
               ),
             ),
          ),
          
          // Title Section (Below Card) HTML Lines 194-201
          const SizedBox(height: 24), // mt-6
          AnimatedOpacity(
            opacity: _isHovered ? 1.0 : 0.8,
            duration: const Duration(milliseconds: 300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                   widget.title,
                   style: AppTextStyles.titleMedium.copyWith(
                     fontSize: 20, // text-xl
                     fontWeight: FontWeight.w500,
                     letterSpacing: -0.5, // tracking-tight
                   ),
                 ),
                 const SizedBox(height: 8),
                 Row(
                   children: widget.genres.asMap().entries.map((entry) {
                     return Row(
                       children: [
                         Text(
                           entry.value,
                           style: AppTextStyles.bodySmall.copyWith(
                             color: AppColors.textSecondary,
                             fontWeight: FontWeight.w300,
                             fontSize: 12,
                           ),
                         ),
                         if (entry.key != widget.genres.length - 1)
                           Container(
                              width: 4, height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), shape: BoxShape.circle),
                           ),
                       ],
                     );
                   }).toList(),
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueWatchingCard extends StatefulWidget {
  final String title;
  final String episode;
  final String remaining;
  final double progress;
  final String imageUrl;

  const _ContinueWatchingCard({required this.title, required this.episode, required this.remaining, required this.progress, required this.imageUrl});

  @override
  State<_ContinueWatchingCard> createState() => _ContinueWatchingCardState();
}

class _ContinueWatchingCardState extends State<_ContinueWatchingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           AnimatedContainer(
             duration: const Duration(milliseconds: 500),
             curve: Curves.easeOut,
             width: 400, // w-[400px]
             height: 225, // aspect-video (16:9)
             transform: Matrix4.identity()
               ..scale(_isHovered ? 1.05 : 1.0)
               ..translate(0.0, _isHovered ? -8.0 : 0.0),
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(16),
               border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
               boxShadow: [
                 if (_isHovered)
                    // ambient-teal-hover
                    const BoxShadow(color: Color.fromRGBO(50, 255, 200, 0.8), blurRadius: 120, spreadRadius: -5, offset: Offset(0, 50))
                 else
                    const BoxShadow(color: Color.fromRGBO(40, 255, 180, 0.5), blurRadius: 100, spreadRadius: -10, offset: Offset(0, 40)),
               ],
             ),
             child: ClipRRect(
               borderRadius: BorderRadius.circular(16),
               child: Stack(
                 children: [
                    Positioned.fill(child: CachedNetworkImage(imageUrl: widget.imageUrl, fit: BoxFit.cover)),
                    Container(color: Colors.black.withValues(alpha: 0.2)), // dimming
                    
                    // Center Play Button
                    Center(
                       child: AnimatedOpacity(
                         opacity: _isHovered ? 1.0 : 0.0,
                         duration: const Duration(milliseconds: 300),
                         child: Container(
                           width: 56, height: 56,
                           decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.3), blurRadius: 30)]),
                           child: const Icon(Icons.play_arrow, color: Colors.black, size: 30),
                         ),
                       ),
                    ),

                    // Progress Bar
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        height: 4,
                        color: Colors.white.withValues(alpha: 0.1),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: widget.progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.8), blurRadius: 15)],
                            ),
                          ),
                        ),
                      ),
                    ),
                 ],
               ),
             ),
           ),
           const SizedBox(height: 24),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       Text(widget.episode, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                       Container(width: 1, height: 12, margin: const EdgeInsets.symmetric(horizontal: 12), color: Colors.white.withValues(alpha: 0.2)),
                       Text(widget.remaining, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                     ],
                   ),
                   const SizedBox(height: 4),
                   Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                 ],
               )
             ],
           )
        ],
      ),
    );
  }
}

class _FixedHeader extends StatelessWidget {
  final double scrollOffset;
  final bool isMobile;

  const _FixedHeader({required this.scrollOffset, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    // Backdrop blur triggers when scrolling
    final isScrolled = scrollOffset > 50;
    
    return GlassContainer(
      color: Colors.black.withValues(alpha: isScrolled ? 0.6 : 0.0),
      blur: isScrolled ? 20 : 0,
       border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: isScrolled ? 0.05 : 0.0),
            width: 1,
          ),
        ),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
      borderRadius: BorderRadius.zero,
      child: Row(
        children: [
          // Logo Section
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                 // Icon path from HTML: M39...
                 child: Icon(Icons.play_arrow, size: 16, color: Colors.white), 
              ),
              const SizedBox(width: 12),
              Text(
                'StreamFlow',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          if (!isMobile) ...[
            const SizedBox(width: 48),
            // Nav Items - wrapped  to prevent overflow
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NavTextButton('HOME', Icons.home, isActive: true),
                  const SizedBox(width: 32),
                  _NavTextButton('MOVIES', Icons.movie),
                  const SizedBox(width: 32),
                  _NavTextButton('SERIES', Icons.tv),
                  const SizedBox(width: 32),
                  _NavTextButton('LIST', Icons.bookmark),
                ],
              ),
            ),
            const SizedBox(width: 48),
          ] else 
             const Spacer(),

          // Right Section
          Row(
            children: [
               if (!isMobile) ...[
                // Search Input - Clickable
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/search'),
                  child: Container(
                    width: 200,
                     height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(999),
                    ),
                     padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text('Search...', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
               ],
               
               // Notification
               Stack(
                 children: [
                   Icon(Icons.notifications_none, color: AppColors.textSecondary, size: 22),
                    Positioned(
                      top: 0, right: 0,
                      child: Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.8), blurRadius: 8)]),
                      ),
                    )
                 ],
               ),
               const SizedBox(width: 24),
               
               // Profile - Clickable
               GestureDetector(
                 onTap: () => Navigator.of(context).pushNamed('/profile'),
                 child: Container(
                   width: 32, height: 32,
                   decoration: BoxDecoration(
                     shape: BoxShape.circle,
                     border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                     color: Colors.grey[800],
                     // For now, use a placeholder or the user's avatar if we had one
                   ),
                   child: ClipOval(
                      child: Container(color: Colors.grey[800], child: Icon(Icons.person, color: Colors.white, size: 20)),
                   ),
                 ),
               )
            ],
          ),
        ],
      ),
    );
  }
}

class _NavTextButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;

  const _NavTextButton(this.label, this.icon, {this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: isActive ? Colors.white : AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: isActive ? Colors.white : Colors.transparent)),
      ],
    );
  }
}
