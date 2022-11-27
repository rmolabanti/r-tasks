import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  runApp(const TasksHome());
}

class Task {
  Task({required this.name});
  String name;
  bool isDone=false;
}

class TasksHome extends StatelessWidget {
  const TasksHome({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'R Tasks',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: TasksPage(
        title: 'R Tasks',
        tasks: [Task(name: "Task1"), Task(name: "Task2")],
      ),
    );
  }
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key, required this.title, required this.tasks});
  final String title;
  final List<Task> tasks;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {

  void _handleTaskChange(Task task) {
    setState(() {
      task.isDone=!task.isDone;
    });
  }

  void _handleNewTask(Task task) {
    setState(() {
      widget.tasks.add(task);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: widget.tasks.map((task) {
          return TaskItem(task:task,onTaskChanged: _handleTaskChange,);
        }).toList(),

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddTaskForm(onTaskAdded:_handleNewTask)));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TaskItem extends StatelessWidget {
  TaskItem({required this.task,required this.onTaskChanged}) : super(key: ObjectKey(task));

  final Task task;
  final void Function(Task) onTaskChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){onTaskChanged(task);},
      leading: CircleAvatar(
        backgroundColor: task.isDone?Colors.black54:Theme.of(context).primaryColor,
        child: Text(task.name[0]),
      ),
      title: Text(
        task.name,
        style: _getTextStyle(context),
      ),
    );
  }

  TextStyle? _getTextStyle(BuildContext context) {
    if(!task.isDone) return null;
    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }
}

class AddTaskForm extends StatefulWidget{
  const AddTaskForm({super.key, required this.onTaskAdded});
  final void Function(Task) onTaskAdded;

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
                TextFormField(
                  controller: addTaskController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
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
                            widget.onTaskAdded(Task(name: addTaskController.text));
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text("Add")),
                  ),
                ),
          ],
        )),
      ),
    );
  }
}
