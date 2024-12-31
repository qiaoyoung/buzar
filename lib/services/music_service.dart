import 'package:audioplayers/audioplayers.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal() {
    _setupListeners();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentMusic;

  // 添加流控制器
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;
  Stream<bool> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged
      .map((state) => state == PlayerState.playing);

  void _setupListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
    });
  }

  Future<void> playFromAsset(String assetPath) async {
    if (_currentMusic == assetPath && _isPlaying) {
      return;
    }
    
    if (_isPlaying) {
      await pause();
    }

    try {
      final path = assetPath.replaceFirst('assets/', '');
      await _audioPlayer.play(AssetSource(path));
      _isPlaying = true;
      _currentMusic = assetPath;
    } catch (e) {
      print('Error playing music: $e');
      _isPlaying = false;
      _currentMusic = null;
      rethrow;
    }
  }

  Future<void> pause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _isPlaying = false;
    }
  }

  Future<void> resume() async {
    if (!_isPlaying && _currentMusic != null) {
      await _audioPlayer.resume();
      _isPlaying = true;
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _currentMusic = null;
  }

  bool get isPlaying => _isPlaying;
  String? get currentMusic => _currentMusic;

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
} 