import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:r_tasks/task.dart';
import 'package:r_tasks/tasks_dao.dart';

// Future<void> main() async {
//   runApp(const TasksHome());
// }

class TasksHome extends StatelessWidget {
  final User user;

  const TasksHome({super.key, required this.user});

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
        uid: user.uid,
        tasks: [],
      ),
    );
  }
}

class TasksPage extends StatefulWidget {
  final String uid;
  final String title;
  final List<Task> tasks;

  const TasksPage(
      {super.key, required this.title, required this.uid, required this.tasks});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TasksDao dao = TasksDao();
  late Future<List<Task>> tasksFuture;

  void _handleTaskChange(Task task) {
    setState(() {
      task.isDone = !task.isDone;
    });
  }

  void _handleNewTask({required String name}) {
    setState(() {
      var task = Task(uid: widget.uid, name: name);
      widget.tasks.add(task);
      dao.addTask(task);
    });
  }

  @override
  void initState() {
    super.initState();
    tasksFuture = dao.getAll();
  }

  @override
  Widget build(BuildContext context) {

    getView(List<Task> tasks) {
      tasks.forEach((task) {
        if(!widget.tasks.contains(task)){
          widget.tasks.add(task);
        }
      });
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: widget.tasks.map((task) {
            return TaskItem(
              task: task,
              onTaskChanged: _handleTaskChange,
            );
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    AddTaskForm(onTaskAdded: _handleNewTask)));
          },
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
    }

    return FutureBuilder(
        future: tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return getView(snapshot.data!);
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return CircularProgressIndicator();
          }
        },
    );
  }
}

class TaskItem extends StatelessWidget {
  TaskItem({required this.task, required this.onTaskChanged})
      : super(key: ObjectKey(task));

  final Task task;
  final void Function(Task) onTaskChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTaskChanged(task);
      },
      leading: CircleAvatar(
        backgroundColor:
            task.isDone ? Colors.black54 : Theme.of(context).primaryColor,
        child: Text(task.name[0]),
      ),
      title: Text(
        task.name,
        style: _getTextStyle(context),
      ),
    );
  }

  TextStyle? _getTextStyle(BuildContext context) {
    if (!task.isDone) return null;
    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }
}

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
                            widget.onTaskAdded(name: addTaskController.text);
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
