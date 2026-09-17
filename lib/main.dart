import 'package:flutter/material.dart';

void main() => runApp(const StudyFlowApp());

enum AssignmentPriority {
  low('Low'),
  med('Med'),
  high('High');

  const AssignmentPriority(this.label);

  final String label;
}

class Assignment {
  Assignment({
    required this.title,
    required this.dueDate,
    this.course = '',
    this.priority = AssignmentPriority.med,
    this.isComplete = false,
  });

  final String title;
  final DateTime dueDate;
  final String course;
  final AssignmentPriority priority;
  bool isComplete;

  bool get isOverdue =>
      !isComplete &&
      DateUtils.dateOnly(dueDate).isBefore(DateUtils.dateOnly(DateTime.now()));
}

class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyFlow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AssignmentHomePage(),
    );
  }
}

enum AssignmentFilter { all, upcoming, completed }

class AssignmentHomePage extends StatefulWidget {
  const AssignmentHomePage({super.key});

  @override
  State<AssignmentHomePage> createState() => _AssignmentHomePageState();
}

class _AssignmentHomePageState extends State<AssignmentHomePage> {
  final List<Assignment> _assignments = [
    Assignment(
      title: 'Read Chapter 1',
      dueDate: DateTime.now().add(const Duration(days: 2)),
    ),
    Assignment(
      title: 'Submit project proposal',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
  AssignmentFilter _filter = AssignmentFilter.all;

  List<Assignment> get _visibleAssignments {
    final assignments = _assignments.where((assignment) {
      return switch (_filter) {
        AssignmentFilter.all => true,
        AssignmentFilter.upcoming => !assignment.isComplete,
        AssignmentFilter.completed => assignment.isComplete,
      };
    }).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return assignments;
  }

  Future<void> _addAssignment() async {
    final controller = TextEditingController();
    final courseController = TextEditingController();
    var selectedPriority = AssignmentPriority.med;
    var selectedDate = DateTime.now().add(const Duration(days: 1));
    final route = DialogRoute<Assignment>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Assignment title',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: courseController,
                  decoration: const InputDecoration(
                    labelText: 'Course / class',
                    hintText: 'e.g. Biology',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AssignmentPriority>(
                  initialValue: selectedPriority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: AssignmentPriority.values
                      .map(
                        (priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority.label),
                        ),
                      )
                      .toList(),
                  onChanged: (priority) {
                    if (priority != null) {
                      setDialogState(() => selectedPriority = priority);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: Text('Due: ${_formatDate(selectedDate)}')),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
                        );
                        if (date != null && context.mounted) {
                          setDialogState(() => selectedDate = date);
                        }
                      },
                      child: const Text('Choose date'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final title = controller.text.trim();
                if (title.isNotEmpty) {
                  Navigator.pop(
                    dialogContext,
                    Assignment(
                      title: title,
                      dueDate: selectedDate,
                      course: courseController.text.trim(),
                      priority: selectedPriority,
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
    final assignment = await Navigator.of(context).push(route);
    // Keep controllers alive until the dialog's closing animation finishes.
    await route.completed;
    controller.dispose();
    courseController.dispose();
    if (mounted && assignment != null) {
      setState(() => _assignments.add(assignment));
    }
  }

  String _formatDate(DateTime date) => '${date.month}/${date.day}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final assignments = _visibleAssignments;
    return Scaffold(
      appBar: AppBar(title: const Text('StudyFlow')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAssignment,
        icon: const Icon(Icons.add),
        label: const Text('Add assignment'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SegmentedButton<AssignmentFilter>(
              segments: const [
                ButtonSegment(value: AssignmentFilter.all, label: Text('All')),
                ButtonSegment(
                  value: AssignmentFilter.upcoming,
                  label: Text('Upcoming'),
                ),
                ButtonSegment(
                  value: AssignmentFilter.completed,
                  label: Text('Completed'),
                ),
              ],
              selected: {_filter},
              onSelectionChanged: (selection) =>
                  setState(() => _filter = selection.first),
            ),
          ),
          Expanded(
            child: assignments.isEmpty
                ? const Center(child: Text('No assignments here yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      final assignment = assignments[index];
                      final color = assignment.isOverdue ? Colors.red : null;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: CheckboxListTile(
                          value: assignment.isComplete,
                          onChanged: (value) => setState(
                            () => assignment.isComplete = value ?? false,
                          ),
                          title: Text(
                            assignment.title,
                            style: TextStyle(
                              color: color,
                              decoration: assignment.isComplete
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Course / class: ${assignment.course.isEmpty ? 'Unspecified' : assignment.course}',
                              ),
                              Text('Priority: ${assignment.priority.label}'),
                              Text(
                                assignment.isOverdue
                                    ? 'Overdue • ${_formatDate(assignment.dueDate)}'
                                    : 'Due ${_formatDate(assignment.dueDate)}',
                                style: TextStyle(color: color),
                              ),
                            ],
                          ),
                          secondary: Icon(
                            Icons.calendar_today_outlined,
                            color: color,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
