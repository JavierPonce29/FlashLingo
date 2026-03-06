import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcards_app/features/home/time_machine_service.dart';
import 'package:flashcards_app/features/settings/app_theme_mode_controller.dart';

class GeneralSettingsPage extends ConsumerWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes generales')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<ThemeMode>(
            key: ValueKey(themeMode),
            initialValue: themeMode,
            decoration: const InputDecoration(
              labelText: 'Aspecto de la interfaz',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: ThemeMode.system, child: Text('Segun el telefono')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Oscuro')),
              DropdownMenuItem(value: ThemeMode.light, child: Text('Claro')),
            ],
            onChanged: (selectedMode) {
              if (selectedMode == null) return;
              ref
                  .read(appThemeModeProvider.notifier)
                  .setThemeMode(selectedMode);
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Por defecto: Segun el telefono.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history_toggle_off),
              title: const Text('Maquina del tiempo'),
              subtitle: const Text(
                'Mueve todas las tarjetas 1 dia hacia atras y reinicia el contador diario.',
              ),
              onTap: () => _showTimeMachineDialog(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  void _showTimeMachineDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Maquina del Tiempo'),
        content: const Text(
          'Esto mueve todas las tarjetas 1 dia hacia atras (para que queden vencidas).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await applyTimeTravel(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Viajaste 1 dia al futuro!')),
                );
              }
            },
            child: const Text('Viajar +1 Dia'),
          ),
        ],
      ),
    );
  }
}
