import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'TaskItemWidget.dart';
import 'TasksController.dart';

class HomeScreenPage extends StatefulWidget {
  final String uid;
  final TasksController tasksController = Get.find();

  HomeScreenPage({
    super.key,
    required this.uid,
  });

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.tasksController.getAll(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) {
            log('Input $value');
            widget.tasksController.filterTasks(value);
          },
          decoration: const InputDecoration(
            labelText: "Search tasks",
            border: OutlineInputBorder(),
          ),
        ),
        Expanded(
            child: Obx(() => ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: widget.tasksController.getTasks().map((task) {
                log('homeScreen > widget.tasks.map : ${task.isDone}');
                return TaskItem(
                  task: task,
                  onTaskChanged: widget.tasksController.handleTaskChange,
                );
              }).toList(),
            ),
            )
        ),
      ],
    );
  }
}
