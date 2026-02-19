import 'package:isar/isar.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flashcards_app/data/local/isar_provider.dart';
import 'package:flashcards_app/data/models/deck_settings.dart';

class DeckSettingsPage extends ConsumerStatefulWidget {
  final String packName;

  const DeckSettingsPage({super.key, required this.packName});

  @override
  ConsumerState<DeckSettingsPage> createState() => _DeckSettingsPageState();
}

class _DeckSettingsPageState extends ConsumerState<DeckSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // --- CONTROLADORES EXISTENTES ---
  late final TextEditingController _newCardsLimitController;
  late final TextEditingController _reviewsLimitController;
  late final TextEditingController _pMinController;
  late final TextEditingController _alphaController;
  late final TextEditingController _betaController;
  late final TextEditingController _offsetController;
  late final TextEditingController _initialNtController;
  late final TextEditingController _learningStepsController;

  // --- NUEVAS (mínimo 2 vistas el primer día) ---
  late final TextEditingController _newMinCorrectRepsController;
  late final TextEditingController _newIntraDayMinutesController;

  late final TextEditingController _lapseToleranceController;
  late final TextEditingController _lapseFixedIntervalController;
  bool _useFixedIntervalOnLapse = true;

  // --- MODO ESCRITURA ---
  late final TextEditingController _writeThresholdController;
  late final TextEditingController _writeMaxRepsController;
  bool _enableWriteMode = false;

  bool _isLoading = true;

  // Guardamos la última config cargada (para editar/guardar de forma segura)
  DeckSettings? _loadedSettings;

  @override
  void initState() {
    super.initState();

    _newCardsLimitController = TextEditingController();
    _reviewsLimitController = TextEditingController();
    _pMinController = TextEditingController();
    _alphaController = TextEditingController();
    _betaController = TextEditingController();
    _offsetController = TextEditingController();
    _initialNtController = TextEditingController();
    _learningStepsController = TextEditingController();

    _newMinCorrectRepsController = TextEditingController();
    _newIntraDayMinutesController = TextEditingController();

    _lapseToleranceController = TextEditingController();
    _lapseFixedIntervalController = TextEditingController();

    _writeThresholdController = TextEditingController();
    _writeMaxRepsController = TextEditingController();

    _loadSettings();
  }

  @override
  void dispose() {
    _newCardsLimitController.dispose();
    _reviewsLimitController.dispose();
    _pMinController.dispose();
    _alphaController.dispose();
    _betaController.dispose();
    _offsetController.dispose();
    _initialNtController.dispose();
    _learningStepsController.dispose();

    _newMinCorrectRepsController.dispose();
    _newIntraDayMinutesController.dispose();

    _lapseToleranceController.dispose();
    _lapseFixedIntervalController.dispose();
    _writeThresholdController.dispose();
    _writeMaxRepsController.dispose();
    super.dispose();
  }

  // =========================
  // Load / Save
  // =========================

  Future<void> _loadSettings() async {
    final isar = await ref.read(isarDbProvider.future);

    var settings = await isar.deckSettings
        .filter()
        .packNameEqualTo(widget.packName)
        .findFirst();

    // Si no existe, crearla y guardarla (importante por índice único packName)
    if (settings == null) {
      settings = DeckSettings()..packName = widget.packName;
      await isar.writeTxn(() async {
        await isar.deckSettings.put(settings!);
      });
    }

    _loadedSettings = settings;

    // Cargar valores
    _newCardsLimitController.text = settings.newCardsPerDay.toString();
    _reviewsLimitController.text = settings.maxReviewsPerDay.toString();

    _pMinController.text = settings.pMin.toString();
    _alphaController.text = settings.alpha.toString();
    _betaController.text = settings.beta.toString();
    _offsetController.text = settings.offset.toString();
    _initialNtController.text = settings.initialNt.toString();

    // Learning steps en DÍAS (admite fracciones)
    _learningStepsController.text = settings.learningSteps.join(', ');

    // Nuevas: mínimo de aciertos antes de pasar a otro día
    _newMinCorrectRepsController.text = settings.newCardMinCorrectReps.toString();
    _newIntraDayMinutesController.text = settings.newCardIntraDayMinutes.toString();

    _lapseToleranceController.text = settings.lapseTolerance.toString();
    _lapseFixedIntervalController.text = settings.lapseFixedInterval.toString();

    _enableWriteMode = settings.enableWriteMode;
    _writeThresholdController.text = settings.writeModeThreshold.toString();
    _writeMaxRepsController.text = settings.writeModeMaxReps.toString();

    _useFixedIntervalOnLapse = settings.useFixedIntervalOnLapse;

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _saveSettings() async {
    // Validar primero
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final isar = await ref.read(isarDbProvider.future);

    // Parseo seguro (ya validado)
    final newLimit = int.parse(_newCardsLimitController.text.trim());
    final revLimit = int.parse(_reviewsLimitController.text.trim());

    final tolerance = int.parse(_lapseToleranceController.text.trim());
    final lapseDays = _useFixedIntervalOnLapse
        ? double.parse(
      _lapseFixedIntervalController.text.trim().replaceAll(',', '.'),
    )
        : 1.0; // valor no usado si switch está apagado

    final pMin = double.parse(_pMinController.text.trim().replaceAll(',', '.'));
    final alpha = double.parse(
      _alphaController.text.trim().replaceAll(',', '.'),
    );
    final beta = double.parse(_betaController.text.trim().replaceAll(',', '.'));
    final offset = double.parse(
      _offsetController.text.trim().replaceAll(',', '.'),
    );
    final initialNt = double.parse(
      _initialNtController.text.trim().replaceAll(',', '.'),
    );

    final learningSteps = _parseLearningSteps(_learningStepsController.text);

    final newMinReps = int.parse(_newMinCorrectRepsController.text.trim());
    final newMinutes = int.parse(_newIntraDayMinutesController.text.trim());

    final writeThres = _enableWriteMode
        ? int.parse(_writeThresholdController.text.trim())
        : 80;
    final writeReps = _enableWriteMode
        ? int.parse(_writeMaxRepsController.text.trim())
        : 0;

    try {
      await isar.writeTxn(() async {
        DeckSettings? existing = await isar.deckSettings
            .filter()
            .packNameEqualTo(widget.packName)
            .findFirst();

        final settingsToSave =
            existing ?? (DeckSettings()..packName = widget.packName);

        settingsToSave
          ..packName = widget.packName
          ..newCardsPerDay = newLimit
          ..maxReviewsPerDay = revLimit
          ..lapseTolerance = tolerance
          ..useFixedIntervalOnLapse = _useFixedIntervalOnLapse
          ..lapseFixedInterval = lapseDays
          ..pMin = pMin
          ..alpha = alpha
          ..beta = beta
          ..offset = offset
          ..initialNt = initialNt
          ..learningSteps = learningSteps
          ..newCardMinCorrectReps = newMinReps
          ..newCardIntraDayMinutes = newMinutes
          ..enableWriteMode = _enableWriteMode
          ..writeModeThreshold = writeThres
          ..writeModeMaxReps = writeReps;

        await isar.deckSettings.put(settingsToSave);
        _loadedSettings = settingsToSave;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Configuración guardada!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error guardando: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================
  // Parsing + Validators
  // =========================

  List<double> _parseLearningSteps(String raw) {
    final parts = raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (parts.isEmpty) return [1.0, 4.0];

    final list = <double>[];
    for (final p in parts) {
      final v = double.tryParse(p.replaceAll(',', '.'));
      if (v != null && v > 0) list.add(v);
    }

    return list.isEmpty ? [1.0, 4.0] : list;
  }

  String? _validateInt(String? v, {required String label, int? min, int? max}) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Requerido';
    final n = int.tryParse(s);
    if (n == null) return 'Número inválido';
    if (min != null && n < min) return '$label debe ser ≥ $min';
    if (max != null && n > max) return '$label debe ser ≤ $max';
    return null;
  }

  String? _validateDouble(
      String? v, {
        required String label,
        double? min,
        double? max,
      }) {
    final s0 = (v ?? '').trim();
    if (s0.isEmpty) return 'Requerido';
    final s = s0.replaceAll(',', '.');
    final n = double.tryParse(s);
    if (n == null) return 'Número inválido';
    if (min != null && n < min) return '$label debe ser ≥ $min';
    if (max != null && n > max) return '$label debe ser ≤ $max';
    return null;
  }

  String? _validateLearningSteps(String? v) {
    final raw = (v ?? '').trim();
    if (raw.isEmpty) return 'Requerido';

    final list = _parseLearningSteps(raw);
    if (list.isEmpty) return 'Ingresa al menos 1 paso válido';
    if (list.any((x) => x <= 0)) return 'Los pasos deben ser > 0';

    return null;
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurar: ${widget.packName}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- LÍMITES ---
              _buildSectionTitle("Límites Diarios"),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _newCardsLimitController,
                      label: "Nuevas/día",
                      inputType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (v) => _validateInt(
                        v,
                        label: 'Nuevas/día',
                        min: 0,
                        max: 10000,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField(
                      controller: _reviewsLimitController,
                      label: "Máx. Repasos/día",
                      inputType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (v) => _validateInt(
                        v,
                        label: 'Máx. Repasos/día',
                        min: 0,
                        max: 100000,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- MODO ESCRITURA ---
              _buildSectionTitle("Modo Escritura (Producción)"),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepPurple.shade200),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Activar escritura (Rev-Anv)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        "Obliga a escribir la oración en el idioma objetivo.",
                      ),
                      value: _enableWriteMode,
                      activeColor: Colors.deepPurple,
                      onChanged: (val) =>
                          setState(() => _enableWriteMode = val),
                    ),
                    if (_enableWriteMode) ...[
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _writeThresholdController,
                        label: "Exactitud Mínima (%)",
                        helper:
                        "Si no llegas a este % se bloquea el botón 'Bien'.",
                        inputType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) => _validateInt(
                          v,
                          label: 'Exactitud mínima',
                          min: 0,
                          max: 100,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _writeMaxRepsController,
                        label: "Límite de Repasos (0 = Siempre)",
                        helper:
                        "0 = siempre activo. >0 = se desactiva tras N repasos de la carta.",
                        inputType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) => _validateInt(
                          v,
                          label: 'Límite de repaso',
                          min: 0,
                          max: 1000000,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- APRENDIZAJE ---
              _buildSectionTitle("Fase de Aprendizaje"),
              _buildTextField(
                controller: _learningStepsController,
                label: "Pasos (DÍAS)",
                helper:
                "Ej: 1, 4  (días). Puedes usar fracciones: 0.00694 ≈ 10 minutos (10/1440).",
                inputType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validateLearningSteps,
              ),

              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "Nuevas: mínimo 2 vistas (primer día)",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _newMinCorrectRepsController,
                      label: "Aciertos mínimos",
                      helper:
                      "Ej: 2 = una tarjeta nueva debe acertarse 2 veces antes de pasar a otro día.",
                      inputType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (v) => _validateInt(
                        v,
                        label: 'Aciertos mínimos',
                        min: 1,
                        max: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField(
                      controller: _newIntraDayMinutesController,
                      label: "Minutos intra-día",
                      helper:
                      "Intervalo guardado en nextReview tras el 1er \"Bien\" (no fuerza espera).",
                      inputType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (v) => _validateInt(
                        v,
                        label: 'Minutos intra-día',
                        min: 1,
                        max: 1440,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- ALGORITMO ---
              _buildSectionTitle("Algoritmo Ebbinghaus"),
              _buildTextField(
                controller: _pMinController,
                label: "P_min",
                helper: "Probabilidad mínima (0 < P_min < 1). Ej: 0.90",
                inputType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => _validateDouble(
                  v,
                  label: 'P_min',
                  min: 0.000001,
                  max: 0.999999,
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _alphaController,
                label: "Alpha",
                helper: "Correcto: nt = nt * (1 - alpha).",
                inputType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => _validateDouble(v, label: 'Alpha', min: 0),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _betaController,
                label: "Beta",
                helper: "Incorrecto: nt = nt * (1 + beta).",
                inputType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => _validateDouble(v, label: 'Beta', min: 0),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _offsetController,
                label: "Offset (días)",
                helper: "Se resta al intervalo final.",
                inputType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => _validateDouble(v, label: 'Offset'),
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _initialNtController,
                label: "Nt inicial",
                helper: "Decaimiento inicial.",
                inputType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) => _validateDouble(v, label: 'Nt inicial', min: 0.000001),
              ),
              const SizedBox(height: 20),

              // --- LAPSES ---
              _buildSectionTitle("Lapses"),
              _buildTextField(
                controller: _lapseToleranceController,
                label: "Tolerancia (lapses)",
                helper: "0 = desactivado. Ej: 3 => a la 3ra falla entra relearning.",
                inputType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (v) => _validateInt(
                  v,
                  label: 'Tolerancia',
                  min: 0,
                  max: 1000,
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text("Usar intervalo fijo en lapse"),
                subtitle: const Text("Si está activo, un lapse programa un intervalo fijo."),
                value: _useFixedIntervalOnLapse,
                onChanged: (v) => setState(() => _useFixedIntervalOnLapse = v),
              ),
              if (_useFixedIntervalOnLapse) ...[
                _buildTextField(
                  controller: _lapseFixedIntervalController,
                  label: "Intervalo fijo (días)",
                  helper: "Ej: 1.0",
                  inputType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => _validateDouble(v, label: 'Intervalo fijo', min: 0.000001),
                ),
              ],

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Guardar"),
                  onPressed: _saveSettings,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // Helpers UI
  // =========================

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? helper,
    TextInputType inputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
