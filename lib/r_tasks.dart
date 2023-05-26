
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:r_tasks/TasksController.dart';
import 'package:r_tasks/TimerScreen.dart';
import 'package:r_tasks/auth_service.dart';
import 'package:r_tasks/task.dart';
import 'package:r_tasks/tasks_dao.dart';

import 'FocusScreen.dart';
import 'HomeScreen.dart';
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
      ),
    );
  }
}

class TasksPage extends StatefulWidget {
  final String uid;
  final String title;
  final TasksController tasksController;

  TasksPage({super.key, required this.title, required this.uid,}): tasksController = Get.put(TasksController(uid));

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  int _currentIndex = 1;
  List<Task> tasks = [];
  final TasksDao dao = TasksDao();

  final PageController _pageController = PageController(initialPage: 1);

  void _onPageChanged(index) {
    setState(() {
      log('onPageChanged > _currentIndex: $index');
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      log('_onItemTapped > _currentIndex: $index');
      _currentIndex = index;
      _pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  void _handleTaskChange(Task task) {
    setState(() {
      log('_handleTaskChange: ${task.isDone}');
      dao.updateTask(task);
      log('_handleTaskChange: ${tasks.map((e) => e.isDone)}');
    });
  }

  @override
  void initState() {
    super.initState();
    tasks = [];
  }

  @override
  Widget build(BuildContext context) {
    return buildScreen();
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
                widget.tasksController.deleteCompleted(widget.uid);
                setState(() {});
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Focus List'),
              onTap: (){
                widget.tasksController.refreshFocusTasks();
                Navigator.pop(context);
              },
            ),
        ],
    ),
    );
    }

  buildScreen() {

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
      //body: buildAllTasksView(),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          HomeScreenPage(uid:widget.uid,onTaskChange: _handleTaskChange,tasks: tasks),
          FocusScreen(uid:widget.uid, onTaskChange: _handleTaskChange,),
          const StopwatchPage(),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddTaskForm()));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tips_and_updates),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


