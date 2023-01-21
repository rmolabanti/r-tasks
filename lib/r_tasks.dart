
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:r_tasks/auth_service.dart';
import 'package:r_tasks/task.dart';
import 'package:r_tasks/tasks_dao.dart';

import 'TaskItemWidget.dart';
import 'add_task_form.dart';

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
      tasksFuture = Future.value(widget.tasks);
    });
  }

  void _handleNewTask({required String name}) {
    var task = Task(uid: widget.uid, name: name);
    dao.addTask(task).then((updatedTask) => setState(() {
          widget.tasks.add(updatedTask);
          tasksFuture = Future.value(widget.tasks);
        }));
  }

  void _deleteCompleted() {
    log('deleting completed tasks');
    dao.deleteCompleted(widget.uid).then((list) => setState((){
      log('tasks count: ${widget.tasks.length}');
      widget.tasks.removeWhere((task) => list.any((element) => task.id == element.id));
      log('tasks count: ${widget.tasks.length}');
      tasksFuture = Future.value(widget.tasks);
    }));
  }

  @override
  void initState() {
    super.initState();
    tasksFuture = dao.getAll(widget.uid);
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: tasksFuture,
        builder: (context, snapshot) {
          log('snapshot has data: ${snapshot.hasData}');
          if (snapshot.hasData) {
            log('tasks count: ${widget.tasks.length}');
            for(var task in snapshot.data!){
              if(!widget.tasks.contains(task)){
                widget.tasks.add(task);
              }
            }
            log('tasks count: ${widget.tasks.length}');
            return buildScreen(widget.tasks);
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Transform.scale(
              scale: 0.1,
              child: const CircularProgressIndicator(strokeWidth: 20.0,),
            );
          }
        },
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
        child: ListView(
          children: [
            SizedBox(
            height: kToolbarHeight + 10,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).secondaryHeaderColor,
              ),
              child: const Text('Actions',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('delete'),
              onTap: (){
                _deleteCompleted();
                Navigator.pop(context);
              },
            ),
        ],
    ),
    );
    }

  buildScreen(List<Task> tasks) {
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
      drawer: buildDrawer(context),
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
}


