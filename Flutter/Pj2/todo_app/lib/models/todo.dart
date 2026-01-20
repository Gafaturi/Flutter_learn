// default params, assert, initializer list, factory, mixins, closures, collections

// Priority
enum Priority { low, medium, high }

// Date filter for "added at" time
enum AddedDateFilter { all, today, last7days }

// UI: active / completed / trash
enum ViewMode { active, completed, trash }

class Todo {
  final int id;
  final DateTime createdAt;

  String title;
  String? description;
  bool isDone;
  bool isDeleted;
  Priority priority;

  // Default param + assert + initializer list
  Todo(
    this.title, {
    this.description,
    bool isDone = false,
    bool isDeleted = false,
    Priority priority = Priority.medium,
  }) : assert(title.trim().isNotEmpty),
       id = DateTime.now().millisecondsSinceEpoch,
       createdAt = DateTime.now(),
       isDone = isDone,
       isDeleted = isDeleted,
       priority = priority;

  // Factory constructor (create Todo from Map-like data)
  factory Todo.fromMap(Map<String, dynamic> map) {
    dynamic rawTitle = map['title'];
    String? title;

    if (rawTitle is String) {
      String trimmed = rawTitle.trim();
      if (trimmed.isEmpty) {
        title = null;
      } else {
        title = trimmed;
      }
    } else {
      title = null;
    }

    title ??= 'Untitled'; // syntactic sugar ??=

    dynamic rawDesc = map['description'];
    String? description;

    if (rawDesc is String) {
      String trimmedDesc = rawDesc.trim();
      if (trimmedDesc.isEmpty) {
        description = null;
      } else {
        description = trimmedDesc;
      }
    } else {
      description = null;
    }

    dynamic rawIsDone = map['isDone'];
    bool isDone;

    if (rawIsDone is bool) {
      isDone = rawIsDone;
    } else {
      isDone = false;
    }

    dynamic rawIsDeleted = map['isDeleted'];
    bool isDeleted;

    if (rawIsDeleted is bool) {
      isDeleted = rawIsDeleted;
    } else {
      isDeleted = false;
    }

    dynamic rawPriority = map['priority'];
    Priority priority;

    if (rawPriority is String) {
      String p = rawPriority.toLowerCase();
      if (p == 'low') {
        priority = Priority.low;
      } else if (p == 'high') {
        priority = Priority.high;
      } else {
        priority = Priority.medium;
      }
    } else if (rawPriority is int) {
      if (rawPriority == 0) {
        priority = Priority.low;
      } else if (rawPriority == 2) {
        priority = Priority.high;
      } else {
        priority = Priority.medium;
      }
    } else {
      priority = Priority.medium;
    }

    Todo todo = Todo(
      title,
      description: description,
      isDone: isDone,
      isDeleted: isDeleted,
      priority: priority,
    );

    return todo;
  }
}

// Mixin example
mixin LoggerMixin {
  void log(String message) {
    // ignore: avoid_print
    print('[LOG] ' + message);
  }
}

class TodoManager with LoggerMixin {
  // Collections: List + Map + Set
  final List<Todo> _todos = <Todo>[];
  final Map<int, Todo> _byId = <int, Todo>{};

  // Additional collections: id in completed/trash
  final Set<int> _completedIds = <int>{};
  final Set<int> _deletedIds = <int>{};

  List<Todo> get todos {
    List<Todo> copy = <Todo>[];
    for (int i = 0; i < _todos.length; i++) {
      copy.add(_todos[i]);
    }
    return copy;
  }

  void add(Todo todo) {
    _todos.add(todo);
    _byId[todo.id] = todo;

    if (todo.isDone) {
      _completedIds.add(todo.id);
    }
    if (todo.isDeleted) {
      _deletedIds.add(todo.id);
    }

    log('Added todo id=' + todo.id.toString());
  }

  void toggleDone(int id) {
    Todo? todo = _byId[id];
    if (todo == null) {
      return;
    }
    if (todo.isDeleted) {
      return;
    }

    if (todo.isDone == true) {
      todo.isDone = false;
      _completedIds.remove(id);
    } else {
      todo.isDone = true;
      _completedIds.add(id);
    }

    log('Toggled done id=' + id.toString());
  }

