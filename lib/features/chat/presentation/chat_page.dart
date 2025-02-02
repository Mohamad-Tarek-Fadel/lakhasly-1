import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import '../widgets/custom_bottom_toolbar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user-id');
  final _assistant = const types.User(
    id: 'assistant-id',
    firstName: 'Lakhasly',
  );
  late final AnimationController _animationController;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimationController();
    _showWelcomeMessage();
  }

  void _initializeAnimationController() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _showWelcomeMessage() {
    final welcome = types.TextMessage(
      author: _assistant,
      id: const Uuid().v4(),
      text: 'Welcome! Tap the microphone to start recording.',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    _addMessage(welcome);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.add(message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
  }

  Future<void> _handleTranscriptionReceived(
    String transcription,
    String analysis,
  ) async {
    final transcriptionMessage = types.TextMessage(
      author: _assistant,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: transcription,
    );

    final analysisMessage = types.TextMessage(
      author: _assistant,
      createdAt: DateTime.now().millisecondsSinceEpoch + 100,
      id: const Uuid().v4(),
      text: '💡 Analysis:\n$analysis',
    );

    await Future<void>.delayed(const Duration(milliseconds: 500));
    _addMessage(transcriptionMessage);
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    _addMessage(analysisMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A1A),
                Color(0xFF2D2D2D),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: _buildChatContainer(),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatContainer() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: _user,
          showUserNames: true,
          showUserAvatars: true,
          inputOptions: const InputOptions(
            enabled: false,
          ),
          theme: const DefaultChatTheme(
            backgroundColor: Colors.transparent,
            primaryColor: Colors.teal,
            secondaryColor: Color(0xFF404040),
            userAvatarNameColors: [Colors.tealAccent],
            messageBorderRadius: 20,
            inputBackgroundColor: Color(0xFF404040),
            inputTextColor: Colors.white,
            inputTextCursorColor: Colors.tealAccent,
            messageInsetsVertical: 16,
            messageInsetsHorizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Text(
            'Lakhasly',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.tealAccent,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.library_music, color: Colors.tealAccent),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return CustomBottomToolbar(
      isRecording: _isRecording,
      isUploading: false,
      onRecordPressed: () {
        setState(() {
          _isRecording = !_isRecording;
        });
        if (_isRecording) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      onMediaPressed: () {
        // Handle media selection
      },
    );
  }
}
