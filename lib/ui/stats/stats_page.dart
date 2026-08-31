import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../db/database.dart';
import '../../services/hash_check_service.dart';
import '../../services/model_refresh_bus.dart';
import '../animation.dart';

/// Statistics dashboard showing aggregated model information.
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  bool _loading = true;
  int _dataVersion = 0;

  // Overview
  int _totalModels = 0;
  int _totalVersions = 0;
  double _totalSizeMB = 0;

  // Type distribution
  List<_NameCount> _typeDistribution = [];

  // Base model distribution
  List<_NameCount> _baseModelDistribution = [];

  // NSFW
  int _sfwCount = 0;
  int _nsfwCount = 0;

  // Top creators
  List<_NameCount> _topCreators = [];

  // Top tags
  List<_NameCount> _topTags = [];

  // Recent updates
  List<_RecentModel> _recentUpdates = [];

  // Hash check
  bool _hashChecking = false;
  HashCheckProgress? _hashProgress;

  @override
  void initState() {
    super.initState();
    _fetchAll();
    ModelRefreshBus.instance.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    ModelRefreshBus.instance.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    final db = (await CivitaiDatabase.instance).db;

    final results = await Future.wait([
      // Overview
      db.rawQuery('SELECT COUNT(*) as cnt FROM model'),
      db.rawQuery('SELECT COUNT(*) as cnt FROM model_version'),
      db.rawQuery(
        'SELECT COALESCE(SUM(size_kb), 0) as total FROM model_version_file',
      ),
      // Type distribution
      db.rawQuery('''
        SELECT mt.name, COUNT(*) as cnt
        FROM model m
        JOIN model_type mt ON mt.id = m.type_id
        GROUP BY mt.name
        ORDER BY cnt DESC
      '''),
      // Base model distribution
      db.rawQuery('''
        SELECT bm.name, COUNT(DISTINCT mv.model_id) as cnt
        FROM model_version mv
        JOIN base_model bm ON bm.id = mv.base_model_id
        GROUP BY bm.name
        ORDER BY cnt DESC
      '''),
      // NSFW counts
      db.rawQuery('SELECT nsfw, COUNT(*) as cnt FROM model GROUP BY nsfw'),
      // Top creators
      db.rawQuery('''
        SELECT c.username as name, COUNT(*) as cnt
        FROM model m
        JOIN creator c ON c.id = m.creator_id
        GROUP BY c.username
        ORDER BY cnt DESC
        LIMIT 10
      '''),
      // Top tags
      db.rawQuery('''
        SELECT t.name, COUNT(*) as cnt
        FROM model_tags mt
        JOIN tag t ON t.id = mt.tag_id
        GROUP BY t.name
        ORDER BY cnt DESC
        LIMIT 15
      '''),
      // Recent updates
      db.rawQuery('''
        SELECT m.id, m.name, m.updated_at, c.username
        FROM model m
        LEFT JOIN creator c ON c.id = m.creator_id
        ORDER BY m.updated_at DESC
        LIMIT 10
      '''),
    ]);

    if (!mounted) return;
    setState(() {
      _totalModels = (results[0].first['cnt'] as int?) ?? 0;
      _totalVersions = (results[1].first['cnt'] as int?) ?? 0;
      _totalSizeMB =
          ((results[2].first['total'] as num?)?.toDouble() ?? 0) /
          1024; // KB → MB

      _typeDistribution = _parseNameCount(results[3]);

      _baseModelDistribution = _parseNameCount(results[4]);

      for (final row in results[5]) {
        final nsfw = row['nsfw'] == 1;
        final cnt = row['cnt'] as int;
        if (nsfw) {
          _nsfwCount = cnt;
        } else {
          _sfwCount = cnt;
        }
      }

      _topCreators = _parseNameCount(results[6]);

      _topTags = _parseNameCount(results[7]);

      _recentUpdates = results[8].map((r) {
        return _RecentModel(
          id: r['id'] as int,
          name: r['name'] as String,
          username: r['username'] as String?,
          updatedAt: r['updated_at'] as String,
        );
      }).toList();

      _loading = false;
      _dataVersion++;
    });
  }

  List<_NameCount> _parseNameCount(dynamic result) {
    return (result as List).map((r) {
      return _NameCount(
        name: r['name'] as String? ?? 'Unknown',
        count: r['cnt'] as int,
      );
    }).toList();
  }

  Future<void> _startHashCheck() async {
    setState(() {
      _hashChecking = true;
      _hashProgress = null;
    });

    const service = HashCheckService();
    await for (final progress in service.checkAll()) {
      if (!mounted) return;
      setState(() => _hashProgress = progress);
    }

    if (mounted) setState(() => _hashChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: ShimmerGrid(crossAxisCount: 3)),
      );
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: RefreshIndicator(
        onRefresh: _fetchAll,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: ListView(
            key: ValueKey(_dataVersion),
            padding: const EdgeInsets.all(16),
            children: [
              _AnimatedSection(index: 0, child: _buildOverviewCards(theme)),
              const SizedBox(height: 24),
              _buildSectionTitle('Model Type Distribution'),
              const SizedBox(height: 8),
              _AnimatedSection(
                index: 1,
                child: _buildHorizontalBarChart(_typeDistribution, theme),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Base Model Distribution'),
              const SizedBox(height: 8),
              _AnimatedSection(
                index: 2,
                child: _buildPieChart(_baseModelDistribution, theme),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('NSFW Ratio'),
              const SizedBox(height: 8),
              _AnimatedSection(index: 3, child: _buildNsfwPieChart(theme)),
              const SizedBox(height: 24),
              _buildSectionTitle('Top Creators'),
              const SizedBox(height: 8),
              _AnimatedSection(
                index: 4,
                child: _buildRankedList(_topCreators, theme),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Top Tags'),
              const SizedBox(height: 8),
              _AnimatedSection(
                index: 5,
                child: _buildHorizontalBarChart(_topTags, theme),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Recent Updates'),
              const SizedBox(height: 8),
              _AnimatedSection(index: 6, child: _buildRecentUpdates(theme)),
              const SizedBox(height: 24),
              _buildSectionTitle('File Integrity'),
              const SizedBox(height: 8),
              _AnimatedSection(index: 7, child: _buildHashCheckSection(theme)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Hash Check
  // ---------------------------------------------------------------------------
  Widget _buildHashCheckSection(ThemeData theme) {
    final progress = _hashProgress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Idle state: show button
            if (!_hashChecking && progress == null) ...[
              Text(
                'Verify downloaded model files against CivitAI hashes.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _startHashCheck,
                icon: const Icon(Icons.verified_user, size: 20),
                label: const Text('Check Integrity'),
              ),
            ],

            // Checking: progress bar
            if (_hashChecking && progress != null) ...[
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Checking ${progress.checked} / ${progress.total}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.total > 0
                      ? progress.checked / progress.total
                      : 0,
                  minHeight: 6,
                ),
              ),
              if (progress.currentFile != null) ...[
                const SizedBox(height: 4),
                Text(
                  progress.currentFile!,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],

            // Done: summary + details
            if (!_hashChecking && progress != null) ...[
              // Summary row
              Row(
                children: [
                  _HashStatusChip(
                    icon: Icons.check_circle,
                    label: '${progress.passed} passed',
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  _HashStatusChip(
                    icon: Icons.error,
                    label: '${progress.mismatched} mismatch',
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  _HashStatusChip(
                    icon: Icons.help_outline,
                    label: '${progress.skipped} skipped',
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _startHashCheck,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Re-check'),
                  ),
                ],
              ),
              // Failed details
              if (progress.mismatched > 0 || progress.missing > 0) ...[
                const Divider(height: 24),
                ...progress.results
                    .where(
                      (r) =>
                          r.status == HashCheckStatus.mismatch ||
                          r.status == HashCheckStatus.missing,
                    )
                    .map((r) => _buildFailedRow(r, theme)),
              ],
              if (progress.mismatched == 0 &&
                  progress.missing == 0 &&
                  progress.passed > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.verified,
                      color: theme.colorScheme.tertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'All ${progress.passed} files verified successfully',
                      style: TextStyle(color: theme.colorScheme.tertiary),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFailedRow(HashCheckFileResult r, ThemeData theme) {
    final icon = r.status == HashCheckStatus.missing
        ? Icons.warning_amber
        : Icons.close;
    final color = r.status == HashCheckStatus.missing
        ? theme.colorScheme.error.withValues(alpha: 0.7)
        : theme.colorScheme.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          r.fileName,
          style: const TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          r.status == HashCheckStatus.missing
              ? 'File not found on disk'
              : 'Hash mismatch (${r.algorithm ?? 'SHA256'})',
          style: TextStyle(fontSize: 11, color: color),
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 16, bottom: 8),
        children: [
          if (r.status == HashCheckStatus.mismatch) ...[
            _detailRow('Expected', r.expectedHash ?? '', theme),
            _detailRow('Actual', r.actualHash ?? '', theme),
          ],
          _detailRow('Size', r.sizeFormatted, theme),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildOverviewCards(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _OverviewCard(
            icon: Icons.model_training,
            label: 'Models',
            value: _totalModels.toString(),
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OverviewCard(
            icon: Icons.layers,
            label: 'Versions',
            value: _totalVersions.toString(),
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _OverviewCard(
            icon: Icons.storage,
            label: 'Size',
            value: _formatSize(_totalSizeMB),
            color: theme.colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  String _formatSize(double mb) {
    if (mb >= 1024) return '${(mb / 1024).toStringAsFixed(1)} GB';
    return '${mb.toStringAsFixed(0)} MB';
  }

  // ---------------------------------------------------------------------------
  // Horizontal Bar Chart – native Flutter rows (no overlap)
  // ---------------------------------------------------------------------------
  Widget _buildHorizontalBarChart(List<_NameCount> data, ThemeData theme) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No data')),
        ),
      );
    }

    // Take top 12 for readability
    final items = data.length > 12 ? data.sublist(0, 12) : data;
    final maxCount = items.first.count.toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: items.asMap().entries.map((e) {
            final ratio = maxCount > 0 ? e.value.count / maxCount : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  // Label
                  SizedBox(
                    width: 100,
                    child: Text(
                      e.value.name,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bar
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 18,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          theme.colorScheme.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Count
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${e.value.count}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pie Chart (fl_chart)
  // ---------------------------------------------------------------------------
  Widget _buildPieChart(List<_NameCount> data, ThemeData theme) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No data')),
        ),
      );
    }

    final items = data.length > 8 ? data.sublist(0, 8) : data;
    final colors = _generateColors(items.length, theme.colorScheme);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: items.asMap().entries.map((e) {
                    return PieChartSectionData(
                      value: e.value.count.toDouble(),
                      color: colors[e.key],
                      title: '${e.value.count}',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: items.asMap().entries.map((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[e.key],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${e.value.name} (${e.value.count})',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // NSFW Ratio – stacked bar (clearer than pie)
  // ---------------------------------------------------------------------------
  Widget _buildNsfwPieChart(ThemeData theme) {
    final total = _sfwCount + _nsfwCount;
    if (total == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No data')),
        ),
      );
    }

    final sfwRatio = _sfwCount / total;
    final nsfwRatio = _nsfwCount / total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Stacked ratio bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 32,
                child: Row(
                  children: [
                    if (sfwRatio > 0)
                      Expanded(
                        flex: (_sfwCount * 1000).round(),
                        child: Container(color: theme.colorScheme.tertiary),
                      ),
                    if (nsfwRatio > 0)
                      Expanded(
                        flex: (_nsfwCount * 1000).round(),
                        child: Container(color: theme.colorScheme.error),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend + percentages
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(theme.colorScheme.tertiary, 'SFW'),
                const SizedBox(width: 16),
                _legendDot(theme.colorScheme.error, 'NSFW'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'SFW ${(sfwRatio * 100).toStringAsFixed(1)}%  ·  NSFW ${(nsfwRatio * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_sfwCount SFW  /  $_nsfwCount NSFW  ($total total)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Ranked List (Top Creators)
  // ---------------------------------------------------------------------------
  Widget _buildRankedList(List<_NameCount> data, ThemeData theme) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No data')),
        ),
      );
    }

    return Card(
      child: Column(
        children: data.asMap().entries.map((e) {
          final rank = e.key + 1;
          final item = e.value;
          final maxCount = data.first.count.toDouble();
          final ratio = item.count / maxCount;

          Color rankColor;
          if (rank == 1) {
            rankColor = Colors.amber.shade700;
          } else if (rank == 2) {
            rankColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);
          } else if (rank == 3) {
            rankColor = theme.colorScheme.tertiary.withValues(alpha: 0.7);
          } else {
            rankColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);
          }

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: rankColor.withValues(alpha: 0.2),
              radius: 16,
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(item.name, style: const TextStyle(fontSize: 14)),
                ),
                Text(
                  '${item.count}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 4,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Recent Updates
  // ---------------------------------------------------------------------------
  Widget _buildRecentUpdates(ThemeData theme) {
    if (_recentUpdates.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No data')),
        ),
      );
    }

    return Card(
      child: Column(
        children: _recentUpdates.map((m) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.update,
                size: 18,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(m.name, style: const TextStyle(fontSize: 14)),
            subtitle: Text(
              m.username != null
                  ? 'by ${m.username}  ·  ${_formatDate(m.updatedAt)}'
                  : _formatDate(m.updatedAt),
              style: const TextStyle(fontSize: 12),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  // ---------------------------------------------------------------------------
  // Section Title
  // ---------------------------------------------------------------------------
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Color generation
  // ---------------------------------------------------------------------------
  List<Color> _generateColors(int count, ColorScheme scheme) {
    // Derive chart palette from ColorScheme tones.
    final base = [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      scheme.error,
      scheme.primaryContainer,
      scheme.secondaryContainer,
      scheme.tertiaryContainer,
      scheme.errorContainer,
    ].map((c) => c is MaterialColor ? c : c).toList();
    if (count <= base.length) return base.sublist(0, count);
    return List.generate(count, (i) {
      final hue = (i * 360 / count) % 360;
      return HSLColor.fromAHSL(0.7, hue.toDouble(), 0.6, 0.6).toColor();
    });
  }
}

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------
class _NameCount {
  final String name;
  final int count;
  const _NameCount({required this.name, required this.count});
}

class _RecentModel {
  final int id;
  final String name;
  final String? username;
  final String updatedAt;
  const _RecentModel({
    required this.id,
    required this.name,
    this.username,
    required this.updatedAt,
  });
}

// ---------------------------------------------------------------------------
// Overview Card
// ---------------------------------------------------------------------------
class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _OverviewCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hash Status Chip
// ---------------------------------------------------------------------------
class _HashStatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HashStatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated section wrapper
// ---------------------------------------------------------------------------

/// Wraps a section card with a staggered jelly entrance.
class _AnimatedSection extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedSection({required this.index, required this.child});

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.of(context).disableAnimations;
    if (reduced) return widget.child;

    return AnimatedOpacity(
      opacity: _show ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _show ? Offset.zero : const Offset(0, 0.06),
        duration: const Duration(milliseconds: 350),
        curve: jellyCurve,
        child: widget.child,
      ),
    );
  }
}
