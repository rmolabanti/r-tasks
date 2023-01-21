import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r_tasks/task.dart';

class TasksDao{

  Future<List<Task>> getAll(String uid) async{
    log('getAll');
    var tasksCollection = FirebaseFirestore.instance.collection("tasks");
    var tasksSnapshot = await tasksCollection.where("uid",isEqualTo: uid).orderBy('rank',descending: true).get();
    var tasks = tasksSnapshot.docs.map((e) => Task.fromMap(e.id,e.data())).toList();
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
    return snapshot;
  }


}


