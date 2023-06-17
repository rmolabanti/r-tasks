
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:r_tasks/TasksController.dart';
import 'package:r_tasks/TimerScreen.dart';
import 'package:r_tasks/auth_service.dart';

import 'FocusScreen.dart';
import 'HomeScreen.dart';
import 'add_task_form.dart';

class AppHome extends StatelessWidget {
  final User user;

  const AppHome({super.key, required this.user});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RM Tasks',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: AppLayout(
        title: '${user.displayName??'RM'} Tasks',
        uid: user.uid,
      ),
    );
  }
}

class AppLayout extends StatefulWidget {
  final String uid;
  final String title;
  final TasksController tasksController;

  AppLayout({super.key, required this.title, required this.uid,}): tasksController = Get.put(TasksController(uid));

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _currentIndex = 1;
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          buildLogoutButton(context),
        ],
      ),
      drawer: buildDrawer(context),
      //body: buildAllTasksView(),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          HomeScreenPage(uid:widget.uid),
          FocusScreen(uid:widget.uid),
          const StopwatchPage(),
        ],
      ),
      floatingActionButton: buildAddTaskFloatingActionButton(context),
      bottomNavigationBar: buildBottomNavigationBar(),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
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
    );
  }

  FloatingActionButton buildAddTaskFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddTaskForm(task:widget.tasksController.newTask())));
      },
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    );
  }

  IconButton buildLogoutButton(BuildContext context) {
    return IconButton(
          icon: const Icon(Icons.logout_rounded),
          iconSize: 35,
          color: Theme.of(context).scaffoldBackgroundColor,
          onPressed: () {
            AuthService().signOut();
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
}


