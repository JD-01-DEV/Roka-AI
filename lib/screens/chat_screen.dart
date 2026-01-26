// --------------------------------------- //
// -------------- Imports ---------------- //
// --------------------------------------- //
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:roka_ai/main.dart';
// -------------- Providers ----------------- //
import 'package:provider/provider.dart';
import 'package:roka_ai/providers/chat_provider.dart';
import 'package:roka_ai/providers/user_preferences_provider.dart';
// -------------- Widgets ----------------- //
import 'package:roka_ai/widgets/message_bubble.dart';
import 'package:roka_ai/widgets/model_options.dart';
// -------------- STT & TTS ----------------- //
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
// -------------- Other ----------------- //
import 'package:roka_ai/databases/ai_model_db.dart';
import 'package:roka_ai/schemas/chat_session_model.dart';
import 'package:roka_ai/themes/app_themes.dart';

enum TtsState { playing, stopped, paused, continued }

enum AppState { listening, processing, speaking, idle }

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => __ChatScreenState();
}

class __ChatScreenState extends State<ChatScreen> {
  // ------------------------------------------ //
  // -------------- Variables ----------------- //
  // ------------------------------------------ //

  // -------------- Controllers ----------------- //
  final FocusNode _focusNode = FocusNode();
  final _messageController = TextEditingController();
  final _messageScrollController = ScrollController();
  final _chatScrollController = ScrollController();
  final _searchController = TextEditingController();

  // -------------- Speech to Text ----------------- //
  // final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  String _reconWords = '';

  // -------------- Text to Speech ----------------- //
  // FlutterTts flutterTts = FlutterTts();
  TtsState _ttsState = TtsState.stopped;

  // -------------- Model Parameters --------------- //
  double temperature = 0.5;
  double topP = 0.8;
  int maxTokens = 512;
  bool isLoading = false;

  // ------------- Live Mode --------------------- //
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  AppState _currentState = AppState.idle;
  String _displayText = "Press the mic to start";

  // -------------- Other ----------------- //
  List<ChatSession> _searchResults = [];
  int? currentSessionId;

