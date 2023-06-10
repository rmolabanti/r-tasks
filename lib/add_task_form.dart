import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:r_tasks/task.dart';

import 'TasksController.dart';

class AddTaskForm extends StatefulWidget {
  final TasksController tasksController = Get.find();
  final Task? task;
  AddTaskForm({super.key,this.task});

  @override
  State<StatefulWidget> createState() => AddTaskFormState(task);
}

class AddTaskFormState extends State<AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController addTaskController;

  AddTaskFormState(task): addTaskController = TextEditingController(text:task?.name);

  @override
  void dispose() {
    addTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Task")),
      body: Center(
        child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    autofocus:true,
                    controller: addTaskController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(addTaskController.text)),
                            );
                            if(widget.task != null){
                              widget.task!.name=addTaskController.text;
                              widget.tasksController.updateTask(widget.task!);
                            }else{
                              widget.tasksController.handleNewTask(addTaskController.text);
                            }
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(widget.task != null ? "Update":"Add"),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}