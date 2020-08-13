import 'package:flutter/foundation.dart';

class Tarefa {
  String id;
  String titulo;
  bool feita;

  Tarefa({
    this.id,
    @required this.titulo,
    this.feita = false,
  });
}
