import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
import 'package:roka_ai/databases/ai_model_db.dart';
import 'package:roka_ai/main.dart';
import 'package:roka_ai/schemas/ai_model_model.dart';
import 'package:roka_ai/themes/app_themes.dart';
import 'package:roka_ai/widgets/model_tile.dart';
// import 'package:roka_ai/services/api_service.dart';
import 'package:roka_ai/widgets/parameter_dialog.dart';
import 'package:provider/provider.dart';
// import 'package:saf/saf.dart';

class ModelManagerScreen extends StatefulWidget {
  const ModelManagerScreen({super.key}); // constructor

  // creating MpdelManagerScreen's state with type of ModelManagerScreen Class
  @override
  State<ModelManagerScreen> createState() => _ModelManagerScreenState();
}

// extending State<ModelManagerScreen> to use fetures of StatefulWidget
class _ModelManagerScreenState extends State<ModelManagerScreen>
    with WidgetsBindingObserver {
  final List<String> _modelsInApp = [];
  bool _isPickingFile = false;

  // it runs when the state / ModelManagerScreen is initialized
  @override
  void initState() {
    super.initState();
    context
        .read<AiModelDb>()
        .fetchAiModels(); // fetches / refreshes the AiModel list so that it can show existing ones at start
  }

  String extractParams(String fileName) {
    final match = RegExp(r'(\d+)(b|B).*?Q(\d+)').firstMatch(fileName);
    if (match != null) {
      return "${match.group(1)}B Q${match.group(3)}";
    }
    return "Unknown";
  }

  // handling adding model from local file / storage to database
  Future<void> _addModel() async {
    if (_isPickingFile) return;
    setState(() => _isPickingFile = true);

    final result = await FilePicker.platform.pickFiles(
      // type: FileType.custom,
      // allowedExtensions: ['gguf'],
    );

    if (result == null || result.files.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("No model added")));
      }
      setState(() => _isPickingFile = false);
      return;
    }

    final file = result.files.single;
    final fileName = file.name;

    if (fileName.endsWith(".gguf") == false) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Only .gguf files are allowed")));
      }
      setState(() => _isPickingFile = false);
      return;
    }

    final pickedFile = File(file.path!);
    final appDocDir = await getApplicationDocumentsDirectory();
    final newModelPath = '${appDocDir.path}/${pickedFile.path.split('/').last}';
    final newModelFile = await pickedFile.copy(newModelPath);

    final fileSize =
        "${(file.size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
    final indexOfDot = fileName.lastIndexOf(".");
    final filteredFileName = indexOfDot != -1
        ? fileName.substring(0, indexOfDot)
        : fileName;
    final modelParameters = extractParams(fileName);

    final aiModel = AiModel()
      ..name = filteredFileName
      ..size = fileSize
      ..dateAdded = DateTime.now()
      ..filePath =
          // "/tmp/$fileName" // Use the server-side path
          newModelFile.path
      ..parameters = modelParameters
      ..isLoaded = false;

    for (var model in _modelsInApp) {
      if (aiModel.name == model && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${aiModel.name} already exists")),
        );
        setState(() => _isPickingFile = false);
        return;
      }
    }

    _modelsInApp.add(aiModel.name);
    if (mounted) {
      await context.read<AiModelDb>().addModelToDb(aiModel);
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${aiModel.name} added")));
    }

    setState(() => _isPickingFile = false);
  }

  Future<void> _handleModelLoading(String path, int modelId) async {
    final db = context.read<AiModelDb>();
    bool anyModelLoaded = db.aiModels.any((m) => m.isLoaded);

    if (anyModelLoaded) {
      final modelId = await db.getActiveModelId();
      await _unloadModel(modelId);
    }

    await _loadModel(path, modelId);
  }

  // handles loading model with the help of ApiService
  Future<void> _loadModel(String path, int modelId) async {
    final db = context.read<AiModelDb>();

    // final loaded = await ApiService.loadModel(
    //   path,
    // ); // loading model using path through ApiSevice

    debugPrint("model path at load: $path");
    final loaded = await llamaManager.laodModel(path);
    // if model is loaded then
    if (loaded) {
      await db.setActiveModel(modelId); // ensures only this model is active
      debugPrint("set active model");
    }

    final String modelName = await db.getModleNameById(modelId);
    // showing message that model loaded of not
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loaded ? "$modelName Loaded" : "Failed to load $modelName",
          ),
        ),
      );
    }
  }

  // hadnling unloading of AI model
  Future<void> _unloadModel(int modelId) async {
    final db = context.read<AiModelDb>();

    // final unLoaded = await ApiService.unloadModel();
    final unLoaded = await llamaManager.unloadModel();
    if (unLoaded) {
      await db.unloadModel(modelId);
    }

    final String modelName = await db.getModleNameById(modelId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            unLoaded
                ? "$modelName Unloaded successfully"
                : "Failed to unload $modelName",
          ),
        ),
      );
    }
  }

  // func to delete model from DB
  void _deleteModel(int modelId) async {
    final db = context.read<AiModelDb>();
    final String modelName = await db.getModleNameById(modelId);
    // deleting model using model ID
    await db.deleteModel(modelId);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(" $modelName deleted")));
    }
  }

  // func to handle model setting dialog
  void _openModelSettings() {
    showDialog(
      context: context,
      builder: (context) => ParameterDialog(
        temperature: 1,
        topP: 0.5,
        maxTokens: 265,
        onTempChange: (value) {},
        onTopPChange: (value) {},
        onMaxTokensChange: (value) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Models"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: Consumer<AiModelDb>(
              builder: (context, db, _) {
                final aiModels = db.aiModels;
                return ListView.builder(
                  itemCount: aiModels.length,
                  itemBuilder: (context, index) {
                    final model = aiModels[index];
                    return ModelTile(
                      name: model.name,
                      size: model.size,
                      parameters: model.parameters,
                      isLoaded: model.isLoaded,
                      onLoadUnlaod: () async {
                        // await _loadModel(model.filePath, model.id);
                        _handleModelLoading(model.filePath, model.id);

                        debugPrint(
                          "Model ${model.name} loaded=${model.isLoaded}",
                        );
                      },
                      onDelete: () => _deleteModel(model.id),
                      onSettings: () => _openModelSettings(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: isDarkMode
            ? AppThemes.accentDark
            : AppThemes.accentLight,
        onPressed: () => _isPickingFile ? null : _addModel(),
        child: Icon(Icons.add_outlined),
      ),
    );
  }
}
