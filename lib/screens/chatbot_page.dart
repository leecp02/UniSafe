import 'package:flutter/material.dart';

import 'hotline_page.dart';
import 'report_page.dart';
import '../style/style.dart';

class ChatbotPage extends StatefulWidget {
  final bool isCounsellor;

  const ChatbotPage({
    super.key,
    this.isCounsellor = false,
  });

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  static const String _openReportActionKey = '__open_report_page__';
  static const String _openHotlineActionKey = '__open_hotline_page__';

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final Map<String, _BotNode> _nodes;
  final List<_ChatMessage> _messages = [];
  String _currentNodeKey = 'main';

  @override
  void initState() {
    super.initState();
    _nodes = _buildNodes();
    _pushBotNode('main');
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, _BotNode> _buildNodes() {
    return {
      'main': _BotNode(
        text:
            'Hi, I am UniSafe Assistant.\nChoose a topic by typing the number or tapping an option.',
        options: const [
          _BotOption(
            key: '1',
            label: '1. Submit an incident report',
            nextNodeKey: 'report_guide',
          ),
          _BotOption(
            key: '2',
            label: '2. Emergency hotline and urgent help',
            nextNodeKey: 'hotline_help',
          ),
          _BotOption(
            key: '3',
            label: '3. Report status and what happens next',
            nextNodeKey: 'status_flow',
          ),
          _BotOption(
            key: '4',
            label: '4. Privacy and confidentiality',
            nextNodeKey: 'privacy',
          ),
          _BotOption(
            key: '5',
            label: '5. Mental health support options',
            nextNodeKey: 'mental_health',
          ),
        ],
      ),
      'report_guide': _BotNode(
        text:
            'To submit a report:\n1. Go to Report tab.\n2. Fill in title, category, location, and description clearly.\n3. Add a photo if available.\n4. Tap Submit.\n\nTip: Include exact location and time to help counsellors respond faster.',
        options: const [
          _BotOption(
            key: '1',
            label: '1. What report categories should I choose?',
            nextNodeKey: 'report_categories',
          ),
          _BotOption(
            key: '2',
            label: '2. How to write a good description?',
            nextNodeKey: 'good_description',
          ),
          _BotOption(
            key: '3',
            label: '3. Go to Report page',
            nextNodeKey: _openReportActionKey,
          ),
          _BotOption(
            key: '9',
            label: '9. Back to main menu',
            nextNodeKey: 'main',
          ),
        ],
      ),
      'report_categories': _BotNode(
        text:
            'Common category examples:\n- Safety hazard\n- Harassment\n- Facility issue\n- Theft\n- Other concerns\n\nPick the closest category and explain details in the description.',
        options: const [
          _BotOption(key: '9', label: '9. Back to main menu', nextNodeKey: 'main'),
        ],
      ),
      'good_description': _BotNode(
        text:
            'A strong report description should answer:\n- What happened?\n- Where exactly?\n- When did it happen?\n- Who was involved? (if safe to share)\n- Any immediate danger now?\n\nKeep it factual and concise.',
        options: const [
          _BotOption(key: '9', label: '9. Back to main menu', nextNodeKey: 'main'),
        ],
      ),
      'hotline_help': _BotNode(
        text:
            'If there is immediate danger, call emergency services first.\nFor campus assistance, open the Hotline tab to view available contacts and call directly.',
        options: const [
          _BotOption(
            key: '1',
            label: '1. What is considered urgent?',
            nextNodeKey: 'urgent_definition',
          ),
          _BotOption(
            key: '2',
            label: '2. Go to Hotline page',
            nextNodeKey: _openHotlineActionKey,
          ),
          _BotOption(key: '9', label: '9. Back to main menu', nextNodeKey: 'main'),
        ],
      ),
      'urgent_definition': _BotNode(
        text:
            'Urgent examples:\n- Threat to life or injury\n- Ongoing violence\n- Severe mental distress with immediate risk\n- Dangerous incidents happening now\n\nFor urgent cases, do not wait for chat replies. Call emergency support immediately.',
        options: const [
          _BotOption(key: '9', label: '9. Back to main menu', nextNodeKey: 'main'),
        ],
      ),
      'status_flow': _BotNode(
        text:
            'Report status guide:\n- new: submitted and waiting review\n- in_progress: counsellor handling it\n- resolved: action completed\n- closed: case finalized\n\nYou can check updates in Records and Messages.',
        options: const [
          _BotOption(
            key: '1',
            label: '1. How long does review usually take?',
            nextNodeKey: 'review_time',
          ),
          _BotOption(key: '9', label: '9. Back to main menu', nextNodeKey: 'main'),
        ],
      ),
      'review_time': _BotNode(
        text:
            'Review speed depends on urgency and queue volume. Urgent cases are prioritized. You will receive updates in the app once a counsellor responds.',
        options: const [
          _BotOption(key: '9', label: '9. Back to main menu', nextNodeKey: 'main'),
        ],
      ),
      'privacy': _BotNode(
        text:
            'Your report is visible to authorized counsellors and relevant system processes only. Share only necessary details and avoid posting sensitive data in public areas.',
        options: const [
          _BotOption(
            key: '1',
            label: '1. Can I edit a report after submit?',
            nextNodeKey: 'edit_report',
          ),
          _BotOption(key: '9', label: '9. Back to main menu', nextNodeKey: 'main'),
        ],
      ),
      'edit_report': _BotNode(
        text:
            'If editing is not available after submission, contact counsellor support through Messages and reference your Report ID.',
        options: const [
          _BotOption(key: '9', label: '9. Back to main menu', nextNodeKey: 'main'),
        ],
      ),
      'mental_health': _BotNode(
        text:
            'You can seek support by:\n1. Sending a report with clear context\n2. Contacting hotline numbers\n3. Chatting with assigned counsellor from Records\n\nIf you feel unsafe now, call emergency services immediately.',
        options: const [
          _BotOption(
            key: '1',
            label: '1. I need help describing my situation',
            nextNodeKey: 'describe_help',
          ),
          _BotOption(key: '9', label: '9. Back to main menu', nextNodeKey: 'main'),
        ],
      ),
      'describe_help': _BotNode(
        text:
            'Try this format:\n- I am currently at: [location]\n- I am feeling: [brief feeling]\n- Immediate risk level: [low/medium/high]\n- What happened: [short facts]\n- What support I need: [specific request]',
        options: const [
          _BotOption(key: '9', label: '9. Back to main menu', nextNodeKey: 'main'),
        ],
      ),
    };
  }

  void _pushBotNode(String nodeKey) {
    final node = _nodes[nodeKey];
    if (node == null) {
      return;
    }

    setState(() {
      _currentNodeKey = nodeKey;
      _messages.add(
        _ChatMessage(
          text: node.text,
          isBot: true,
          options: node.options,
        ),
      );
    });

    _scrollToBottom();
  }

  void _handleUserText(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(text: text, isBot: false));
    });

    _inputController.clear();

    final currentNode = _nodes[_currentNodeKey];
    if (currentNode == null) {
      _pushBotNode('main');
      return;
    }

    _BotOption? matched;
    for (final option in currentNode.options) {
      if (text == option.key || text.toLowerCase() == option.label.toLowerCase()) {
        matched = option;
        break;
      }
    }

    if (matched == null) {
      setState(() {
        _messages.add(
          _ChatMessage(
            text: 'Please choose a valid option number shown above.',
            isBot: true,
            options: currentNode.options,
          ),
        );
      });
      _scrollToBottom();
      return;
    }

    if (matched.nextNodeKey == _openReportActionKey) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Report')),
            body: const SafeArea(child: ReportPage()),
          ),
        ),
      );
      return;
    }

    if (matched.nextNodeKey == _openHotlineActionKey) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Hotline')),
            body: SafeArea(
              child: HotlinePage(isCounsellor: widget.isCounsellor),
            ),
          ),
        ),
      );
      return;
    }

    _pushBotNode(matched.nextNodeKey);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot Assistant'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Try asking with numbers, for example: 1, 2, 3, or 9 to go back.',
              style: CustomStyle.subtitle,
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatBubble(
                  message: message,
                  onTapOption: (option) {
                    _handleUserText(option.key);
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _handleUserText,
                      decoration: InputDecoration(
                        hintText: 'Type option number, e.g. 1',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleUserText(_inputController.text),
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  final ValueChanged<_BotOption> onTapOption;

  const _ChatBubble({
    required this.message,
    required this.onTapOption,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = message.isBot ? Colors.grey.shade200 : CustomStyle.primary;
    final textColor = message.isBot ? Colors.black87 : Colors.white;
    final align = message.isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text,
            style: TextStyle(color: textColor),
          ),
        ),
        if (message.isBot && message.options.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: message.options.map((option) {
              return OutlinedButton(
                onPressed: () => onTapOption(option),
                child: Text(option.label),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isBot;
  final List<_BotOption> options;

  const _ChatMessage({
    required this.text,
    required this.isBot,
    this.options = const [],
  });
}

class _BotNode {
  final String text;
  final List<_BotOption> options;

  const _BotNode({
    required this.text,
    required this.options,
  });
}

class _BotOption {
  final String key;
  final String label;
  final String nextNodeKey;

  const _BotOption({
    required this.key,
    required this.label,
    required this.nextNodeKey,
  });
}
