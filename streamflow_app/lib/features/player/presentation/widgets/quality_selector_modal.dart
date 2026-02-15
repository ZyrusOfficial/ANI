
import 'package:flutter/material.dart';
import '../../../../core/models/anime_models.dart';

class QualitySelectorModal extends StatelessWidget {
  final List<StreamingSource> sources;
  final StreamingSource? currentSource;
  final Function(StreamingSource) onSourceSelected;

  const QualitySelectorModal({
    super.key,
    required this.sources,
    this.currentSource,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.black.withOpacity(0.9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Quality / Source',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (sources.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No other sources available', style: TextStyle(color: Colors.grey)),
            )
          else
            ...sources.map((source) {
              final isSelected = currentSource?.url == source.url;
              return ListTile(
                title: Text(
                  _formatQualityLabel(source),
                  style: TextStyle(
                    color: isSelected ? Colors.purple : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  source.isM3U8 ? 'HLS Stream' : 'Direct MP4',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                trailing: isSelected 
                    ? const Icon(Icons.check, color: Colors.purple) 
                    : null,
                onTap: () {
                  onSourceSelected(source);
                  Navigator.pop(context);
                },
              );
            }),
        ],
      ),
    );
  }

  String _formatQualityLabel(StreamingSource source) {
    if (source.quality == 'auto') return 'Auto (Best)';
    if (source.quality == 'default') return 'Default';
    return source.quality.toUpperCase();
  }
}
