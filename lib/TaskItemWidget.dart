import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:r_tasks/task.dart';

import 'add_task_form.dart';

class TaskItem extends StatelessWidget {
  TaskItem({required this.task, required this.onTaskChanged})
      : super(key: ObjectKey(task));

  final Task task;
  final void Function(Task) onTaskChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        task.isDone=!task.isDone;
        onTaskChanged(task);
      },
      leading: CircleAvatar(
        backgroundColor:
        task.isDone ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorDark,
        child: Text(task.rank.toString(),style: const TextStyle(color: Colors.black)),
      ),
      title: Text(
        task.name,
        style: _getTextStyle(context),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.exposure_plus_1_rounded),
            iconSize: 35,
            color: task.isDone ? Theme.of(context).disabledColor : Colors.green,
            onPressed: () {
              if(!task.isDone){
                task.rank=task.rank+1;
                onTaskChanged(task);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.exposure_minus_1_rounded),
            iconSize: 35,
            color: task.isDone ? Theme.of(context).disabledColor : Colors.red,
            onPressed: () {
              if(!task.isDone) {
                task.rank = task.rank - 1;
                onTaskChanged(task);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            iconSize: 35,
            color: task.isDone ? Theme.of(context).disabledColor : Colors.red,
            onPressed: () {
              if(!task.isDone) {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddTaskForm(task:task)));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            iconSize: 35,
            color: task.isDone ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColor,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: task.name));
            },
          ),
        ],
      ),
    );
  }

  TextStyle? _getTextStyle(BuildContext context) {
    if (!task.isDone) return null;
    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }
}