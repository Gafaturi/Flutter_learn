import 'package:flutter/material.dart';
import 'models/todo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      theme: ThemeData(useMaterial3: true),
      home: const TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() {
    return _TodoPageState();
  }
}

class _TodoPageState extends State<TodoPage> {
  final TodoManager manager = TodoManager();

  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  Priority selectedPriority = Priority.medium;

  Priority? priorityFilter;
  AddedDateFilter dateFilter = AddedDateFilter.all;
  bool newestFirst = true;

  int tabIndex = 0;

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  ViewMode currentViewMode() {
    if (tabIndex == 1) {
      return ViewMode.completed;
    }
    if (tabIndex == 2) {
      return ViewMode.trash;
    }
    return ViewMode.active;
  }

  void onTabChanged(int index) {
    setState(() {
      tabIndex = index;
    });
  }

  void onPriorityChanged(Priority? p) {
    setState(() {
      if (p == null) {
        selectedPriority = Priority.medium;
      } else {
        selectedPriority = p;
      }
    });
  }

  void onPriorityFilterChanged(Priority? p) {
    setState(() {
      priorityFilter = p;
    });
  }

  void onDateFilterChanged(AddedDateFilter? f) {
    setState(() {
      if (f == null) {
        dateFilter = AddedDateFilter.all;
      } else {
        dateFilter = f;
      }
    });
  }

  void toggleDateSort() {
    setState(() {
      newestFirst = !newestFirst;
    });
  }

  // 1) Syntactic sugar ??= + 4.1) factory used in real flow.
  void addTodo() {
    String rawTitle = titleCtrl.text.trim();
    String? title;

    if (rawTitle.isEmpty) {
      title = null;
    } else {
      title = rawTitle;
    }

    title ??= 'Untitled'; // 1) ??=

    String rawDesc = descCtrl.text.trim();
    String? description;

    if (rawDesc.isEmpty) {
      description = null;
    } else {
      description = rawDesc;
    }

    // 1) ??= again (easy to show on video).
    description ??= 'No description';

    // 4.1) Factory constructor usage (Map -> Todo).
    Map<String, dynamic> map = <String, dynamic>{};
    map['title'] = title;
    map['description'] = description;
    map['priority'] = selectedPriority.name;
    map['isDone'] = false;
    map['isDeleted'] = false;

    Todo todo = Todo.fromMap(map);
    manager.add(todo);

    setState(() {
      titleCtrl.clear();
      descCtrl.clear();
      selectedPriority = Priority.medium;
      tabIndex = 0;
    });
  }

  void toggleDone(int id) {
    setState(() {
      manager.toggleDone(id);
    });
  }

  void moveToTrash(int id) {
    setState(() {
      manager.moveToTrash(id);
    });
  }

  void restoreFromTrash(int id) {
    setState(() {
      manager.restoreFromTrash(id);
    });
  }

  void deleteForever(int id) {
    setState(() {
      manager.deleteForever(id);
    });
  }

  Widget buildPriorityDropdown() {
    List<DropdownMenuItem<Priority>> items = <DropdownMenuItem<Priority>>[];

    for (int i = 0; i < Priority.values.length; i++) {
      Priority p = Priority.values[i];
      DropdownMenuItem<Priority> item = DropdownMenuItem<Priority>(
        value: p,
        child: Text(p.name),
      );
      items.add(item);
    }

    return DropdownButton<Priority>(
      value: selectedPriority,
      onChanged: onPriorityChanged,
      items: items,
    );
  }

  Widget buildPriorityFilterDropdown() {
    List<DropdownMenuItem<Priority?>> items = <DropdownMenuItem<Priority?>>[];

    items.add(
      const DropdownMenuItem<Priority?>(
        value: null,
        child: Text('All priorities'),
      ),
    );

    for (int i = 0; i < Priority.values.length; i++) {
      Priority p = Priority.values[i];
      DropdownMenuItem<Priority?> item = DropdownMenuItem<Priority?>(
        value: p,
        child: Text(p.name),
      );
      items.add(item);
    }

    return DropdownButton<Priority?>(
      value: priorityFilter,
      onChanged: onPriorityFilterChanged,
      items: items,
    );
  }

  String dateFilterLabel(AddedDateFilter f) {
    if (f == AddedDateFilter.today) {
      return 'Today';
    }
    if (f == AddedDateFilter.last7days) {
      return 'Last 7 days';
    }
    return 'All dates';
  }

