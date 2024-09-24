import 'package:holberton_app/app/app.dart';
import 'package:holberton_app/bootstrap.dart';

void main() {
  bootstrap((todosRepository) => App(todosRepository: todosRepository));
}
