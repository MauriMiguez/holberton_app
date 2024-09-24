import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holberton_app/l10n/l10n.dart';
import 'package:holberton_app/todos/todos.dart';

class TodosFilterButton extends StatelessWidget {
  const TodosFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final activeFilter =
        context.select((TodosBloc bloc) => bloc.state.filter);

    return PopupMenuButton<TodosFilter>(
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      initialValue: activeFilter,
      tooltip: l10n.todosFilterTooltip,
      onSelected: (filter) {
        context
            .read<TodosBloc>()
            .add(TodosFilterChanged(filter));
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: TodosFilter.all,
            child: Text(l10n.todosFilterAll),
          ),
          PopupMenuItem(
            value: TodosFilter.activeOnly,
            child: Text(l10n.todosFilterActiveOnly),
          ),
          PopupMenuItem(
            value: TodosFilter.completedOnly,
            child: Text(l10n.todosFilterCompletedOnly),
          ),
        ];
      },
      icon: const Icon(Icons.filter_list_rounded),
    );
  }
}