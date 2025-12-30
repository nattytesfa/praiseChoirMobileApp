import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/input/custom_text_field.dart';
import '../../data/models/poll_model.dart' as poll_model;
import '../cubit/event_cubit.dart';
import '../cubit/event_state.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({super.key});

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  bool _isMultipleChoice = false;
  bool _isAnonymous = true;

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        _optionControllers.removeAt(index);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _createPoll() {
    if (_formKey.currentState!.validate()) {
      final options = _optionControllers
          .where((controller) => controller.text.trim().isNotEmpty)
          .map(
            (controller) => poll_model.PollOption(
              id: 'option_${DateTime.now().millisecondsSinceEpoch}_${controller.hashCode}',
              text: controller.text.trim(),
            ),
          )
          .toList();

      if (options.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least 2 options')),
        );
        return;
      }

      final poll = poll_model.PollModel(
        id: '',
        question: _questionController.text.trim(),
        options: options,
        createdBy: 'current_user_id', // TODO: Get from auth
        createdAt: DateTime.now(),
        expiresAt: _selectedDate,
      );

      context.read<EventCubit>().createPoll(poll);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Poll'),
        actions: [
          IconButton(onPressed: _createPoll, icon: const Icon(Icons.check)),
        ],
      ),
      body: BlocListener<EventCubit, EventState>(
        listener: (context, state) {
          if (state is PollCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Poll created successfully')),
            );
            Navigator.pop(context);
          } else if (state is EventError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: _questionController,
                  label: 'Poll Question *',
                  hintText: 'Enter your poll question',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter poll question';
                    }
                    return null;
                  },
                  labelText: '',
                ),
                const SizedBox(height: 20),
                Text('Poll Options *', style: AppTextStyles.titleSmall),
                const SizedBox(height: 8),
                ..._optionControllers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: controller,
                            hintText: 'Option ${index + 1}',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter option text';
                              }
                              return null;
                            },
                            labelText: '',
                            label: '',
                          ),
                        ),
                        if (_optionControllers.length > 2) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _removeOption(index),
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
                OutlinedButton(
                  onPressed: _addOption,
                  child: const Text('Add Option'),
                ),
                const SizedBox(height: 20),
                // Poll Settings
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Poll Settings', style: AppTextStyles.titleSmall),
                        const SizedBox(height: 12),
                        // Multiple Choice
                        Row(
                          children: [
                            Checkbox(
                              value: _isMultipleChoice,
                              onChanged: (value) {
                                setState(() => _isMultipleChoice = value!);
                              },
                            ),
                            const Expanded(
                              child: Text('Allow multiple choice selection'),
                            ),
                          ],
                        ),
                        // Anonymous
                        Row(
                          children: [
                            Checkbox(
                              value: _isAnonymous,
                              onChanged: (value) {
                                setState(() => _isAnonymous = value!);
                              },
                            ),
                            const Expanded(child: Text('Anonymous voting')),
                          ],
                        ),
                        // Expiry Date
                        const SizedBox(height: 12),
                        Text(
                          'Poll Expiry Date',
                          style: AppTextStyles.inputLabel,
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _selectDate,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<EventCubit, EventState>(
                  builder: (context, state) {
                    if (state is PollCreating) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createPoll,
                        child: const Text('Create Poll'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
