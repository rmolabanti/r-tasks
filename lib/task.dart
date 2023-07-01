import 'package:intl/intl.dart';

class Task {
  String id='';
  String uid='';
  String name='';
  bool isDone=false;
  int rank=0;
  List<String> tags=[];
  bool isRepeating=false;
  DateTime createdDate;
  DateTime? dueDate;

  Task({required this.uid,required this.name}):createdDate=DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'isDone': isDone,
      'rank':rank,
      'tags':tags,
      'isRepeating':isRepeating,
      'createdDate':createdDate.millisecondsSinceEpoch,
      'dueDate':dueDate?.millisecondsSinceEpoch
    };
  }

  static Task fromMap(String id,Map<String, dynamic> map) {
    Task task = Task(uid: map['uid'], name: map['name']);
    task.id=id;
    task.isDone =map['isDone'];
    task.rank =map['rank']??0;
    task.isRepeating =map['isRepeating']??false;
    task.createdDate =DateTime.fromMillisecondsSinceEpoch(map['createdDate']??DateTime.now().millisecondsSinceEpoch);
    task.dueDate =map['dueDate']!=null?DateTime.fromMillisecondsSinceEpoch(map['dueDate']):null;
    task.tags =map['tags']!=null?map['tags'].cast<String>():[];
    return task;
  }

  Task copyWith({int? rank, bool? isRepeating}) {
    Task task = Task( uid: uid, name: name);
    task.isRepeating=isRepeating??this.isRepeating;
    task.rank=rank??this.rank;
    task.tags=tags;
    task.dueDate=dueDate;
    return task;
  }

  String formatedDate() {
    final format = DateFormat("dd MMM");
    final formattedDate = format.format(createdDate);
    return formattedDate;
  }

}