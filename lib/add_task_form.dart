import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:r_tasks/task.dart';

import 'TasksController.dart';

class AddTaskForm extends StatefulWidget {
  final TasksController tasksController = Get.find();
  final Task task;

  AddTaskForm({super.key,required this.task});

  @override
  State<StatefulWidget> createState() => AddTaskFormState();
}

class AddTaskFormState extends State<AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController addTaskController;
  final TextEditingController _tagController = TextEditingController();

  void _addTag() {
    String newTag = _tagController.text.trim();
    if (newTag.isNotEmpty) {
      setState(() {
        widget.task.tags.add(newTag);
        _tagController.clear();
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != widget.task.dueDate) {
      setState(() {
        widget.task.dueDate = pickedDate;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    addTaskController = TextEditingController(text:widget.task.name);
  }

  @override
  void dispose() {
    addTaskController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag),
      onDeleted: () {
        setState(() {
          widget.task.tags.remove(tag);
        });
      },
    );
  }

  ElevatedButton _buildElevatedButtonAdd(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(addTaskController.text)),
          );
          if(widget.task.name.isNotEmpty){
            widget.task.name=addTaskController.text;
            widget.tasksController.updateTask(widget.task);
          }else{
            widget.task.name=addTaskController.text;
            widget.tasksController.handleNewTask(widget.task);
          }
          Navigator.of(context).pop();
        }
      },
      child: Text(widget.task.name.isNotEmpty  ? "Update":"Add"),
    );
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
                Wrap(
                  spacing: 8,
                  children: widget.task.tags.map((tag) => _buildTagChip(tag)).toList(),
                ),
                Padding(padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _tagController,
                    onSubmitted: (value) {
                      _addTag();
                    },
                    decoration: InputDecoration(
                      labelText: 'Tag',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addTag,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                    ),
                    onTap: _selectDate, // Open date picker on tap
                    readOnly: true, // Disable manual text input
                    controller: TextEditingController(
                      text: widget.task.dueDate != null
                          ? DateFormat('dd MMM yyyy').format(widget.task.dueDate!)
                          : '', // Show selected date if available
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Repeat'),
                  value: widget.task.isRepeating,
                  onChanged: (value) {
                    setState(() {
                      widget.task.isRepeating = value;
                    });
                  },
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: _buildElevatedButtonAdd(context),
                  ),
                ),
              ],
            )),
      ),
    );
  }


}