import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:r_tasks/task.dart';
import 'package:r_tasks/tasks_dao.dart';

import 'TaskItemWidget.dart';
import 'TasksController.dart';

class HomeScreenPage extends StatefulWidget {
  final String uid;
  final void Function(Task task) onTaskChange;
  final List<Task> tasks;
  final TasksController tasksController = Get.find();

  HomeScreenPage({
    super.key,
    required this.uid,
    required this.onTaskChange,
    required this.tasks,
  });

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  late Future<List<Task>> tasksFuture;
  List<Task> tasks = [];
  final TasksDao dao = TasksDao();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tasksFuture = dao.getAll(widget.uid).then((value) => tasks = value);
    widget.tasksController.getAll(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    log('homeScreen > build : ${widget.tasks}, $tasks');
    if(widget.tasks.isNotEmpty){
      for(Task task in widget.tasks){
        if(!tasks.contains(task)){
          tasks.add(task);
        }
      }
      tasksFuture = Future.value(tasks);
    }


    return FutureBuilder(
        future: tasksFuture,
        builder: (context, snapshot) {

          if (snapshot.hasData) {
            //tasks = snapshot.data!;
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
                        onTaskChanged: widget.onTaskChange,
                      );
                    }).toList(),
                  ),
                )),
              ],
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
