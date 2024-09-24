import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holberton_app/edit_todo/edit_todo.dart';
import 'package:holberton_app/todos/todos.dart';
import 'package:holberton_app/l10n/l10n.dart';
import 'package:todos_repository/todos_repository.dart';


class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodosBloc(
        todosRepository: context.read<TodosRepository>(),
      )..add(const TodosSubscriptionRequested()),
      child: const TodosView(),
    );
  }
}

class TodosView extends StatelessWidget {
  const TodosView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todosAppBarTitle),
        actions: const [
          TodosFilterButton(),
          TodosOptionsButton(),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<TodosBloc, TodosState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == TodosStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.todosErrorSnackbarText),
                    ),
                  );
              }
            },
          ),
          BlocListener<TodosBloc, TodosState>(
            listenWhen: (previous, current) =>
                previous.lastDeletedTodo != current.lastDeletedTodo &&
                current.lastDeletedTodo != null,
            listener: (context, state) {
              final deletedTodo = state.lastDeletedTodo!;
              final messenger = ScaffoldMessenger.of(context);
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.todosTodoDeletedSnackbarText(
                        deletedTodo.title,
                      ),
                    ),
                    action: SnackBarAction(
                      label: l10n.todosUndoDeletionButtonText,
                      onPressed: () {
                        messenger.hideCurrentSnackBar();
                        context
                            .read<TodosBloc>()
                            .add(const TodosUndoDeletionRequested());
                      },
                    ),
                  ),
                );
            },
          ),
        ],
        child: BlocBuilder<TodosBloc, TodosState>(
          builder: (context, state) {
            if (state.todos.isEmpty) {
              if (state.status == TodosStatus.loading) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (state.status != TodosStatus.success) {
                return const SizedBox();
              } else {
                return Center(
                  child: Text(
                    l10n.todosEmptyText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }
            }

            return CupertinoScrollbar(
              child: ListView(
                children: [
                  for (final todo in state.filteredTodos)
                    TodoListTile(
                      todo: todo,
                      onToggleCompleted: (isCompleted) {
                        context.read<TodosBloc>().add(
                              TodosTodoCompletionToggled(
                                todo: todo,
                                isCompleted: isCompleted,
                              ),
                            );
                      },
                      onDismissed: (_) {
                        context
                            .read<TodosBloc>()
                            .add(TodosTodoDeleted(todo));
                      },
                      onTap: () {
                        Navigator.of(context).push(
                          EditTodoPage.route(initialTodo: todo),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}