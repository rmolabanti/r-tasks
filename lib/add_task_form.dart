import 'package:flutter/material.dart';

class AddTaskForm extends StatefulWidget {
  final void Function({required String name}) onTaskAdded;

  const AddTaskForm({super.key, required this.onTaskAdded});

  @override
  State<StatefulWidget> createState() => AddTaskFormState();
}

class AddTaskFormState extends State<AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final addTaskController = TextEditingController();

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
                            widget.onTaskAdded(name: addTaskController.text);
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text("Add"),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}