import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:roka_ai/screens/chat_screen.dart';
import 'package:roka_ai/themes/app_themes.dart';
import 'package:roka_ai/widgets/icon_btn.dart';
import 'package:speech_to_text/speech_to_text.dart';

// ------------- Live Mode --------------------- //
final SpeechToText _speech = SpeechToText();
final FlutterTts _flutterTts = FlutterTts();
AppState _currentState = AppState.idle;
String _displayText = "Press the mic to start";

bool _isLive = false;

class LiveModeScreen extends StatefulWidget {
  const LiveModeScreen({super.key});

  @override
  State<LiveModeScreen> createState() => _LiveModeScreenState();
}

class _LiveModeScreenState extends State<LiveModeScreen> {
  @override
  void initState() {
    super.initState();
    _initTts();
    _initStt();
  }

  void _initStt() async {
    // Just warm up the engine, don't listen yet
    await _speech.initialize(
      onError: (val) => debugPrint('STT Error: $val'),
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
      listenOptions: SpeechListenOptions(cancelOnError: true, onDevice: true),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 500),

              child: Container(
                decoration: BoxDecoration(
                  color: AppThemes.accentBgDark,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(20),
                    right: Radius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconBtn(
                icon: Icon(Icons.cancel_outlined, size: 40),
                onPressed: () {
                  Navigator.pop(context);
                  _stopLiveMode();
                },
                darkThemeColor: AppThemes.tertiaryTextDark,
                lightThemeColor: AppThemes.tertiaryTextLight,
                borderRadius: BorderRadius.all(Radius.circular(40)),
                margin: EdgeInsets.all(20),
              ),
              SizedBox(width: 100),
              IconBtn(
                icon: Icon(_isLive ? Icons.stop : Icons.mic, size: 40),
                onPressed: () {
                  _isLive ? _stopLiveMode() : _startListening();
                  setState(() => _isLive = !_isLive);
                },
                darkThemeColor: AppThemes.tertiaryTextDark,
                lightThemeColor: AppThemes.tertiaryTextLight,
                borderRadius: BorderRadius.all(Radius.circular(40)),
                margin: EdgeInsets.all(20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
