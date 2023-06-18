
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:r_tasks/TasksController.dart';

class FocusListSettingsScreen extends StatefulWidget {
  final TasksController tasksController = Get.find();
  FocusListSettingsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FocusListSettingsScreenState();
}

class _FocusListSettingsScreenState extends State<FocusListSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TasksController tasksController = Get.find();
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tasksController.loadFocusListSettings();
  }

  void _addTag() {
    String newTag = _tagController.text.trim();
    if (newTag.isNotEmpty) {
      tasksController.addTag(newTag);
      _tagController.clear();
    }
  }

  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag),
      onDeleted: () {
        tasksController.removeTag(tag);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Focus List Settings")),
      body: Center(
        child: Form(
            key: _formKey,
            child: Column(
              children: [
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
                Obx(() => Wrap(
                  spacing: 8,
                  children:tasksController.getFocusListSettings().tags.map((tag) => _buildTagChip(tag)).toList(),
                )),
                SwitchListTile(
                  title: const Text('One oldest task'),
                  value: true,
                  onChanged: (value) {
                    setState(() {
                    });
                  },
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          tasksController.saveFocusListSettings();
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text("Save"),
                    ),
                  ),
                ),
              ],
            )
        )
      ),
    );
  }
}

