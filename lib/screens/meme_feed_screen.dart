import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_swiper/card_swiper.dart';
import '../providers/meme_provider.dart';
import '../widgets/meme_card.dart';
import '../utils/constants.dart';
import '../services/audio_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../models/meme_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/native_ad_widget.dart';

class MemeFeedScreen extends StatefulWidget {
  const MemeFeedScreen({super.key});

  @override
  State<MemeFeedScreen> createState() => _MemeFeedScreenState();
}

class _MemeFeedScreenState extends State<MemeFeedScreen> {
  bool _showHelper = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemeProvider>().loadMemes().then((_) {
        if (mounted &&
            context.read<MemeProvider>().memes.isNotEmpty &&
            context.read<MemeProvider>().memes[0] is Meme) {
          AudioService.playRandomSound();
        }
      });

      // Helper hide timer
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showHelper = false;
          });
        }
      });
    });
  }

  void _precacheNextImages(int currentIndex) {
    if (!mounted) return;

    final provider = context.read<MemeProvider>();
    if (provider.memes.isEmpty) return;

    // Pre-cache the next 3 images to reduce loading times
    for (int i = 1; i <= 3; i++) {
      final nextIndex = currentIndex + i;
      if (nextIndex < provider.memes.length) {
        final item = provider.memes[nextIndex];
        if (item is Meme) {
          final imageUrl = item.imageUrl;
          if (imageUrl.isNotEmpty) {
            precacheImage(CachedNetworkImageProvider(imageUrl), context);
            print('Pre-caching image for index $nextIndex');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<MemeProvider>(
                builder: (context, provider, child) {
                  // Loading state
                  if (provider.isLoading && provider.memes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppConstants.primaryColor,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Loading fresh memes...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Error state
                  if ((provider.hasError || provider.memes.isEmpty) &&
                      !provider.isLoading) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_off_rounded,
                              size: 100,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              provider.errorMessage.isNotEmpty
                                  ? provider.errorMessage
                                  : 'Oops! Something went wrong',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Make sure you\'re connected to the internet',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () => provider.loadMemes(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Memes available
                  if (provider.memes.isNotEmpty) {
                    return Stack(
                      children: [
                        // Swiper
                        Swiper(
                          itemCount: provider.memes.length,
                          itemBuilder: (context, index) {
                            final item = provider.memes[index];
                            if (item is Meme) {
                              return MemeCard(meme: item);
                            } else {
                              // This is the ad placeholder
                              return const NativeAdWidget();
                            }
                          },
                          loop: false,
                          scrollDirection: Axis.vertical,
                          onIndexChanged: (index) {
                            // Pre-cache images for the next few swipes
                            _precacheNextImages(index);

                            // Helper hide
                            if (_showHelper) {
                              setState(() {
                                _showHelper = false;
                              });
                            }

                            final item = provider.memes[index];
                            if (item is Meme) {
                              print(
                                'Viewing meme ${index + 1}/${provider.memes.length}',
                              );

                              // Play random sound only for memes
                              AudioService.playRandomSound();
                            } else {
                              print('Viewing ad at index $index');
                              AudioService.stopSound();
                            }
                          },
                        ),

                        // Top Bar
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Logo
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppConstants.primaryColor,
                                            AppConstants.primaryColor
                                                .withOpacity(0.7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppConstants.primaryColor
                                                .withOpacity(0.4),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.emoji_emotions,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'MemeSwipe',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),

                                // Refresh Button
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      provider.refresh();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Refreshing memes...',
                                          ),
                                          backgroundColor:
                                              AppConstants.primaryColor,
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 1),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Swipe Helper
                        if (_showHelper)
                          Positioned(
                            bottom: 100,
                            left: 0,
                            right: 0,
                            child: AnimatedOpacity(
                              opacity: _showHelper ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 500),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppConstants.primaryColor.withOpacity(
                                          0.9,
                                        ),
                                        AppConstants.primaryColor.withOpacity(
                                          0.7,
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppConstants.primaryColor
                                            .withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.swipe_up_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Swipe up for next meme',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    AudioService.stopSound();
    super.dispose();
  }
}
