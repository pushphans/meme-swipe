import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static final Random _random = Random();

  // 🔢 Total sounds (1 to 22)
  static const int totalSounds = 22;

  // Initialize
  static Future<void> initialize() async {
    // Use `release` mode for short sound effects, not `loop`
    await _audioPlayer.setReleaseMode(ReleaseMode.release);
    await _audioPlayer.setVolume(0.6);
    print('🔊 Audio service initialized');
  }

  // Play random sound
  static Future<void> playRandomSound() async {
    try {
      // Random number generate (1 to 10)
      final randomNumber = _random.nextInt(totalSounds) + 1;
      final soundFile = 'sounds/sound$randomNumber.mp3';

      print('🔊 Playing: sound$randomNumber.mp3');

      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(soundFile));
    } catch (e) {
      print('❌ Sound error: $e');
    }
  }

  // Stop sound
  static Future<void> stopSound() async {
    await _audioPlayer.stop();
  }

  // Dispose
  static Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
