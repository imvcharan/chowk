import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/api_service.dart';
import '../live_video_screen.dart';
import 'in_app_live_broadcaster_screen.dart';
import '../../widgets/live_media_preview.dart';

class AdminLiveScreen extends StatefulWidget {
  const AdminLiveScreen({super.key});

  @override
  State<AdminLiveScreen> createState() => _AdminLiveScreenState();
}

class _AdminLiveScreenState extends State<AdminLiveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _streamTitleController = TextEditingController();
  final _streamDescriptionController = TextEditingController();
  bool _submitting = false;
  bool _streamSubmitting = false;
  bool _loadingReports = false;
  bool _loadingStreams = false;
  String? _reportError;
  String? _streamError;
  List<dynamic> _liveReports = [];
  List<Map<String, dynamic>> _liveStreams = [];
  Map<String, dynamic>? _createdStream;
  int? _editingId;

  bool get _isEditing => _editingId != null;

  @override
  void initState() {
    super.initState();
    _fetchLiveReports();
    _fetchLiveStreams();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    _videoUrlController.dispose();
    _streamTitleController.dispose();
    _streamDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveStreams() async {
    setState(() {
      _loadingStreams = true;
      _streamError = null;
    });
    try {
      final streams = await ApiService.getLiveStreams();
      if (!mounted) return;
      setState(() => _liveStreams = streams);
    } catch (e) {
      if (!mounted) return;
      setState(() => _streamError = e.toString());
    } finally {
      if (mounted) setState(() => _loadingStreams = false);
    }
  }

  Future<void> _createStream() async {
    final title = _streamTitleController.text.trim();
    if (title.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stream title must be at least 3 characters')));
      return;
    }
    setState(() => _streamSubmitting = true);
    try {
      final stream = await ApiService.createLiveStream(
        title: title,
        description: _streamDescriptionController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _createdStream = stream);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stream created. Connect your broadcaster, then mark it live.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create stream: $e')));
    } finally {
      if (mounted) setState(() => _streamSubmitting = false);
    }
  }

  Future<void> _setStreamStatus(Map<String, dynamic> stream, String status) async {
    setState(() => _streamSubmitting = true);
    try {
      await ApiService.updateLiveStream(id: stream['id'].toString(), status: status);
      if (!mounted) return;
      setState(() {
        if (status == 'LIVE') {
          _createdStream = null;
        }
      });
      await _fetchLiveStreams();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update stream: $e')));
    } finally {
      if (mounted) setState(() => _streamSubmitting = false);
    }
  }

  void _previewStream(Map<String, dynamic> stream) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => LiveVideoScreen(story: {
        'title': stream['title'] ?? 'Live stream',
        'body': stream['description'] ?? '',
        'videoUrl': stream['playbackUrl'] ?? '',
      }),
    ));
  }

  Future<void> _fetchLiveReports() async {
    setState(() {
      _loadingReports = true;
      _reportError = null;
    });

    try {
      final reports = await ApiService.getLiveUpdates(limit: 50);
      if (!mounted) return;
      setState(() {
        _liveReports = reports;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _reportError = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loadingReports = false);
    }
  }

  void _openLiveReportPreview(Map<String, dynamic> report) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveVideoScreen(story: report),
      ),
    );
  }

  DateTime _parseToIst(String value) {
    try {
      final parsed = DateTime.parse(value);
      return parsed.toUtc().add(const Duration(hours: 5, minutes: 30));
    } catch (_) {
      return DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    }
  }

  String _formatTimestamp(String value) {
    try {
      final dateTime = _parseToIst(value);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')} IST';
    } catch (_) {
      return value;
    }
  }

  Future<void> _submitLiveUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      if (_isEditing) {
        await ApiService.updateLiveUpdate(
          id: _editingId!,
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
          videoUrl: _videoUrlController.text.trim().isEmpty ? null : _videoUrlController.text.trim(),
        );
      } else {
        await ApiService.createLiveUpdate(
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
          imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
          videoUrl: _videoUrlController.text.trim().isEmpty ? null : _videoUrlController.text.trim(),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Live update updated successfully' : 'Live update published successfully')),
      );
      _editingId = null;
      _titleController.clear();
      _bodyController.clear();
      _imageUrlController.clear();
      _fetchLiveReports();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Failed to update live update: $e' : 'Failed to publish live update: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _startEditing(Map<String, dynamic> report) {
    setState(() {
      _editingId = report['id'] as int?;
      _titleController.text = report['title'] ?? '';
      _bodyController.text = report['body'] ?? '';
      _imageUrlController.text = report['image_url'] ?? '';
      _videoUrlController.text = report['video_url'] ?? '';
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingId = null;
      _titleController.clear();
      _bodyController.clear();
      _imageUrlController.clear();
      _videoUrlController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publish Live Update'),
        backgroundColor: AppTheme.chowkOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStreamPanel(),
                const SizedBox(height: 24),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Live update publishes a short real-time report to the frontend live feed.',
                            style: TextStyle(fontSize: 16, color: AppTheme.mutedText),
                          ),
                          const SizedBox(height: 24),
                          if (_isEditing)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Editing live report #$_editingId',
                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _submitting ? null : _cancelEditing,
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            ),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(labelText: 'Title'),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Title is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _bodyController,
                            decoration: const InputDecoration(labelText: 'Body / details'),
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Body is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _imageUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Image URL (optional)',
                              hintText: 'https://...',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _videoUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Video URL (optional)',
                              hintText: 'https://... (mp4 or streaming URL)',
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _submitting ? null : _submitLiveUpdate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.chowkOrange,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _submitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(_isEditing ? 'Save live update' : 'Publish Live Update'),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _submitting
                                ? null
                                : () => Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard),
                            child: const Text('Back to admin dashboard'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Live Reports History',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            TextButton.icon(
                              onPressed: _loadingReports ? null : _fetchLiveReports,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_loadingReports)
                          const Center(child: CircularProgressIndicator())
                        else if (_reportError != null)
                          Center(
                            child: Text(
                              'Unable to load live reports: $_reportError',
                              style: const TextStyle(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else if (_liveReports.isEmpty)
                          const Center(
                            child: Text(
                              'No live reports have been published yet.',
                              style: TextStyle(color: AppTheme.mutedText),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _liveReports.length,
                            separatorBuilder: (_, __) => const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final report = _liveReports[index] as Map<String, dynamic>;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                report['title'] ?? 'Untitled live update',
                                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                                              ),
                                              const SizedBox(height: 6),
                                              Wrap(
                                                spacing: 10,
                                                runSpacing: 4,
                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                children: [
                                                  Text(
                                                    'Published: ${_formatTimestamp(report['created_at'] ?? '')}',
                                                    style: const TextStyle(fontSize: 12, color: AppTheme.mutedText),
                                                  ),
                                                  if ((report['author_name'] ?? '').toString().isNotEmpty)
                                                    Text(
                                                      'by ${report['author_name']}',
                                                      style: const TextStyle(fontSize: 12, color: AppTheme.mutedText),
                                                    ),
                                                  if ((report['updated_at'] ?? '').toString().isNotEmpty && report['updated_at'] != report['created_at'])
                                                    Text(
                                                      'Updated: ${_formatTimestamp(report['updated_at'] ?? '')}',
                                                      style: const TextStyle(fontSize: 12, color: AppTheme.mutedText),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.play_circle_outline, color: AppTheme.chowkOrange, size: 20),
                                              tooltip: 'Preview live report',
                                              onPressed: () {
                                                _openLiveReportPreview(report);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, color: AppTheme.chowkOrange, size: 20),
                                              tooltip: 'Edit live report',
                                              onPressed: () {
                                                _startEditing(report);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                              tooltip: 'Delete live report',
                                              onPressed: () async {
                                                final confirmed = await showDialog<bool>(
                                                  context: context,
                                                  builder: (dialogContext) {
                                                    return AlertDialog(
                                                      title: const Text('Delete live report?'),
                                                      content: const Text('This will remove the live report permanently.'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.of(dialogContext).pop(false),
                                                          child: const Text('Cancel'),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () => Navigator.of(dialogContext).pop(true),
                                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                                          child: const Text('Delete'),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );

                                                if (confirmed == true) {
                                                  try {
                                                    await ApiService.deleteLiveUpdate(report['id'] as int);
                                                    if (!mounted) return;
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Live report deleted')),
                                                    );
                                                    _fetchLiveReports();
                                                  } catch (e) {
                                                    if (!mounted) return;
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Failed to delete live report: $e')),
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      report['body'] ?? '',
                                      style: const TextStyle(fontSize: 14, color: AppTheme.chowkBlack),
                                    ),
                                    const SizedBox(height: 12),
                                    LiveMediaPreview(
                                      story: report,
                                      height: 140,
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        Chip(
                                          label: Text('ID: ${report['id'] ?? '—'}'),
                                          backgroundColor: AppTheme.lightGray,
                                        ),
                                        Chip(
                                          label: Text('Seq: ${report['sequence_id'] ?? '—'}'),
                                          backgroundColor: AppTheme.lightGray,
                                        ),
                                        Chip(
                                          label: Text('Published IST'),
                                          backgroundColor: AppTheme.lightGray,
                                        ),
                                        if ((report['updated_at'] ?? '').toString().isNotEmpty && report['updated_at'] != report['created_at'])
                                          Chip(
                                            label: Text('Updated IST'),
                                            backgroundColor: AppTheme.lightGray,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreamPanel() {
    final created = _createdStream;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Live video stream', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Create an RTMP session, connect OBS or another broadcaster, then publish it to viewers.', style: TextStyle(color: AppTheme.mutedText)),
            const SizedBox(height: 18),
            TextField(controller: _streamTitleController, decoration: const InputDecoration(labelText: 'Stream title')),
            const SizedBox(height: 12),
            TextField(controller: _streamDescriptionController, decoration: const InputDecoration(labelText: 'Description (optional)')),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _streamSubmitting ? null : _createStream,
              icon: const Icon(Icons.add_link),
              label: const Text('Create stream session'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.chowkOrange),
            ),
            if (created != null) ...[
              const Divider(height: 28),
              const Text('Broadcast from this phone', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _streamSubmitting
                    ? null
                    : () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => InAppLiveBroadcasterScreen(stream: created)),
                        );
                        if (mounted) _fetchLiveStreams();
                      },
                icon: const Icon(Icons.videocam),
                label: const Text('Go live with camera and microphone'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.chowkOrange),
              ),
              const SizedBox(height: 12),
              const Text('Advanced broadcaster settings', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              SelectableText('RTMP publish URL: ${created['ingestUrl'] ?? ''}'),
              const SizedBox(height: 6),
              SelectableText('Stream key: ${created['streamKey'] ?? ''}'),
              SelectableText('Media path: ${created['pathName'] ?? ''}'),
              const SizedBox(height: 8),
              const Text(
                'In OBS, use the RTMP publish URL as the server and the stream key as the key. Start broadcasting before marking this session live.',
                style: TextStyle(color: AppTheme.mutedText),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _streamSubmitting ? null : () => _setStreamStatus(created, 'LIVE'),
                icon: const Icon(Icons.wifi_tethering),
                label: const Text('Mark stream live'),
              ),
            ],
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Currently live', style: TextStyle(fontWeight: FontWeight.w800)),
                IconButton(onPressed: _loadingStreams ? null : _fetchLiveStreams, icon: const Icon(Icons.refresh), tooltip: 'Refresh live streams'),
              ],
            ),
            if (_loadingStreams)
              const LinearProgressIndicator()
            else if (_streamError != null)
              Text(_streamError!, style: const TextStyle(color: Colors.redAccent))
            else if (_liveStreams.isEmpty)
              const Text('No active video streams.', style: TextStyle(color: AppTheme.mutedText))
            else
              ..._liveStreams.map((stream) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.live_tv, color: AppTheme.chowkOrange),
                    title: Text(stream['title'] ?? 'Live stream'),
                    subtitle: Text(stream['playbackUrl'] ?? ''),
                    onTap: () => _previewStream(stream),
                    trailing: IconButton(
                      icon: const Icon(Icons.stop_circle_outlined, color: Colors.redAccent),
                      tooltip: 'End stream',
                      onPressed: _streamSubmitting ? null : () => _setStreamStatus(stream, 'ENDED'),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
