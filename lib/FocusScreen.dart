import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'FocusTaskItem.dart';
import 'TasksController.dart';

class FocusScreen extends StatefulWidget {
  final String uid;
  final TasksController tasksController = Get.find();

  FocusScreen({
    super.key,
    required this.uid,
  });

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {

  @override
  void initState() {
    super.initState();
    widget.tasksController.loadFocusTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      children: widget.tasksController.getFocusTasks().map((task) {
        log('FocusScreen > widget.tasks.map : ${task.isDone}');
        return FocusTaskItem(
          task: task,
          onTaskChanged: widget.tasksController.handleTaskChange,
        );
      }).toList(),
    ));
  }
}
