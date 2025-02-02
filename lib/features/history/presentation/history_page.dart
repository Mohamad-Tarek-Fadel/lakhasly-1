import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../data/database_helper.dart';
import '../domain/transcription.dart';
import 'widgets/transcription_insights.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _searchController = TextEditingController();
  List<Transcription> _transcriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTranscriptions();
  }

  Future<void> _loadTranscriptions() async {
    setState(() => _isLoading = true);
    final transcriptions = await DatabaseHelper.instance.getAllTranscriptions();
    setState(() {
      _transcriptions = transcriptions;
      _isLoading = false;
    });
  }

  Future<void> _searchTranscriptions(String query) async {
    if (query.isEmpty) {
      await _loadTranscriptions();
      return;
    }
    
    final transcriptions = await DatabaseHelper.instance.searchTranscriptions(query);
    setState(() => _transcriptions = transcriptions);
  }

  Future<void> _deleteTranscription(Transcription transcription) async {
    await DatabaseHelper.instance.delete(transcription.id!);
    await _loadTranscriptions();
  }

  Future<void> _shareTranscription(Transcription transcription) async {
    await Share.share(
      '${transcription.title}\n\n${transcription.content}',
      subject: transcription.title,
    );
  }

  void _showTranscriptionDetails(Transcription transcription) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text(transcription.title),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(transcription.content),
              ),
              const Divider(),
              Expanded(
                child: TranscriptionInsights(
                  transcription: transcription,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search transcriptions...',
              onChanged: _searchTranscriptions,
              leading: const Icon(Icons.search),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transcriptions.isEmpty
                    ? const Center(child: Text('No transcriptions found'))
                    : ListView.builder(
                        itemCount: _transcriptions.length,
                        itemBuilder: (context, index) {
                          final transcription = _transcriptions[index];
                          return ListTile(
                            title: Text(transcription.title),
                            subtitle: Text(transcription.createdAt),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text('Share'),
                                  onTap: () => _shareTranscription(transcription),
                                ),
                                PopupMenuItem(
                                  child: const Text('Delete'),
                                  onTap: () => _deleteTranscription(transcription),
                                ),
                              ],
                            ),
                            onTap: () => _showTranscriptionDetails(transcription),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 