import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:r_tasks/task.dart';

import 'TaskItemWidget.dart';

class HomeScreenPage extends StatefulWidget{
  final List<Task> tasks;
  final void Function(Task task) onTaskChange;

  const HomeScreenPage({super.key, required this.tasks, required this.onTaskChange});

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage>{
  List<Task> _filteredTasks = [];
  final TextEditingController _searchController = TextEditingController();

  void _filterTasks(String query) {
    List<Task> filteredList = [];
    if (query.isNotEmpty) {
      for (var task in widget.tasks) {
        if (task.name.toLowerCase().contains(query.toLowerCase())) {
          filteredList.add(task);
        }
      }
    } else {
      filteredList = widget.tasks;
    }
    setState(() {
      _filteredTasks = filteredList;
    });
  }

  @override
  void initState() {
    super.initState();
    _filteredTasks = widget.tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) {
            log('Input $value');
            _filterTasks(value);
          },
          decoration: const InputDecoration(
            labelText: "Search tasks",
            border: OutlineInputBorder(),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            children: _filteredTasks.map((task) {
              log('homeScreen > widget.tasks.map : ${task.isDone}');
              return TaskItem(
                task: task,
                onTaskChanged: widget.onTaskChange,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}