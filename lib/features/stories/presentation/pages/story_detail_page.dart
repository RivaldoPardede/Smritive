import 'package:flutter/material.dart';

/// Placeholder — full implementation in Phase 2.
class StoryDetailPage extends StatelessWidget {
  const StoryDetailPage({super.key, required this.storyId});

  final String storyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Story Detail')),
      body: Center(child: Text('Detail for $storyId — Phase 2')),
    );
  }
}
