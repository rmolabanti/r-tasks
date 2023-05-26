import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:r_tasks/task.dart';
import 'package:r_tasks/tasks_dao.dart';

import 'FocusTaskItem.dart';

class FocusScreen extends StatefulWidget {
  final String uid;
  final void Function(Task task) onTaskChange;

  const FocusScreen({
    super.key,
    required this.uid,
    required this.onTaskChange,
  });

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  late Future<List<Task>> tasksFuture;
  final TasksDao dao = TasksDao();

  @override
  void initState() {
    super.initState();
    tasksFuture = dao.getFocusTasks(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: snapshot.data!.map((task) {
                log('FocusScreen > widget.tasks.map : ${task.isDone}');
                return FocusTaskItem(
                  task: task,
                  onTaskChanged: widget.onTaskChange,
                );
              }).toList(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Transform.scale(
              scale: 0.1,
              child: const CircularProgressIndicator(
                strokeWidth: 20.0,
              ),
            );
          }
        });
  }
}
