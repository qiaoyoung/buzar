import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';
import '../models/character.dart';
import 'package:uuid/uuid.dart';

class AssistantScreen extends StatelessWidget {
  static const presetQuestions = [
    "How to improve learning efficiency?",
    "How to develop good reading habits?",
    "How to manage time effectively?",
    "How to overcome procrastination?",
    "How to maintain good sleep habits?",
    "How to improve concentration?",
    "How to relieve stress and anxiety?",
    "How to develop creative thinking?",
    "How to improve memory?",
    "How to set reasonable goals?",
    "How to improve communication skills?",
    "How to develop critical thinking?",
    "How to maintain motivation for continuous learning?",
    "How to improve writing skills?",
    "How to develop independent thinking?",
    "How to improve problem-solving skills?",
    "How to develop leadership?",
    "How to improve emotional intelligence?",
    "How to cultivate innovative thinking?",
    "How to improve self-management?",
  ];

  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uuid = const Uuid();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
      ),
      body: Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 80,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
            ),
            itemCount: presetQuestions.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    final sessionId = uuid.v4();
                    
                    final aiAssistant = Character(
                      id: 'ai_assistant_${sessionId}',
                      nickname: 'AI Assistant',
                      role: 'Intelligent Assistant',
                      description: 'Professional AI assistant, ready to answer your questions.',
                      avatarPath: 'assets/images/character_1.png',
                      skills: ['Question Answering', 'Knowledge Sharing', 'Intelligent Analysis', 'Advice Providing'],
                      personality: 'Professional, Friendly, Patient, Detailed',
                      background: 'Professionally trained AI assistant, skilled in answering various questions.',
                      equipment: ['Knowledge Base', 'Analysis Tools', 'Professional Dictionary', 'Data Repository'],
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          character: aiAssistant,
                          initialQuestion: presetQuestions[index],
                          sessionId: sessionId,
                          saveHistory: false,
                          autoSendInitialQuestion: true,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.question_answer_outlined,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          presetQuestions[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => CustomQuestionDialog(
                      onSubmit: (question) {
                        if (question.isNotEmpty) {
                          final sessionId = uuid.v4();
                          final aiAssistant = Character(
                            id: 'ai_assistant_${sessionId}',
                            nickname: 'AI Assistant',
                            role: 'Intelligent Assistant',
                            description: 'Professional AI assistant, ready to answer your questions.',
                            avatarPath: 'assets/images/character_1.png',
                            skills: ['Question Answering', 'Knowledge Sharing', 'Intelligent Analysis', 'Advice Providing'],
                            personality: 'Professional, Friendly, Patient, Detailed',
                            background: 'Professionally trained AI assistant, skilled in answering various questions.',
                            equipment: ['Knowledge Base', 'Analysis Tools', 'Professional Dictionary', 'Data Repository'],
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                character: aiAssistant,
                                initialQuestion: question,
                                sessionId: sessionId,
                                saveHistory: false,
                                autoSendInitialQuestion: true,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6B8EFF), Color(0xFF4466E7)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4466E7).withOpacity(0.3),
                        offset: const Offset(0, 4),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Custom Question',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomQuestionDialog extends StatefulWidget {
  final Function(String) onSubmit;

  const CustomQuestionDialog({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<CustomQuestionDialog> createState() => _CustomQuestionDialogState();
}

class _CustomQuestionDialogState extends State<CustomQuestionDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Your Question'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Please enter your question...',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final question = _controller.text.trim();
            if (question.isNotEmpty) {
              Navigator.pop(context);
              widget.onSubmit(question);
            }
          },
          child: const Text('Ask'),
        ),
      ],
    );
  }
} 