class Task {
  String id='';
  String uid='';
  String name='';
  bool isDone=false;
  int rank=0;

  Task({required this.uid,required this.name});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'isDone': isDone,
      'rank':rank,
    };
  }

  static Task fromMap(String id,Map<String, dynamic> map) {
    Task task = Task(uid: map['uid'], name: map['name']);
    task.id=id;
    task.isDone =map['isDone'];
    task.rank =map['rank']??0;
    return task;
  }

}