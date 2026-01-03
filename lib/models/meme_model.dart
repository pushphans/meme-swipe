class Meme {
  final String imageUrl;
  final String title;
  final int upvotes;
  final String subreddit;
  final String author;

  Meme({
    required this.imageUrl,
    required this.title,
    required this.upvotes,
    required this.subreddit,
    required this.author,
  });

  factory Meme.fromJson(Map<String, dynamic> json) {
    return Meme(
      imageUrl: json['url']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Meme',
      upvotes: json['ups'] ?? 0,
      subreddit: json['subreddit']?.toString() ?? 'memes',
      author: json['author']?.toString() ?? 'Anonymous',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': imageUrl,
      'title': title,
      'ups': upvotes,
      'subreddit': subreddit,
      'author': author,
    };
  }

  static bool isValidPost(Map<String, dynamic> data) {
    try {
      final postHint = data['post_hint']?.toString() ?? '';
      final isImage = postHint == 'image';

      final over18 = data['over_18'];
      final isNotNSFW = over18 == null || over18 == false;

      final isVideo = data['is_video'];
      final isNotVideo = isVideo == null || isVideo == false;

      final url = data['url']?.toString() ?? '';
      final hasValidUrl =
          url.isNotEmpty &&
          url.startsWith('http') &&
          (url.contains('.jpg') ||
              url.contains('.png') ||
              url.contains('.jpeg'));

      final isGallery = data['is_gallery'];
      final isNotGallery = isGallery == null || isGallery == false;

      // Stickied posts skip (announcements)
      final isStickied = data['stickied'];
      final isNotStickied = isStickied == null || isStickied == false;

      return isImage &&
          isNotNSFW &&
          isNotVideo &&
          hasValidUrl &&
          isNotGallery &&
          isNotStickied;
    } catch (e) {
      return false;
    }
  }
}
