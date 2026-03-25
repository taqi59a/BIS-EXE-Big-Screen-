import 'dart:io';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../constants.dart';

/// Simple background music service — loops a single track indefinitely.
class MusicService {
  MusicService._();
  static final MusicService instance = MusicService._();

  final AudioPlayer _player = AudioPlayer();

  bool _isInitialised = false;
  List<MusicTrack> _tracks = [];
  int _currentIndex = 0;
  bool _enabled = true;

  bool get isPlaying => _player.playing;
  bool get enabled => _enabled;
  List<MusicTrack> get tracks => List.unmodifiable(_tracks);
  MusicTrack? get currentTrack =>
      _tracks.isNotEmpty ? _tracks[_currentIndex % _tracks.length] : null;

  /// Initialise — discover mp3 files from assets and external storage.
  Future<void> init() async {
    if (_isInitialised) return;
    _isInitialised = true;
    _tracks = await _discoverAllTracks();
  }

  /// Discover tracks from bundled assets and external storage.
  Future<List<MusicTrack>> _discoverAllTracks() async {
    final List<MusicTrack> all = [];

    // 1. Bundled asset tracks
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final RegExp musicPattern =
          RegExp(r'"(assets/music/[^"]+\.(mp3|m4a|wav|ogg))"');
      for (final match in musicPattern.allMatches(manifestContent)) {
        final assetPath = match.group(1)!;
        final name = Uri.decodeFull(
            assetPath.split('/').last.replaceAll(RegExp(r'\.(mp3|m4a|wav|ogg)$'), ''));
        all.add(MusicTrack(name: name, path: assetPath, source: TrackSource.asset));
      }
    } catch (_) {}

    // 2. External storage tracks
    try {
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final root = extDir.path.split('Android').first;
        final musicDir = Directory('$root${AppConstants.musicSubDir}');
        if (await musicDir.exists()) {
          final files = musicDir
              .listSync()
              .whereType<File>()
              .where((f) => RegExp(r'\.(mp3|m4a|wav|ogg)$', caseSensitive: false)
                  .hasMatch(f.path))
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));
          for (final f in files) {
            final name = f.path
                .split('/')
                .last
                .replaceAll(RegExp(r'\.(mp3|m4a|wav|ogg)$', caseSensitive: false), '');
            all.add(MusicTrack(name: name, path: f.path, source: TrackSource.file));
          }
        } else {
          await musicDir.create(recursive: true);
        }
      }
    } catch (_) {}

    return all;
  }

  /// Re-scan music files.
  Future<void> rescan() async {
    _tracks = await _discoverAllTracks();
    _currentIndex = 0;
  }

  /// Start playing — loops forever.
  Future<void> play() async {
    if (_tracks.isEmpty || !_enabled) return;
    try {
      final track = _tracks[_currentIndex % _tracks.length];
      if (track.source == TrackSource.asset) {
        await _player.setAsset(track.path);
      } else {
        await _player.setFilePath(track.path);
      }
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(0.7);
      await _player.play();
    } catch (e) {
      // If first track fails, try others
      if (_tracks.length > 1) {
        _currentIndex = (_currentIndex + 1) % _tracks.length;
        await play();
      }
    }
  }

  /// Skip to next track.
  Future<void> skipNext() async {
    if (_tracks.isEmpty) return;
    await _player.stop();
    _currentIndex = (_currentIndex + 1) % _tracks.length;
    await play();
  }

  /// Pause playback.
  Future<void> pause() async {
    await _player.pause();
  }

  /// Stop playback completely.
  Future<void> stop() async {
    await _player.stop();
  }

  void setEnabled(bool value) {
    _enabled = value;
    if (!_enabled) {
      stop();
    } else {
      play();
    }
  }

  /// Remove a track from the playlist.
  void removeTrack(int index) {
    if (index < 0 || index >= _tracks.length) return;
    _tracks.removeAt(index);
    if (_currentIndex >= _tracks.length) _currentIndex = 0;
  }

  void dispose() {
    _player.dispose();
  }
}

/// Represents a music track.
class MusicTrack {
  final String name;
  final String path;
  final TrackSource source;

  const MusicTrack({
    required this.name,
    required this.path,
    required this.source,
  });
}

enum TrackSource { asset, file }
