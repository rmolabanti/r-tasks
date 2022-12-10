import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r_tasks/task.dart';

class TasksDao{

  Future<Task> addTask(Task task) async {
    var tasks = FirebaseFirestore.instance.collection("tasks");
    var ref = await tasks.add(task.toMap());
    var snapshot = await ref.get();
    var newTask = Task.fromMap(snapshot.data()!);
    return newTask;
  }

  Future<List<Task>> getAll() async{
    var tasksCollection = FirebaseFirestore.instance.collection("tasks");
    var tasksSnapshot = await tasksCollection.get();
    var tasks = tasksSnapshot.docs.map((e) => Task.fromMap(e.data())).toList();
    return tasks;
  }
}


