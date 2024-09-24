import 'package:todos_repository/todos_repository.dart';

enum TodosFilter { all, activeOnly, completedOnly }

extension TodosViewFilterX on TodosFilter {
  bool apply(Todo todo) {
    switch (this) {
      case TodosFilter.all:
        return true;
      case TodosFilter.activeOnly:
        return !todo.isCompleted;
      case TodosFilter.completedOnly:
        return todo.isCompleted;
    }
  }

  Iterable<Todo> applyAll(Iterable<Todo> todos) {
    return todos.where(apply);
  }
}