  // --------------------------------------- //
  // -------------- States ----------------- //
  // --------------------------------------- //
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    context.read<AiModelDb>().resetOnStartup();
    _initTts();
    _initStt();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _messageController.dispose();
    _chatScrollController.dispose();
    _messageScrollController.dispose();
    super.dispose();
  }

  // ------------------------------------------ //
  // -------------- Functions ----------------- //
  // --------------------------------------- ---//

  // handles creating new chat
  void _newChat(ChatProvider chatProvider) {
    // initializing session with model and session name
    chatProvider.startNewSession();
    Navigator.pop(context); // closing drawer
  }

  // handles auto scroll for AI response
  void _scrollToBottom({bool force = false}) {
    if (_messageScrollController.hasClients) {
      final maxScroll = _messageScrollController.position.maxScrollExtent;

      _messageScrollController.animateTo(
        maxScroll,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // handles search feature in Drawer
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
    } else {
      _searchChats(query);
    }
  }

  // filter chats based on search
  void _searchChats(String query) async {
    final results = await context.read<ChatProvider>().searchChats(query);
    setState(() {
      _searchResults = results;
    });
  }

  // handle sendig and stopping messages
  Future<void> _sendMessage(ChatProvider chatProvider) async {
    final aiModelDb = context.read<AiModelDb>();
    final String modelName = await aiModelDb.getActiveModelName();
    setState(() {
      chatProvider
          .sendMessage(true, _messageController.text, modelName)
          .then((_) => {setState(() => isLoading = false)});
      isLoading = true;
    });
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(force: true);
    });
  }

  // regenerate AI's reponse
  void onRegenerate(ChatMessage msg) async {
    final db = context.read<ChatProvider>();

    final messages = await db.getMessagesForSession(msg.sessionId);
    final index = messages.indexWhere((m) => m.id == msg.id);

    if (index > 0) {
      final userMessage = messages[index - 1];
      final aiMessage = messages[index];

      if (userMessage.isUser && mounted) {
        context.read<ChatProvider>().regenerate(
          userMessage.sessionId,
          userMessage.id,
          aiMessage.id,
          userMessage.content,
        );
        setState(() => isLoading = true);
      }
    }
  }

  //
  Future<void> handleSendAndStop(ChatProvider chatProvider) async {
    if (await context.read<AiModelDb>().isAnyModelLoaded() && mounted) {
      if (!isLoading || context.read<ChatProvider>().hasResponseCompleted) {
        if (chatProvider.currentSessionId == null) {
          chatProvider.startNewSessions(
            "MyGGUFModel",
            "Chat ${DateTime.now().toString().substring(0, 10)}",
          );
        }
        _sendMessage(chatProvider);
        currentSessionId = chatProvider.currentSessionId;
      } else {
        // ApiService.stopStream();
        llamaManager.stopStream();
        setState(() => isLoading = false);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Load the model first.")));
      }
    }
  }

  // handles speech recognition
  Future<void> _listen() async {
    if (!_isListening) {
      // 1. Initialize logic
      bool available = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (errorNotification) => print('onError: $errorNotification'),
      );

      if (available) {
        setState(() => _isListening = true);

        // 2. Start Listening
        _speech.listen(
          onResult: (val) => setState(() {
            _reconWords = val.recognizedWords;
            _messageController.text = _reconWords;
          }),
        );
      }
    } else {
      // 3. Stop Listening
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _initStt() async {
    // Just warm up the engine, don't listen yet
    await _speech.initialize(
      onError: (val) => print('STT Error: $val'),
      onStatus: (val) => _handleSttStatus(val),
    );
  }

  void _initTts() {
    _flutterTts.setCompletionHandler(() {
      // CRITICAL: When TTS finishes, immediately start listening again
      _startListening();
    });
  }

  void _handleSttStatus(String status) {
    // If the OS tells us listening stopped (silence detected), we process the text
    if (status == 'done' && _currentState == AppState.listening) {
      setState(() => _currentState = AppState.processing);
      // In a real app, send text to AI/Logic here.
      // For this demo, we just echo the text back.
      if (_displayText.isNotEmpty && _displayText != "Listening...") {
        _speakResponse("You said: $_displayText");
      } else {
        // If they said nothing, just listen again or go idle
        _startListening();
      }
    }
  }

  Future<void> _startListening() async {
    // Stop speaking if we interrupt
    await _flutterTts.stop();

    setState(() {
      _currentState = AppState.listening;
      _displayText = "Listening...";
    });

    // Listen for a short burst (e.g., command)
    _speech.listen(
      onResult: (val) => setState(() {
        _displayText = val.recognizedWords;
      }),
      listenFor: const Duration(seconds: 10), // Auto-stop after silence
      pauseFor: const Duration(seconds: 2), // Detect end of sentence
      cancelOnError: true,
      onDevice: true, // Try offline if available
    );
  }

  Future<void> _speakResponse(String text) async {
    setState(() => _currentState = AppState.speaking);
    await _flutterTts.speak(text);
    // The setCompletionHandler in initState will trigger _startListening when this finishes
  }

  void _stopLiveMode() {
    _speech.stop();
    _flutterTts.stop();
    setState(() => _currentState = AppState.idle);
  }

  // ------------------------------------------ //
  // -------------- User Inteface --------------//
  // ------------------------------------------ //
  @override
  Widget build(BuildContext context) {
    isDarkMode = Provider.of<UserPreferencesProvider>(context).isDark;
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                padding: EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _onSearchChanged(),
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),

                  onSubmitted: (query) => _searchChats(query),
                ),
              ),
            ),
            Expanded(
              child: _searchController.text.isNotEmpty
                  ? (_searchResults.isNotEmpty
                        ? ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final session = _searchResults[index];
                              return ListTile(
                                title: Text(session.title, style: TextStyle()),
                                subtitle: Text(
                                  session.createdAt.toString().substring(0, 16),
                                  style: TextStyle(),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  chatProvider.loadMessages(session.id);
                                },
                              );
                            },
                          )
                        : Center(
                            child: Text("No Result found", style: TextStyle()),
                          ))
                  : Column(
                      children: [
                        Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.chat_bubble_outline),
                              title: Text("New Chat", style: TextStyle()),
                              onTap: () => _newChat(chatProvider),
                            ),
                            ListTile(
                              leading: Icon(Icons.view_comfy_alt_outlined),
                              title: Text("Models", style: TextStyle()),
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/model_manager',
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.message),
                              title: Text("Chats", style: TextStyle()),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: ListView.builder(
                              controller: _chatScrollController,
                              itemCount: chatProvider.sessions.length,
                              itemBuilder: (context, index) {
                                final session = chatProvider.sessions[index];
                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? AppThemes.secondaryDark
                                        : AppThemes.secondaryLight,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      session.title,
                                      style: TextStyle(),
                                    ),
                                    subtitle: Text(
                                      session.modelUsed,
                                      style: TextStyle(),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      chatProvider.loadMessages(session.id);
                                    },
                                    trailing: IconButton(
                                      onPressed: () {
                                        context
                                            .read<ChatProvider>()
                                            .deleteSession(session.id);
                                      },
                                      icon: Icon(Icons.delete),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    icon: Icon(Icons.settings),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Center(child: Text("Róka AI", style: TextStyle())),
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: Scaffold.of(context).openDrawer,
              icon: Icon(Icons.menu_outlined),
            );
          },
        ),
        actions: [
          IconButton(icon: MenuOptions(), onPressed: () => MenuOptions()),
        ],
        actionsPadding: EdgeInsets.only(right: 15),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom(force: true);
                });

                return ListView.builder(
                  controller: _messageScrollController,
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chatProvider.messages[index];
                    return MessageBubble(
                      content: msg.content,
                      isUser: msg.isUser,
                      onEdit: msg.isUser
                          ? (newMessage) async {
                              context.read<ChatProvider>().editMessage(
                                msg.sessionId,
                                msg.id,
                                newMessage,
                              );
                              setState(() => isLoading = true);
                            }
                          : null,
                      onRegenerate: !msg.isUser
                          ? () async => onRegenerate(msg)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  margin: EdgeInsets.only(left: 10, bottom: 20),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppThemes.secondaryDark
                        : AppThemes.secondaryLight,
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                  ),
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (_) => _sendMessage(chatProvider),
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: "Ask any thing ...",
                      hintStyle: TextStyle(
                        color: isDarkMode
                            ? AppThemes.secondaryTextDark
                            : AppThemes.secondaryTextLight,
                      ),
                      contentPadding: EdgeInsets.only(left: 25),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppThemes.secondaryDark
                      : AppThemes.secondaryLight,
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                ),
                margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
                child: IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: _currentState == AppState.idle
                      ? _startListening
                      : _stopLiveMode,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? AppThemes.secondaryDark
                      : AppThemes.secondaryLight,
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                ),
                margin: EdgeInsets.only(right: 10, bottom: 20),
                child: IconButton(
                  icon: isLoading
                      ? Icon(Icons.stop_circle_outlined, size: 30)
                      : Icon(Icons.send),
                  onPressed: () => handleSendAndStop(chatProvider),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
