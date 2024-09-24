import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:holberton_app/todos/todos.dart';
import 'package:todos_repository/todos_repository.dart';

part 'todos_event.dart';
part 'todos_state.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  TodosBloc({
    required TodosRepository todosRepository,
  })  : _todosRepository = todosRepository,
        super(const TodosState()) {
    on<TodosSubscriptionRequested>(_onSubscriptionRequested);
    on<TodosTodoCompletionToggled>(_onTodoCompletionToggled);
    on<TodosTodoDeleted>(_onTodoDeleted);
    on<TodosUndoDeletionRequested>(_onUndoDeletionRequested);
    on<TodosFilterChanged>(_onFilterChanged);
    on<TodosToggleAllRequested>(_onToggleAllRequested);
    on<TodosClearCompletedRequested>(_onClearCompletedRequested);
  }

  final TodosRepository _todosRepository;

  Future<void> _onSubscriptionRequested(
    TodosSubscriptionRequested event,
    Emitter<TodosState> emit,
  ) async {
    emit(state.copyWith(status: () => TodosStatus.loading));

    await emit.forEach<List<Todo>>(
      _todosRepository.getTodos(),
      onData: (todos) => state.copyWith(
        status: () => TodosStatus.success,
        todos: () => todos,
      ),
      onError: (_, __) => state.copyWith(
        status: () => TodosStatus.failure,
      ),
    );
  }

  Future<void> _onTodoCompletionToggled(
    TodosTodoCompletionToggled event,
    Emitter<TodosState> emit,
  ) async {
    final newTodo = event.todo.copyWith(isCompleted: event.isCompleted);
    await _todosRepository.saveTodo(newTodo);
  }

  Future<void> _onTodoDeleted(
    TodosTodoDeleted event,
    Emitter<TodosState> emit,
  ) async {
    emit(state.copyWith(lastDeletedTodo: () => event.todo));
    await _todosRepository.deleteTodo(event.todo.id);
  }

  Future<void> _onUndoDeletionRequested(
    TodosUndoDeletionRequested event,
    Emitter<TodosState> emit,
  ) async {
    assert(
      state.lastDeletedTodo != null,
      'Last deleted todo can not be null.',
    );

    final todo = state.lastDeletedTodo!;
    emit(state.copyWith(lastDeletedTodo: () => null));
    await _todosRepository.saveTodo(todo);
  }

  void _onFilterChanged(
    TodosFilterChanged event,
    Emitter<TodosState> emit,
  ) {
    emit(state.copyWith(filter: () => event.filter));
  }

  Future<void> _onToggleAllRequested(
    TodosToggleAllRequested event,
    Emitter<TodosState> emit,
  ) async {
    final areAllCompleted = state.todos.every((todo) => todo.isCompleted);
    await _todosRepository.completeAll(isCompleted: !areAllCompleted);
  }

  Future<void> _onClearCompletedRequested(
    TodosClearCompletedRequested event,
    Emitter<TodosState> emit,
  ) async {
    await _todosRepository.clearCompleted();
  }
}
