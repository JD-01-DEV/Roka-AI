import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:path/path.dart' as path;

class LlamaManager extends ChangeNotifier {
  String libraryPath = "";
  String? modelPath;
  LlamaParent? _llamaParent;
  StreamSubscription? _streamSub;
  StreamController<String>? _controller;

  Future<void> setLibraryPath() async {
    debugPrint("path: ${Directory.current.path}");
    if (Platform.isAndroid) {
      libraryPath =
          "libllama.so"; // the shared library should be under android/app/src/main/jnilib
    }
    if (Platform.isIOS) libraryPath = "";
    if (Platform.isMacOS) libraryPath = "";
    if (Platform.isLinux) {
      // libraryPath =
      //     "/home/jd01/Desktop/JD/Softwares/Projects/Codium/Flutter/test/lib/libllama.so.0";
      libraryPath = path.join(Directory.current.path, "slib/linux/libllama.so");

      // libraryPath =
      //     "/home/jd01/Desktop/JD/Softwares/Projects/Codium/Flutter/róka.ai/slib/linux/libllama.so";
    }
    if (Platform.isWindows) libraryPath = "";

    if (libraryPath.isNotEmpty) Llama.libraryPath = libraryPath;

    debugPrint("Seted path to: $libraryPath");
  }

  Future<bool> loadModel(String path) async {
    try {
      final loadCommand = LlamaLoad(
        path: path,
        modelParams: ModelParams(),
        contextParams: ContextParams()..nCtx = 4096,
        samplingParams: SamplerParams(),
        format: ChatMLFormat(),
      );

      _llamaParent = LlamaParent(loadCommand);

      // The init call spawns the Isolate.
      // If the UI still freezes here, the package is performing a sync check on the main thread.
      await _llamaParent!.init();

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Load Error: $e");
      return false;
    }
  }

  Future<bool> unloadModel() async {
    try {
      await _llamaParent?.dispose();
      _llamaParent = null;
      return true;
    } catch (e) {
      return false;
    }
  }

  Stream<String> streamResponse(String prompt) async* {
    if (_llamaParent == null) {
      throw Exception("Model not loaded");
    }

    _controller = StreamController<String>();

    _streamSub = _llamaParent!.stream.listen(
      (token) {
        _controller!.add(token);
      },
      onError: (e) {
        _controller!.addError("Stream error: $e");
      },
    );

    final completionSub = _llamaParent!.completions.listen((event) async {
      if (!event.success) {
        _controller!.addError("Completion error: ${event.errorDetails}");
      }

      await _controller!.close();
    });

    await _llamaParent!.sendPrompt(prompt);

    yield* _controller!.stream;

    await _streamSub!.cancel();
    await completionSub.cancel();
  }

  void stopStream() {
    _streamSub?.cancel();
    _controller?.close();
  }
}
