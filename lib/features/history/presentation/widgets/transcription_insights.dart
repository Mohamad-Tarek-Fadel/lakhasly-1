import 'package:flutter/material.dart';
import '../../domain/transcription.dart';
import '../../domain/transcription_insight.dart';
import '../../data/database_helper.dart';
import '../../../common/data/gemini_service.dart';
import '../../../common/domain/insight_type.dart';

class TranscriptionInsights extends StatefulWidget {
  final Transcription transcription;

  const TranscriptionInsights({
    super.key,
    required this.transcription,
  });

  @override
  State<TranscriptionInsights> createState() => _TranscriptionInsightsState();
}

class _TranscriptionInsightsState extends State<TranscriptionInsights> {
  List<TranscriptionInsight> _insights = [];
  bool _isLoading = true;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() => _isLoading = true);
    final insights = await DatabaseHelper.instance
        .getInsightsForTranscription(widget.transcription.id!);
    setState(() {
      _insights = insights;
      _isLoading = false;
    });
  }

  Future<void> _generateInsight(InsightType type) async {
    setState(() => _isGenerating = true);
    try {
      final prompt = GeminiService.getPromptForInsightType(type);
      final content = await GeminiService.generateInsight(
        widget.transcription.content,
        prompt,
      );

      final insight = TranscriptionInsight(
        transcriptionId: widget.transcription.id!,
        type: type,
        content: content,
        createdAt: DateTime.now(),
      );
      
      await DatabaseHelper.instance.createInsight(insight);
      await _loadInsights();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating insight: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _rateInsight(TranscriptionInsight insight, int rating) async {
    await DatabaseHelper.instance.updateInsightRating(insight.id!, rating);
    await _loadInsights();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 8.0,
            children: [
              for (final type in InsightType.values)
                AnimatedScale(
                  scale: _isGenerating ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: FilledButton.tonal(
                    onPressed: _isGenerating ? null : () => _generateInsight(type),
                    child: Text('Generate ${type.name}'),
                  ),
                ),
            ],
          ),
        ),
        if (_isGenerating)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Generating insight...'),
                ],
              ),
            ),
          )
        else if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_insights.isEmpty)
          const Center(child: Text('No insights generated yet'))
        else
          Expanded(
            child: AnimatedList(
              initialItemCount: _insights.length,
              itemBuilder: (context, index, animation) {
                final insight = _insights[index];
                return SlideTransition(
                  position: animation.drive(
                    Tween(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ),
                  ),
                  child: FadeTransition(
                    opacity: animation,
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(insight.type.name),
                            subtitle: Text(insight.content),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text('Rate this insight: '),
                                for (var i = 1; i <= 5; i++)
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: IconButton(
                                      key: ValueKey('${insight.id}-$i-${insight.rating}'),
                                      icon: Icon(
                                        i <= (insight.rating ?? 0)
                                            ? Icons.star
                                            : Icons.star_border,
                                      ),
                                      onPressed: () => _rateInsight(insight, i),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
} 