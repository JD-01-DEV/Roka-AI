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
      libraryPath = path.join(
        Directory.current.path,
        "slib/android/arn64-v8a/libllama.so",
      );
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

  Future<bool> laodModel(
    String modelPath, {
    int nPredict = 2048,
    int nCtx = 4096,
    double topP = 0.9,
    double minP = 0.05,
  }) async {
    modelPath = modelPath;

    try {
      final loadCommand = LlamaLoad(
        path: modelPath,
        modelParams: ModelParams(),
        contextParams: ContextParams()
          ..nPredict = nPredict
          ..nCtx = nCtx,
        samplingParams: SamplerParams()
          ..topP = topP
          ..minP = minP,
        format: ChatMLFormat(),
      );

      _llamaParent = LlamaParent(loadCommand);
      await _llamaParent!.init();
      return true;
    } catch (e) {
      debugPrint("Failed to load model: $e");
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