  Widget buildDateFilterDropdown() {
    List<DropdownMenuItem<AddedDateFilter>> items =
        <DropdownMenuItem<AddedDateFilter>>[];

    for (int i = 0; i < AddedDateFilter.values.length; i++) {
      AddedDateFilter f = AddedDateFilter.values[i];
      DropdownMenuItem<AddedDateFilter> item =
          DropdownMenuItem<AddedDateFilter>(
            value: f,
            child: Text(dateFilterLabel(f)),
          );
      items.add(item);
    }

    return DropdownButton<AddedDateFilter>(
      value: dateFilter,
      onChanged: onDateFilterChanged,
      items: items,
    );
  }

  Widget buildDateSortButton() {
    String label;
    if (newestFirst) {
      label = 'Newest first';
    } else {
      label = 'Oldest first';
    }

    return ElevatedButton(onPressed: toggleDateSort, child: Text(label));
  }

  Widget buildInputForm() {
    bool canAdd;
    if (currentViewMode() == ViewMode.trash) {
      canAdd = false;
    } else {
      canAdd = true;
    }

    return Column(
      children: <Widget>[
        TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: descCtrl,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            const Text('Priority:'),
            const SizedBox(width: 10),
            buildPriorityDropdown(),
            const Spacer(),
            ElevatedButton(
              onPressed: canAdd ? addTodo : null,
              child: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildFiltersRow() {
    return Row(
      children: <Widget>[
        buildPriorityFilterDropdown(),
        const SizedBox(width: 12),
        buildDateFilterDropdown(),
        const SizedBox(width: 12),
        buildDateSortButton(),
      ],
    );
  }

  List<Todo> buildVisibleItems() {
    List<Todo> items = manager.todos;

    ViewMode mode = currentViewMode();
    items = manager.filterByViewMode(items, mode);

    items = manager.filterByPriority(items, priorityFilter);

    // 2) Use closure-based filter in real flow when filter is set.
    if (priorityFilter != null) {
      items = manager.filterUsingClosure(items, priorityFilter!);
    }

    items = manager.filterByAddedDate(items, dateFilter);
    items = manager.sortByAddedDate(items, newestFirst);

    return items;
  }

  Widget buildTodoItem(Todo t) {
    String subtitleText;
    if (t.description == null) {
      subtitleText = 'No description';
    } else {
      subtitleText = t.description!;
    }

    subtitleText = subtitleText + ' | priority=' + t.priority.name;

    TextDecoration? decoration;
    if (t.isDone) {
      decoration = TextDecoration.lineThrough;
    } else {
      decoration = null;
    }

    Widget leadingWidget;
    if (currentViewMode() == ViewMode.trash) {
      leadingWidget = const Icon(Icons.delete);
    } else {
      leadingWidget = Checkbox(
        value: t.isDone,
        onChanged: (bool? _) {
          toggleDone(t.id);
        },
      );
    }

    List<Widget> trailingButtons = <Widget>[];

    if (currentViewMode() == ViewMode.trash) {
      trailingButtons.add(
        IconButton(
          icon: const Icon(Icons.restore),
          onPressed: () {
            restoreFromTrash(t.id);
          },
        ),
      );
      trailingButtons.add(
        IconButton(
          icon: const Icon(Icons.delete_forever),
          onPressed: () {
            deleteForever(t.id);
          },
        ),
      );
    } else {
      trailingButtons.add(
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            moveToTrash(t.id);
          },
        ),
      );
    }

    Widget trailingWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: trailingButtons,
    );

    return Card(
      child: ListTile(
        leading: leadingWidget,
        title: Text(t.title, style: TextStyle(decoration: decoration)),
        subtitle: Text(subtitleText),
        trailing: trailingWidget,
      ),
    );
  }

  Widget buildTodoList() {
    List<Todo> items = buildVisibleItems();

    String emptyText;
    if (currentViewMode() == ViewMode.trash) {
      emptyText = 'Trash is empty';
    } else if (currentViewMode() == ViewMode.completed) {
      emptyText = 'No completed tasks';
    } else {
      emptyText = 'No active tasks';
    }

    if (items.isEmpty) {
      return Center(child: Text(emptyText));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        Todo t = items[index];
        return buildTodoItem(t);
      },
    );
  }

  String appBarTitle() {
    ViewMode mode = currentViewMode();
    if (mode == ViewMode.completed) {
      return 'To-Do App — Completed';
    }
    if (mode == ViewMode.trash) {
      return 'To-Do App — Trash';
    }
    return 'To-Do App — Active';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle())),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            buildInputForm(),
            const SizedBox(height: 10),
            buildFiltersRow(),
            const Divider(),
            Expanded(child: buildTodoList()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabIndex,
        onTap: onTabChanged,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Active'),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Completed'),
          BottomNavigationBarItem(icon: Icon(Icons.delete), label: 'Trash'),
        ],
      ),
    );
  }
}
