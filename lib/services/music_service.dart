import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal() {
    _setupListeners();
    _setupAudioSession();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentMusic;
  Duration _currentDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;

  // 添加流控制器
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;
  Stream<bool> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged
      .map((state) => state == PlayerState.playing);

  // 添加获取当前状态的方法
  Duration get currentDuration => _currentDuration;
  Duration get currentPosition => _currentPosition;

  Future<void> _setupAudioSession() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // 设置音频会话，允许后台播放
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    } catch (e) {
      print('Error setting up audio session: $e');
    }
  }

  void _setupListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _currentDuration = duration;
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
    });

    // 添加生命周期监听
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == 'AppLifecycleState.paused') {
        // 应用进入后台
        if (_isPlaying) {
          // 如果正在播放，确保继续在后台播放
          await _audioPlayer.setReleaseMode(ReleaseMode.loop);
          await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
        }
      }
      return null;
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