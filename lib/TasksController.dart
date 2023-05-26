import 'dart:developer';

import 'package:get/get.dart';
import 'package:r_tasks/task.dart';
import 'package:r_tasks/tasks_dao.dart';

class TasksController extends GetxController{
  final String uid;
  final Set<Task> tasks = <Task>{}.obs;
  final List<Task> allTasks = <Task>[].obs;
  final Set<Task> focusTasks = <Task>{}.obs;
  final TasksDao dao = TasksDao();

  TasksController(this.uid);

  getAll(String uid) async {
    log('TasksController > getAll');
    allTasks.clear();
    List<Task> taskFromFS = await dao.getAll(uid);
    for(Task task in taskFromFS){
      if(!allTasks.contains(task)){
        allTasks.add(task);
      }
    }
    tasks.clear();
    tasks.addAll(allTasks);
  }

  Set<Task> getTasks(){
    return tasks;
  }

  void filterTasks(String query) {
    List<Task> filteredList = [];
    if (query.isNotEmpty) {
      for (var task in allTasks) {
        if (task.name.toLowerCase().contains(query.toLowerCase())) {
          filteredList.add(task);
        }
      }
    } else {
      filteredList = allTasks;
    }
    tasks.clear();
    tasks.addAll(filteredList);
  }

  void deleteCompleted(String uid) {
    log('TasksController > deleteCompleted > deleting completed tasks');
    dao.deleteCompleted(uid).then((list){
      log('TasksController > deleteCompleted > before allTasks: ${allTasks.length}');
      log('TasksController > deleteCompleted > before tasks: ${tasks.length}');
      allTasks.removeWhere((task) => list.any((element) => task.id == element.id));
      tasks.removeWhere((task) => list.any((element) => task.id == element.id));
      log('TasksController > deleteCompleted > after allTasks: ${allTasks.length}');
      log('TasksController > deleteCompleted > after tasks: ${tasks.length}');
    });
  }

  void handleNewTask(name) {
    var task = Task(uid: uid, name: name);
    dao.addTask(task).then((updatedTask){
      allTasks.add(updatedTask);
      tasks.add(updatedTask);
    });
  }

  void refreshFocusTasks() {
    log('Refresh focus tasks');
    dao.refreshFocusTasks(uid);
  }

}