  void moveToTrash(int id) {
    Todo? todo = _byId[id];
    if (todo == null) {
      return;
    }

    todo.isDeleted = true;
    _deletedIds.add(id);

    log('Moved to trash id=' + id.toString());
  }

  void restoreFromTrash(int id) {
    Todo? todo = _byId[id];
    if (todo == null) {
      return;
    }

    todo.isDeleted = false;
    _deletedIds.remove(id);

    log('Restored from trash id=' + id.toString());
  }

  void deleteForever(int id) {
    int indexToRemove = -1;

    for (int i = 0; i < _todos.length; i++) {
      Todo t = _todos[i];
      if (t.id == id) {
        indexToRemove = i;
        break;
      }
    }

    if (indexToRemove != -1) {
      _todos.removeAt(indexToRemove);
    }

    _byId.remove(id);
    _completedIds.remove(id);
    _deletedIds.remove(id);

    log('Deleted forever id=' + id.toString());
  }

  List<Todo> filterByPriority(List<Todo> input, Priority? priority) {
    if (priority == null) {
      return input;
    }

    List<Todo> result = <Todo>[];

    for (int i = 0; i < input.length; i++) {
      Todo t = input[i];
      if (t.priority == priority) {
        result.add(t);
      }
    }

    return result;
  }

  List<Todo> filterByAddedDate(List<Todo> input, AddedDateFilter filter) {
    if (filter == AddedDateFilter.all) {
      return input;
    }

    DateTime now = DateTime.now();
    DateTime start;

    if (filter == AddedDateFilter.today) {
      start = DateTime(now.year, now.month, now.day);
    } else {
      DateTime todayStart = DateTime(now.year, now.month, now.day);
      start = todayStart.subtract(const Duration(days: 6));
    }

    List<Todo> result = <Todo>[];

    for (int i = 0; i < input.length; i++) {
      Todo t = input[i];
      if (t.createdAt.isAfter(start) || t.createdAt.isAtSameMomentAs(start)) {
        result.add(t);
      }
    }

    return result;
  }

  List<Todo> sortByAddedDate(List<Todo> input, bool newestFirst) {
    List<Todo> sorted = <Todo>[];
    for (int i = 0; i < input.length; i++) {
      sorted.add(input[i]);
    }

    for (int i = 0; i < sorted.length - 1; i++) {
      for (int j = i + 1; j < sorted.length; j++) {
        bool needSwap;

        if (newestFirst) {
          needSwap = sorted[i].createdAt.isBefore(sorted[j].createdAt);
        } else {
          needSwap = sorted[i].createdAt.isAfter(sorted[j].createdAt);
        }

        if (needSwap) {
          Todo temp = sorted[i];
          sorted[i] = sorted[j];
          sorted[j] = temp;
        }
      }
    }

    return sorted;
  }

  List<Todo> filterByViewMode(List<Todo> input, ViewMode mode) {
    List<Todo> result = <Todo>[];

    for (int i = 0; i < input.length; i++) {
      Todo t = input[i];

      if (mode == ViewMode.trash) {
        if (t.isDeleted == true) {
          result.add(t);
        }
      } else if (mode == ViewMode.completed) {
        if (t.isDeleted == false && t.isDone == true) {
          result.add(t);
        }
      } else {
        if (t.isDeleted == false && t.isDone == false) {
          result.add(t);
        }
      }
    }

    return result;
  }

  // Closure: returns a function that uses captured "priority"
  bool Function(Todo) priorityFilter(Priority priority) {
    bool filter(Todo t) {
      return t.priority == priority;
    }

    return filter;
  }

  // Using the closure
  List<Todo> filterUsingClosure(List<Todo> input, Priority priority) {
    bool Function(Todo) f = priorityFilter(priority);

    List<Todo> result = <Todo>[];
    for (int i = 0; i < input.length; i++) {
      Todo t = input[i];
      if (f(t)) {
        result.add(t);
      }
    }
    return result;
  }
}
