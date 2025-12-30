import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/input/custom_text_field.dart';
import '../../data/models/event_model.dart';
import '../../data/models/event_type.dart';
import '../cubit/event_cubit.dart';
import '../cubit/event_state.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  DateTime _selectedStartDate = DateTime.now();
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  DateTime _selectedEndDate = DateTime.now();
  TimeOfDay _selectedEndTime = TimeOfDay.now().replacing(
    hour: TimeOfDay.now().hour + 1,
  );
  EventType _selectedType = EventType.rehearsal;

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() => _selectedStartDate = picked);
    }
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(() => _selectedStartTime = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() => _selectedEndDate = picked);
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(() => _selectedEndTime = picked);
    }
  }

  void _createEvent() {
    if (_formKey.currentState!.validate()) {
      final startDateTime = DateTime(
        _selectedStartDate.year,
        _selectedStartDate.month,
        _selectedStartDate.day,
        _selectedStartTime.hour,
        _selectedStartTime.minute,
      );

      final endDateTime = DateTime(
        _selectedEndDate.year,
        _selectedEndDate.month,
        _selectedEndDate.day,
        _selectedEndTime.hour,
        _selectedEndTime.minute,
      );

      final event = EventModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
        location: _locationController.text.trim(),
        type: _selectedType,
        attendeeIds: [],
        createdBy: 'current_user_id',
        createdAt: DateTime.now(),
      );

      context.read<EventCubit>().createEvent(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        actions: [
          IconButton(onPressed: _createEvent, icon: const Icon(Icons.check)),
        ],
      ),
      body: BlocListener<EventCubit, EventState>(
        listener: (context, state) {
          if (state is EventCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event created successfully')),
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
                  controller: _titleController,
                  label: 'Event Title *',
                  hintText: 'Enter event title',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter event title';
                    }
                    return null;
                  },
                  labelText: '',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hintText: 'Enter event description',
                  maxLines: 4,
                  labelText: '',
                ),
                const SizedBox(height: 16),
                // Start Date and Time
                Text('Start Time', style: AppTextStyles.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _selectStartDate,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedStartDate.day}/${_selectedStartDate.month}/${_selectedStartDate.year}',
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _selectStartTime,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedStartTime.format(context)),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // End Date and Time
                Text('End Time', style: AppTextStyles.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _selectEndDate,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedEndDate.day}/${_selectedEndDate.month}/${_selectedEndDate.year}',
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _selectEndTime,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedEndTime.format(context)),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _locationController,
                  label: 'Location',
                  hintText: 'Enter event location',
                  labelText: '',
                ),
                const SizedBox(height: 16),
                // Event Type
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Event Type', style: AppTextStyles.inputLabel),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<EventType>(
                      initialValue: _selectedType,
                      onChanged: (EventType? newValue) {
                        setState(() => _selectedType = newValue!);
                      },
                      items: EventType.values.map((EventType type) {
                        return DropdownMenuItem<EventType>(
                          value: type,
                          child: Text(_getEventTypeLabel(type)),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                BlocBuilder<EventCubit, EventState>(
                  builder: (context, state) {
                    if (state is EventCreating) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createEvent,
                        child: const Text('Create Event'),
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

  String _getEventTypeLabel(EventType type) {
    switch (type) {
      case EventType.rehearsal:
        return 'Rehearsal';
      case EventType.performance:
        return 'Performance';
      case EventType.meeting:
        return 'Meeting';
      case EventType.social:
        return 'Social Event';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
