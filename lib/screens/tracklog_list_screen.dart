import 'package:flutter/material.dart';
import '../l10n/l10n_extension.dart';
import '../models/tracklog_metadata.dart';
import '../widgets/tracklog_dialogs.dart';

class TracklogListScreen extends StatefulWidget {
  final List<TracklogMetadata> tracklogs;
  final Function(TracklogMetadata) onUpdateMetadata;
  final Function(String) onDeleteTracklog;

  const TracklogListScreen({
    super.key,
    required this.tracklogs,
    required this.onUpdateMetadata,
    required this.onDeleteTracklog,
  });

  @override
  State<TracklogListScreen> createState() => _TracklogListScreenState();
}

class _TracklogListScreenState extends State<TracklogListScreen> {
  late List<TracklogMetadata> _tracklogs;

  @override
  void initState() {
    super.initState();
    _tracklogs = List.from(widget.tracklogs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.tracklogs),
      ),
      body: widget.tracklogs.isEmpty ? _buildEmptyState() : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noTracklogsAdded,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: _tracklogs.length,
      itemBuilder: (context, index) {
        final tracklog = _tracklogs[index];
        return ListTile(
          leading: Icon(
            tracklog.isVisible ? Icons.visibility : Icons.visibility_off,
            color: tracklog.isVisible ? tracklog.color : Colors.grey,
          ),
          title: Text(tracklog.name),
          subtitle: Text('${context.l10n.imported}: ${_formatDate(tracklog.importedAt)}'),
          trailing: PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value, tracklog),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_visibility',
                child: Row(
                  children: [
                    Icon(
                      tracklog.isVisible ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(tracklog.isVisible ? context.l10n.hide : context.l10n.show),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 20),
                    const SizedBox(width: 8),
                    Text(context.l10n.rename),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'change_color',
                child: Row(
                  children: [
                    const Icon(Icons.palette, size: 20),
                    const SizedBox(width: 8),
                    Text(context.l10n.changeColor),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(context.l10n.remove, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          onTap: () => Navigator.pop(context, tracklog.id),
        );
      },
    );
  }

  void _handleMenuAction(String action, TracklogMetadata tracklog) {
    switch (action) {
      case 'toggle_visibility':
        _toggleVisibility(tracklog);
        break;
      case 'rename':
        _renameTracklog(tracklog);
        break;
      case 'change_color':
        _changeColor(tracklog);
        break;
      case 'remove':
        _removeTracklog(tracklog);
        break;
    }
  }

  void _toggleVisibility(TracklogMetadata tracklog) {
    final updated = TracklogMetadata(
      id: tracklog.id,
      name: tracklog.name,
      color: tracklog.color,
      isVisible: !tracklog.isVisible,
      filePath: tracklog.filePath,
      importedAt: tracklog.importedAt,
      importedFrom: tracklog.importedFrom,
      format: tracklog.format,
      boundsNorth: tracklog.boundsNorth,
      boundsSouth: tracklog.boundsSouth,
      boundsEast: tracklog.boundsEast,
      boundsWest: tracklog.boundsWest,
    );

    setState(() {
      final index = _tracklogs.indexWhere((t) => t.id == tracklog.id);
      if (index != -1) {
        _tracklogs[index] = updated;
      }
    });

    try {
      widget.onUpdateMetadata(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToUpdateTracklog(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(updated.isVisible
            ? context.l10n.isVisibleNow(updated.name)
            : context.l10n.isHiddenNow(updated.name)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _renameTracklog(TracklogMetadata tracklog) async {
    final newName = await showNameDialog(
      context,
      initialValue: tracklog.name,
      title: context.l10n.renameTracklog,
    );

    if (newName == null || newName == tracklog.name) return;

    final updated = TracklogMetadata(
      id: tracklog.id,
      name: newName,
      color: tracklog.color,
      isVisible: tracklog.isVisible,
      filePath: tracklog.filePath,
      importedAt: tracklog.importedAt,
      importedFrom: tracklog.importedFrom,
      format: tracklog.format,
      boundsNorth: tracklog.boundsNorth,
      boundsSouth: tracklog.boundsSouth,
      boundsEast: tracklog.boundsEast,
      boundsWest: tracklog.boundsWest,
    );

    setState(() {
      final index = _tracklogs.indexWhere((t) => t.id == tracklog.id);
      if (index != -1) {
        _tracklogs[index] = updated;
      }
    });

    try {
      widget.onUpdateMetadata(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToUpdateTracklog(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Renamed to "$newName"'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _changeColor(TracklogMetadata tracklog) async {
    final newColor = await showColorPickerDialog(
      context,
      currentColor: tracklog.color,
    );

    if (newColor == null || newColor == tracklog.color) return;

    final updated = TracklogMetadata(
      id: tracklog.id,
      name: tracklog.name,
      color: newColor,
      isVisible: tracklog.isVisible,
      filePath: tracklog.filePath,
      importedAt: tracklog.importedAt,
      importedFrom: tracklog.importedFrom,
      format: tracklog.format,
      boundsNorth: tracklog.boundsNorth,
      boundsSouth: tracklog.boundsSouth,
      boundsEast: tracklog.boundsEast,
      boundsWest: tracklog.boundsWest,
    );

    setState(() {
      final index = _tracklogs.indexWhere((t) => t.id == tracklog.id);
      if (index != -1) {
        _tracklogs[index] = updated;
      }
    });

    try {
      widget.onUpdateMetadata(updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToUpdateTracklog(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Color changed for "${tracklog.name}"'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _removeTracklog(TracklogMetadata tracklog) async {
    final confirmed = await showDeleteConfirmation(
      context,
      tracklogName: tracklog.name,
    );

    if (!confirmed) return;

    setState(() {
      _tracklogs.removeWhere((t) => t.id == tracklog.id);
    });

    try {
      widget.onDeleteTracklog(tracklog.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToDeleteTracklog(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${tracklog.name}" removed'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
