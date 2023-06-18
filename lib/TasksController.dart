import 'dart:developer';

import 'package:get/get.dart';
import 'package:r_tasks/FocusListSettings.dart';
import 'package:r_tasks/task.dart';
import 'package:r_tasks/tasks_dao.dart';

class TasksController extends GetxController{
  final String uid;
  final RxSet<Task> tasks = <Task>{}.obs;
  final List<Task> allTasks = <Task>[].obs;
  final Set<Task> focusTasks = <Task>{}.obs;
  final Rx<FocusListSettings> focusListSettings;
  final TasksDao dao = TasksDao();

  TasksController(this.uid):
        focusListSettings = FocusListSettings(uid:uid).obs;

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

  void loadFocusTasks() async {
    focusTasks.clear();
    focusTasks.addAll(await dao.getFocusTasks(uid));
  }

  Set<Task> getFocusTasks() {
    return focusTasks;
  }

  RxSet<Task> getTasks(){
    return tasks;
  }

  void filterTasks(String query) {
    List<Task> filteredList = [];
    if (query.isNotEmpty) {
      for (var task in allTasks) {
        if (task.name.toLowerCase().contains(query.toLowerCase())||task.tags.any((element) => element.toLowerCase().contains(query.toLowerCase()))) {
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

  void handleNewTask(Task task) {
    dao.addTask(task).then((updatedTask){
      allTasks.add(updatedTask);
      tasks.add(updatedTask);
    });
  }

  void updateTask(Task task) {
    dao.updateTask(task).then((v){
      allTasks.removeWhere((element) => task.id == element.id);
      tasks.removeWhere((element) => task.id == element.id);
      allTasks.add(task);
      tasks.add(task);
    });
  }

  void refreshFocusTasks() async {
    log('Refresh focus tasks');
    List<Task> openTasks = allTasks.where((task) => !task.isDone).toList();
    openTasks.sort((a, b) => b.rank.compareTo(a.rank));
    List<Task> topTasks = openTasks.take(5).toList();

    loadFocusListSettings();
    for(String fTag in focusListSettings.value.tags){
      if(!topTasks.any((element) => element.tags.any((tag) => tag.toLowerCase() == fTag.toLowerCase()))){
        Task? tagTask = allTasks.firstWhere((element) => element.tags.any((tag) => tag.toLowerCase() == fTag.toLowerCase()),orElse: () => newTask());
        if(tagTask.id.isNotEmpty){
          var lastWhereTask = topTasks.lastWhere((element) => element.tags.isEmpty || element.tags.any((tag) => !focusListSettings.value.tags.any((fTag) => fTag.toLowerCase() == tag.toLowerCase())),orElse: () => topTasks.last);
          topTasks.remove(lastWhereTask);
          topTasks.add(tagTask);
        }
      }
    }
    await dao.updateFocusTasks(uid,topTasks);
    loadFocusTasks();
  }

  void handleTaskChange(Task task) {
    dao.updateTask(task);
    tasks.add(task);
    if(focusTasks.contains(task)){
      focusTasks.add(task);
    }
    if(task.isRepeating && task.isDone){
      var newTask = task.copyWith(rank: task.rank);
      handleNewTask(newTask);
    }
  }

  Task newTask() {
    return Task(uid: uid, name: '');
  }

  void loadFocusListSettings() async {
     FocusListSettings flsFromDB = await dao.getFocusListSettings(uid);
     focusListSettings(flsFromDB);
  }

  FocusListSettings getFocusListSettings() {
    return focusListSettings.value;
  }

  void addTag(String newTag) {
    focusListSettings.update((fls) {
      fls?.tags.add(newTag);
    });
  }

  void removeTag(String tag) {
    focusListSettings.update((fls) {
      fls?.tags.remove(tag);
    });
  }

  void saveFocusListSettings() async {
    var updateFocusListSettings = await dao.updateFocusListSettings(focusListSettings.value);
    focusListSettings(updateFocusListSettings);
  }

}