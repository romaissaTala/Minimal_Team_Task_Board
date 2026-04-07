import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/project_bloc.dart';
import '../bloc/project_event.dart';

class CreateProjectSheet extends StatefulWidget {
  const CreateProjectSheet({super.key});

  @override
  State<CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends State<CreateProjectSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedColor = '#6366F1';

  static const _colors = [
    '#6366F1', '#10B981', '#F59E0B', '#EF4444',
    '#8B5CF6', '#EC4899', '#14B8A6', '#F97316',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 24, 24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Create project',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Project name',
              hintText: 'e.g. Website redesign',
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Color',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: scheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: _colors.map((c) {
              final color = Color(int.parse(c.replaceFirst('#', '0xFF')));
              final selected = c == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = c),
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: scheme.surface, width: 3)
                        : null,
                    boxShadow: selected
                        ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6)]
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_nameCtrl.text.trim().isEmpty) return;
                context.read<ProjectBloc>().add(
                  CreateProject(
                    name: _nameCtrl.text.trim(),
                    description: _descCtrl.text.trim().isEmpty
                        ? null
                        : _descCtrl.text.trim(),
                    color: _selectedColor,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Create project'),
            ),
          ),
        ],
      ),
    );
  }
}