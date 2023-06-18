import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r_tasks/FocusListSettings.dart';
import 'package:r_tasks/task.dart';

class TasksDao{

  Future<List<Task>> getAll(String uid) async{
    log('getAll');
    var tasksCollection = FirebaseFirestore.instance.collection("tasks");
    var tasksSnapshot = await tasksCollection.where("uid",isEqualTo: uid).orderBy('rank',descending: true).get();
    var tasks = tasksSnapshot.docs.map((e) => Task.fromMap(e.id,e.data())).toList();
    return tasks;
  }

  Future<List<Task>> getFocusTasks(String uid) async{
    log('getFocusTasks');
    var tasksCollection = FirebaseFirestore.instance.collection("focus_tasks");
    var tasksSnapshot = await tasksCollection.where("uid",isEqualTo: uid).orderBy('rank',descending: true).get();
    var tasks = tasksSnapshot.docs.map((e) => Task.fromMap(e.id,e.data())).toList();
    log('getFocusTasks 21');
    return tasks;
  }

  Future<List<Task>> deleteCompleted(String uid) async {
    var tasksCollection = FirebaseFirestore.instance.collection("tasks");
    var tasksSnapshot = await tasksCollection.where("uid",isEqualTo: uid).where("isDone",isEqualTo: true).get();
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    List<Task> deleteTasks = [];
    for (var doc in tasksSnapshot.docs) {
      deleteTasks.add(Task.fromMap(doc.id, doc.data()));
      batch.delete(doc.reference);
    }
    batch.commit();

    var focusTasksCollection = FirebaseFirestore.instance.collection("focus_tasks");
    var focusTasksSnapshot = await focusTasksCollection.where("uid",isEqualTo: uid).where("isDone",isEqualTo: true).get();
    final WriteBatch focusBatch = FirebaseFirestore.instance.batch();
    List<Task> focusDeleteTasks = [];
    for (var doc in focusTasksSnapshot.docs) {
      focusDeleteTasks.add(Task.fromMap(doc.id, doc.data()));
      focusBatch.delete(doc.reference);
    }
    focusBatch.commit();

    return deleteTasks;
  }

  Future<Task> addTask(Task task) async {
    var tasks = FirebaseFirestore.instance.collection("tasks");
    var ref = await tasks.add(task.toMap());
    var snapshot = await ref.get();
    var newTask = Task.fromMap(snapshot.id,snapshot.data()!);
    return newTask;
  }

  Future<void>  updateTask(Task task) async {
    var tasks = FirebaseFirestore.instance.collection("tasks");
    var ref = tasks.doc(task.id);
    var snapshot = await ref.update(task.toMap());

    var focusTasks = FirebaseFirestore.instance.collection("focus_tasks");
    DocumentSnapshot fdSnapshot = await focusTasks.doc(task.id).get();
    if(fdSnapshot.exists){
      await focusTasks.doc(task.id).update(task.toMap());
    }
    return snapshot;
  }

  Future<void> updateFocusTasks(String uid,List<Task> topTasks) async {
    var focusTasksCollection = FirebaseFirestore.instance.collection("focus_tasks");

    var focusTasksSnapshot = await focusTasksCollection.where("uid",isEqualTo: uid).get();
    final WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var doc in focusTasksSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.commit();

    for (Task task in topTasks) {
      final documentReference = focusTasksCollection.doc(task.id);
      await documentReference.set(task.toMap());
    }
  }

  Future<FocusListSettings> getFocusListSettings(String uid) async {
    var focusListSettingsCollection = FirebaseFirestore.instance.collection("focus_list_settings");
    var focusListSettingsSnapshot = await focusListSettingsCollection.where("uid",isEqualTo: uid).get();
    if(focusListSettingsSnapshot.docs.isNotEmpty){
      var documentSnapshot = focusListSettingsSnapshot.docs.first;
      return FocusListSettings.fromMap(documentSnapshot.id, documentSnapshot.data());
    }else{
      return FocusListSettings(uid: uid);
    }
  }

  Future<FocusListSettings> updateFocusListSettings(FocusListSettings focusListSettings) async {
    var focusListSettingsCollection = FirebaseFirestore.instance.collection("focus_list_settings");
    if(focusListSettings.id.isEmpty){
      var ref = await focusListSettingsCollection.add(focusListSettings.toMap());
      var snapshot = await ref.get();
      var fls = FocusListSettings.fromMap(snapshot.id,snapshot.data()!);
      return fls;
    }else{
      var ref = focusListSettingsCollection.doc(focusListSettings.id);
      await ref.update(focusListSettings.toMap());
      return focusListSettings;
    }
  }

}


