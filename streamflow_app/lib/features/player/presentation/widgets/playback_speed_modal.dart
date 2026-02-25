
import 'package:flutter/material.dart';

class PlaybackSpeedModal extends StatelessWidget {
  final double currentSpeed;
  final Function(double) onSpeedSelected;

  const PlaybackSpeedModal({
    super.key,
    required this.currentSpeed,
    required this.onSpeedSelected,
  });

  @override
  Widget build(BuildContext context) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.black.withValues(alpha: 0.9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Playback Speed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...speeds.map((speed) => ListTile(
            title: Text(
              '${speed}x',
              style: TextStyle(
                color: currentSpeed == speed ? Colors.purple : Colors.white,
                fontWeight: currentSpeed == speed ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: currentSpeed == speed 
                ? const Icon(Icons.check, color: Colors.purple) 
                : null,
            onTap: () {
              onSpeedSelected(speed);
              Navigator.pop(context);
            },
          )),
        ],
      ),
    );
  }
}
