import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

/// Serial thumbnail loader — processes one video at a time.
class _ThumbnailLoader {
  static final _ThumbnailLoader _instance = _ThumbnailLoader._();
  factory _ThumbnailLoader() => _instance;
  _ThumbnailLoader._();

  final _queue = <_MediaThumbnailState>[];
  bool _busy = false;

  void enqueue(_MediaThumbnailState state) {
    _queue.add(state);
    _process();
  }

  void _process() async {
    if (_busy || _queue.isEmpty) return;
    _busy = true;
    final state = _queue.removeAt(0);
    Player? player;
    try {
      player = Player();
      await player.open(
        Media('file:///${state.widget.filePath.replaceAll('\\', '/')}'),
      );
      // Wait for the decoder to produce the first frame
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final frame = await player.screenshot();
      if (frame != null && state.mounted) {
        state._setThumbnail(frame);
      }
    } catch (_) {
      // Silently skip — thumbnail will be captured on first hover instead
    } finally {
      player?.dispose();
      _busy = false;
      _process();
    }
  }
}

/// Displays a local image or video file.
///
/// For videos: shows a static thumbnail; starts playing on hover (desktop) or
/// tap (mobile).  Only one video plays at a time via [activeVideoNotifier].
class MediaThumbnail extends StatefulWidget {
  final String filePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool autoPlay;

  /// Shared notifier — when a new video starts, the previous one stops.
  static final activeVideoNotifier = ValueNotifier<String?>(null);

  const MediaThumbnail({
    super.key,
    required this.filePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.autoPlay = false,
  });

  @override
  State<MediaThumbnail> createState() => _MediaThumbnailState();
}

class _MediaThumbnailState extends State<MediaThumbnail> {
  Player? _player;
  VideoController? _videoController;
  MemoryImage? _thumbnail;
  bool _isVideo = false;
  bool _isPlaying = false;
  bool _initializing = false;
  bool _unsupported = false;
  bool _thumbnailRequested = false;

  @override
  void initState() {
    super.initState();
    final ext = widget.filePath.split('.').last.toLowerCase();
    _isVideo = ['mp4', 'mov', 'webm'].contains(ext);
    if (_isVideo) {
      if (widget.autoPlay) {
        _startPlay();
      } else {
        if (!_thumbnailRequested) {
          _thumbnailRequested = true;
          _ThumbnailLoader().enqueue(this);
        }
      }
    }
  }

  /// Called by [_ThumbnailLoader] when thumbnail is ready.
  void _setThumbnail(Uint8List bytes) {
    if (mounted) setState(() => _thumbnail = MemoryImage(bytes));
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _ensurePlayer() async {
    if (_player != null || _initializing || _unsupported) return;
    _initializing = true;
    try {
      final player = Player();
      _player = player;
      _videoController = VideoController(player);
      await player.open(
        Media('file:///${widget.filePath.replaceAll('\\', '/')}'),
      );
      await player.setPlaylistMode(PlaylistMode.loop);
      // Capture thumbnail if the eager loader didn't get one
      if (_thumbnail == null) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        final frame = await player.screenshot();
        if (frame != null && mounted) {
          setState(() => _thumbnail = MemoryImage(frame));
        }
      }
    } catch (_) {
      _unsupported = true;
      _player?.dispose();
      _player = null;
      _videoController = null;
    }
    if (mounted) setState(() => _initializing = false);
  }

  void _startPlay() {
    if (!_isVideo || _unsupported) return;
    _ensurePlayer().then((_) {
      if (!mounted || _player == null) return;
      MediaThumbnail.activeVideoNotifier.value = widget.filePath;
      _player!.play();
      setState(() => _isPlaying = true);
    });
  }

  void _stopPlay() {
    if (!_isVideo || _player == null) return;
    _player!.pause();
    setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    final file = File(widget.filePath);
    if (!file.existsSync()) {
      return _placeholder();
    }

    if (_isVideo) {
      final ready = _videoController != null;
      return MouseRegion(
        onEnter: widget.autoPlay ? null : (_) => _startPlay(),
        onExit: widget.autoPlay ? null : (_) => _stopPlay(),
        child: GestureDetector(
          onTap: widget.autoPlay
              ? null
              : () => _isPlaying ? _stopPlay() : _startPlay(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Show Video widget only while playing
              if (_isPlaying && ready)
                ClipRect(
                  child: Video(controller: _videoController!, fit: widget.fit),
                )
              // Show captured thumbnail when paused
              else if (_thumbnail != null)
                Image(
                  image: _thumbnail!,
                  fit: widget.fit,
                  width: widget.width,
                  height: widget.height,
                )
              else
                _placeholder(),
              if (!widget.autoPlay && !_isPlaying)
                Center(
                  child: Icon(
                    _unsupported ? Icons.videocam_off : Icons.play_circle_fill,
                    size: 40,
                    color: _unsupported ? Colors.white38 : Colors.white70,
                  ),
                ),
              if (_initializing)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      );
    }

    return Image.file(
      file,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (_, e, s) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
    );
  }
}
