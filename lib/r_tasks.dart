import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:r_tasks/auth_service.dart';
import 'package:r_tasks/task.dart';
import 'package:r_tasks/tasks_dao.dart';

import 'add_task_form.dart';

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
      title: 'RM Tasks',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: TasksPage(
        title: '${user.displayName??'RM'} Tasks',
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
      dao.updateTask(task);
    });
  }

  void _handleNewTask({required String name}) {
    var task = Task(uid: widget.uid, name: name);
    dao.addTask(task).then((updatedTask) => setState(() {
          widget.tasks.add(updatedTask);
        }));
  }

  @override
  void initState() {
    super.initState();
    tasksFuture = dao.getAll(widget.uid);
  }

  @override
  Widget build(BuildContext context) {

    getView(List<Task> tasks) {

      for(var task in tasks){
        if(!widget.tasks.contains(task)){
          widget.tasks.add(task);
        }
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                iconSize: 35,
                color: Theme.of(context).scaffoldBackgroundColor,
                onPressed: () {
                  AuthService().signOut();
                },
              ),
            ],
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
        task.isDone=!task.isDone;
        onTaskChanged(task);
      },
      leading: CircleAvatar(
        backgroundColor:
            task.isDone ? Theme.of(context).primaryColorLight : Colors.blue,
        child: Text(task.rank.toString()),
      ),
      title: Text(
        task.name,
        style: _getTextStyle(context),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.exposure_plus_1_rounded),
            iconSize: 35,
            color: task.isDone ? Theme.of(context).disabledColor : Colors.green,
            onPressed: () {
              if(!task.isDone){
                task.rank=task.rank+1;
                onTaskChanged(task);
              }
            },
          ),
           IconButton(
            icon: const Icon(Icons.exposure_minus_1_rounded),
             iconSize: 35,
             color: task.isDone ? Theme.of(context).disabledColor : Colors.red,
            onPressed: () {
              if(!task.isDone) {
                task.rank = task.rank - 1;
                onTaskChanged(task);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            iconSize: 35,
            color: task.isDone ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColor,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: task.name));
            },
          ),
        ],
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
