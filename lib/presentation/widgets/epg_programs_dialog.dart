import 'package:flutter/material.dart';
import 'package:iptvca/core/di/injection_container.dart';
import 'package:iptvca/data/datasources/remote/epg_datasource.dart';
import 'package:iptvca/domain/entities/channel.dart';

class EpgProgramsDialog extends StatefulWidget {
  const EpgProgramsDialog({
    super.key,
    required this.channel,
  });
  final Channel channel;

  @override
  State<EpgProgramsDialog> createState() => _EpgProgramsDialogState();
}

class _EpgProgramsDialogState extends State<EpgProgramsDialog> {
  late final EpgDataSource _epgDataSource;
  late final ScrollController _scrollController;
  final Map<int, GlobalKey> _programKeys = {};
  Map<String, dynamic>? _epgData;
  bool _isLoading = false;
  String? _errorMessage;
  double _progress = 0.0;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _epgDataSource = EpgDataSource(
      InjectionContainer.instance.storage,
      InjectionContainer.instance.cacheService,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded && !_isLoading && _epgData == null) {
      _hasLoaded = true;
      _loadEpg();
    }
    if (_epgData != null && !_isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _scrollController.hasClients) {
            _scrollToCurrentTime();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadEpg({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _progress = 0.0;
    });
    try {
      final epgData = await _epgDataSource.fetchEpg(
        forceRefresh: forceRefresh,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _progress = progress;
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _epgData = epgData;
          _isLoading = false;
          _progress = 1.0;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) {
              _scrollToCurrentTime();
            }
          });
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getChannelPrograms() {
    if (_epgData == null) return [];
    final channelsData = _epgData!['channels'];
    if (channelsData is! Map<String, dynamic>) return [];
    final channels = channelsData;
    List<dynamic>? programs;
    if (widget.channel.tvgId != null && widget.channel.tvgId!.isNotEmpty) {
      final tvgPrograms = channels[widget.channel.tvgId];
      if (tvgPrograms is List<dynamic>) {
        programs = tvgPrograms;
      }
    }
    if (programs == null && widget.channel.name.isNotEmpty) {
      final namePrograms = channels[widget.channel.name];
      if (namePrograms is List<dynamic>) {
        programs = namePrograms;
      }
    }
    if (programs == null) {
      final channelNameLower = widget.channel.name.toLowerCase();
      for (final entry in channels.entries) {
        if (entry.key.toLowerCase().contains(channelNameLower) ||
            channelNameLower.contains(entry.key.toLowerCase())) {
          if (entry.value is List<dynamic>) {
            programs = entry.value as List<dynamic>;
            break;
          }
        }
      }
    }
    if (programs == null) return [];
    return programs
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Map<String, dynamic>? _getCurrentProgram() {
    final programs = _getChannelPrograms();
    final now = DateTime.now();
    for (final program in programs) {
      final startTime = DateTime.parse(program['startTime'] as String);
      final endTimeStr = program['endTime'] as String?;
      if (endTimeStr != null) {
        final endTime = DateTime.parse(endTimeStr);
        if (now.isAfter(startTime) && now.isBefore(endTime)) {
          return program;
        }
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _getTodayPrograms() {
    final programs = _getChannelPrograms();
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    return programs
        .where((program) {
          final startTime = DateTime.parse(program['startTime'] as String);
          return startTime.isAfter(todayStart) && startTime.isBefore(todayEnd);
        })
        .toList();
  }

  void _scrollToCurrentTime() {
    if (!_scrollController.hasClients) return;
    final now = DateTime.now();
    final programs = _getTodayPrograms();
    if (programs.isEmpty) return;
    final currentProgram = _getCurrentProgram();
    int? targetIndex;
    for (int i = 0; i < programs.length; i++) {
      final program = programs[i];
      final startTime = DateTime.parse(program['startTime'] as String);
      final endTimeStr = program['endTime'] as String?;
      if (endTimeStr != null) {
        final endTime = DateTime.parse(endTimeStr);
        if (now.isAfter(startTime) && now.isBefore(endTime)) {
          targetIndex = i;
          break;
        }
      } else if (now.isAfter(startTime)) {
        if (i < programs.length - 1) {
          final nextStartTime = DateTime.parse(programs[i + 1]['startTime'] as String);
          if (now.isBefore(nextStartTime)) {
            targetIndex = i;
            break;
          }
        } else {
          targetIndex = i;
          break;
        }
      }
    }
    if (targetIndex == null) {
      for (int i = 0; i < programs.length; i++) {
        final startTime = DateTime.parse(programs[i]['startTime'] as String);
        if (now.isBefore(startTime)) {
          targetIndex = i;
          break;
        }
      }
    }
    if (targetIndex == null && programs.isNotEmpty) {
      targetIndex = 0;
    }
    if (targetIndex != null) {
      final index = targetIndex;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted || !_scrollController.hasClients) return;
        if (_programKeys.containsKey(index)) {
          final key = _programKeys[index];
          if (key?.currentContext != null) {
            Scrollable.ensureVisible(
              key!.currentContext!,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              alignment: 0.1,
            );
          } else {
            _scrollToIndexFallback(index, currentProgram);
          }
        } else {
          _scrollToIndexFallback(index, currentProgram);
        }
      });
    }
  }

  void _scrollToIndexFallback(int targetIndex, Map<String, dynamic>? currentProgram) {
    if (!_scrollController.hasClients) return;
    final programs = _getTodayPrograms();
    if (programs.isEmpty || targetIndex >= programs.length) return;
    final estimatedCurrentProgramHeight = currentProgram != null ? 200.0 : 0.0;
    final estimatedItemHeight = 80.0;
    final padding = 16.0;
    final sectionHeaderHeight = 40.0;
    final dividerHeight = 16.0;
    final scrollPosition = estimatedCurrentProgramHeight +
        sectionHeaderHeight +
        dividerHeight +
        padding +
        (targetIndex * estimatedItemHeight);
    final maxScroll = _scrollController.position.maxScrollExtent;
    final targetScroll = scrollPosition.clamp(0.0, maxScroll);
    _scrollController.animateTo(
      targetScroll,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 500,
      child: Column(
        children: [
          AppBar(
            title: Text('Телепрограмма: ${widget.channel.name}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () async {
                  await _loadEpg(forceRefresh: true);
                },
                tooltip: 'Обновить',
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Закрыть',
              ),
            ],
          ),
            if (_isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _progress > 0 ? _progress : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Загрузка телепрограммы...',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (_progress > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else if (_errorMessage != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Ошибка загрузки телепрограммы',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _errorMessage!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadEpg,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: _buildProgramsList(),
              ),
        ],
      ),
    );
  }

  Widget _buildProgramsList() {
    final currentProgram = _getCurrentProgram();
    final todayPrograms = _getTodayPrograms();
    if (todayPrograms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.tv_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Телепрограмма недоступна',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Данные EPG для этого канала не найдены',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        if (currentProgram != null) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildCurrentProgramCard(currentProgram),
          ),
          const Divider(height: 1),
        ],
        Expanded(
          child: _buildProgramsScrollList(todayPrograms),
        ),
      ],
    );
  }

  Widget _buildProgramsScrollList(List<Map<String, dynamic>> todayPrograms) {
    _programKeys.clear();
    final children = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
        child: Text(
          'Программа на сегодня',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    ];
    for (int i = 0; i < todayPrograms.length; i++) {
      final program = todayPrograms[i];
      final key = GlobalKey();
      _programKeys[i] = key;
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: KeyedSubtree(
            key: key,
            child: _buildProgramCard(program),
          ),
        ),
      );
    }
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 16.0),
      children: children,
    );
  }

  Widget _buildCurrentProgramCard(Map<String, dynamic> program) {
    final title = program['title'] as String? ?? 'Нет названия';
    final description = program['description'] as String?;
    final startTime = DateTime.parse(program['startTime'] as String);
    final endTimeStr = program['endTime'] as String?;
    final category = program['category'] as String?;
    final now = DateTime.now();
    final progress = endTimeStr != null
        ? (now.difference(startTime).inMinutes /
            DateTime.parse(endTimeStr).difference(startTime).inMinutes)
        : 0.0;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_filled,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'Сейчас',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 18,
                  ),
            ),
            if (description != null) ...[
              const SizedBox(height: 6),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimaryContainer
                      .withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${_formatTime(startTime)} - ${endTimeStr != null ? _formatTime(DateTime.parse(endTimeStr)) : '?'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                  ),
                ),
                if (category != null) ...[
                  const SizedBox(width: 12),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (endTimeStr != null) ...[
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgramCard(Map<String, dynamic> program) {
    final title = program['title'] as String? ?? 'Нет названия';
    final description = program['description'] as String?;
    final startTime = DateTime.parse(program['startTime'] as String);
    final endTimeStr = program['endTime'] as String?;
    final category = program['category'] as String?;
    final now = DateTime.now();
    final isCurrent = endTimeStr != null
        ? now.isAfter(startTime) && now.isBefore(DateTime.parse(endTimeStr))
        : false;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCurrent ? theme.colorScheme.primaryContainer : null,
      elevation: isCurrent ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrent
            ? BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: SizedBox(
          width: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCurrent)
                Icon(
                  Icons.play_circle_filled,
                  color: theme.colorScheme.primary,
                  size: 16,
                )
              else
                const SizedBox(width: 16, height: 16),
              const SizedBox(height: 1),
              Text(
                _formatTime(startTime),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent
                      ? theme.colorScheme.onPrimaryContainer
                      : null,
                ),
              ),
              if (endTimeStr != null)
                Text(
                  _formatTime(DateTime.parse(endTimeStr)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 9,
                    color: isCurrent
                        ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
        title: Text(
          title,
          style: isCurrent
              ? theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                )
              : null,
        ),
        subtitle: description != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: isCurrent
                      ? theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                        )
                      : null,
                ),
              )
            : null,
        trailing: isCurrent
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Сейчас',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : category != null
                ? Chip(
                    label: Text(category),
                    labelStyle: theme.textTheme.bodySmall,
                  )
                : null,
        isThreeLine: description != null,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

