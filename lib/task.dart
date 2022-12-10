class Task {
  String uid='';
  String name='';
  bool isDone=false;

  Task({required this.uid,required this.name});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'isDone': isDone,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    Task task = Task(uid: map['uid'], name: map['name']);
    task.isDone =map['isDone'];
    return task;
  }

}