import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import '../services/music_service.dart';

class MusicListScreen extends StatefulWidget {
  const MusicListScreen({super.key});

  @override
  State<MusicListScreen> createState() => _MusicListScreenState();
}

class _MusicListScreenState extends State<MusicListScreen> {
  final MusicService _musicService = MusicService();
  List<String> _musicFiles = [];
  String? _currentPlayingMusic;
  bool _isLoading = true;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _currentPlayingMusic = _musicService.currentMusic;
    _isPlaying = _musicService.isPlaying;
    _duration = _musicService.currentDuration;
    _position = _musicService.currentPosition;
    
    _loadMusicFiles();
    _setupMusicListeners();
  }

  void _setupMusicListeners() {
    _subscriptions.add(
      _musicService.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() => _duration = duration);
        }
      })
    );

    _subscriptions.add(
      _musicService.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() => _position = position);
        }
      })
    );

    _subscriptions.add(
      _musicService.onPlayerStateChanged.listen((playing) {
        if (mounted) {
          setState(() {
            _isPlaying = playing;
            if (!playing && _currentPlayingMusic != null) {
              _currentPlayingMusic = null;
              _duration = Duration.zero;
              _position = Duration.zero;
            }
          });
        }
      })
    );
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _loadMusicFiles() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      final musicFiles = manifestMap.keys
          .where((String key) => key.startsWith('assets/musics/'))
          .toList();

      if (mounted) {
        setState(() {
          _musicFiles = musicFiles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load music files')),
        );
      }
    }
  }

  String _getMusicName(String path) {
    final fileName = path.split('/').last;
    return fileName.split('.').first;
  }

  Future<void> _playMusic(String musicPath) async {
    if (!mounted) return;
    
    if (_currentPlayingMusic == musicPath && _isPlaying) {
      await _musicService.pause();
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    } else {
      await _musicService.playFromAsset(musicPath);
      if (mounted) {
        setState(() {
          _currentPlayingMusic = musicPath;
          _isPlaying = true;
        });
      }
    }
  }

  Widget _buildMusicTile(String musicPath) {
    final isCurrentMusic = _currentPlayingMusic == musicPath;
    final isPlaying = isCurrentMusic && _isPlaying;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: isCurrentMusic ? 2 : 1,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isCurrentMusic ? LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Theme.of(context).primaryColor,
            ),
          ),
          title: Text(
            _getMusicName(musicPath),
            style: TextStyle(
              fontWeight: isCurrentMusic ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: isCurrentMusic ? Text(
            'Now Playing',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ) : null,
          onTap: () => _playMusic(musicPath),
        ),
      ),
    );
  }

  Widget _buildBottomPlayer() {
    if (_currentPlayingMusic == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 6,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 14,
              ),
              activeTrackColor: Theme.of(context).primaryColor,
              inactiveTrackColor: Theme.of(context).primaryColor.withOpacity(0.2),
              thumbColor: Theme.of(context).primaryColor,
              overlayColor: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Slider(
              value: _position.inSeconds.toDouble(),
              min: 0,
              max: _duration.inSeconds.toDouble(),
              onChanged: (value) {
                final position = Duration(seconds: value.toInt());
                _musicService.seek(position);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getMusicName(_currentPlayingMusic!),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10_rounded),
                onPressed: () {
                  final newPosition = _position - const Duration(seconds: 10);
                  _musicService.seek(newPosition);
                },
              ),
              IconButton(
                iconSize: 48,
                icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  if (_isPlaying) {
                    _musicService.pause();
                  } else {
                    _musicService.resume();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.forward_10_rounded),
                onPressed: () {
                  final newPosition = _position + const Duration(seconds: 10);
                  _musicService.seek(newPosition);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Background Music'),
        ),
        body: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _musicFiles.isEmpty
                      ? const Center(child: Text('No music files found'))
                      : ListView.builder(
                          itemCount: _musicFiles.length,
                          itemBuilder: (context, index) {
                            final musicPath = _musicFiles[index];
                            return _buildMusicTile(musicPath);
                          },
                        ),
            ),
            _buildBottomPlayer(),
          ],
        ),
      ),
    );
  }
} 