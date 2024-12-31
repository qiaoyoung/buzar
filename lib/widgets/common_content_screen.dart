import 'package:flutter/material.dart';

class CommonContentScreen extends StatelessWidget {
  final String title;
  final String content;

  const CommonContentScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildFormattedContent(context, content),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormattedContent(BuildContext context, String content) {
    final List<Widget> widgets = [];
    final sections = content.split('\n\n');
    
    for (var section in sections) {
      if (section.trim().isEmpty) continue;

      if (section.startsWith('#')) {
        // 处理大标题
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 12),
          child: Text(
            section.replaceAll('#', '').trim(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ));
      } else if (section.contains('：') && !section.contains('\n')) {
        // 处理小标题
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            section.trim(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ));
      } else if (section.startsWith('•')) {
        // 处理列表项
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '•',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  section.substring(1).trim(),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ));
      } else {
        // 处理普通段落
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            section.trim(),
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
} 