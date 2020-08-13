import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/Tarefa.dart';

class TarefaProvider {
  String buscarURLFirebase([String id = '']) {
    if (id.isNotEmpty) id = '/$id';

    return '';
  }

  Future<List<Tarefa>> buscarTodasTarefas() async {
    final response = await http.get(this.buscarURLFirebase());
    final responseBody = json.decode(response.body) as Map<String, dynamic>;
    final List<Tarefa> tarefas = [];

    if (responseBody != null) {
      responseBody.forEach((chave, valor) {
        tarefas.add(
            Tarefa(titulo: valor['titulo'], feita: valor['feita'], id: chave));
      });
    }
    return tarefas;
  }

  Future<Tarefa> adicionarTarefa(Tarefa tarefa) async {
    final response = await http.post(
      this.buscarURLFirebase(),
      body: json.encode({
        'titulo': tarefa.titulo,
        'feita': tarefa.feita,
      }),
    );

    final tarefaCriada = Tarefa(
      titulo: tarefa.titulo,
      feita: tarefa.feita,
      id: json.decode(response.body)['name'],
    );
    return tarefaCriada;
  }

  Future<void> apagarTarefa(Tarefa tarefa) async {
    await http
        .delete(
      this.buscarURLFirebase(tarefa.id),
    )
        .then((value) {
      if (value.statusCode >= 400) throw (Exception);
    });
  }

  Future<void> editarTarefa(Tarefa tarefa) async {
    await http
        .patch(
      this.buscarURLFirebase(tarefa.id),
      body: json.encode({
        'titulo': tarefa.titulo,
        'feita': tarefa.feita,
      }),
    )
        .then((value) {
      if (value.statusCode >= 400) throw (Exception);
    });
  }
}
