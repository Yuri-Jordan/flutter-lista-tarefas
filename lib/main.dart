import 'package:flutter/material.dart';
import 'package:italist/models/Tarefa.dart';
import 'providers/tarefa-provider.dart';

void main() {
  runApp(MaterialApp(title: "Lista de Tarefas", home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Tarefa> _todoList = List<Tarefa>();
  Tarefa _lastRemoved;
  int _lastRemovedPos;
  bool _carregandoDados;
  final _form = GlobalKey<FormState>();

  TarefaProvider _tarefaProvider = new TarefaProvider();

  TextEditingController _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.buscarTarefas();
  }

  buscarTarefas() {
    setState(() {
      _carregandoDados = false;
    });

    _tarefaProvider
        .buscarTodasTarefas()
        .then((data) => setState(() {
              _todoList = data;
              _carregandoDados = false;

              _todoList.sort((a, b) {
                if (a.feita && !b.feita)
                  return 1;
                else if (!a.feita && b.feita)
                  return -1;
                else
                  return 0;
              });
            }))
        .catchError((onError) {
      setState(() {
        _carregandoDados = false;
      });
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ocorreu um erro!'),
          content: Text("Erro ao carregar suas Tarefas!"),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Scaffold screen = Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: _carregandoDados
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Form(
                          key: _form,
                          child: TextFormField(
                            controller: _todoController,
                            decoration: InputDecoration(
                              labelText: "Nova Tarefa",
                              labelStyle: TextStyle(color: Colors.blueAccent),
                            ),
                            validator: (value) {
                              if (value.trim().isEmpty) {
                                return 'Por favor insira um nome para a tarefa.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      RaisedButton(
                        child: Icon(Icons.add),
                        color: Colors.blueAccent,
                        textColor: Colors.white70,
                        onPressed: addTodo,
                        disabledColor: Colors.grey,
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                        padding: EdgeInsets.only(top: 10.0),
                        itemCount: _todoList.length,
                        itemBuilder: buildItem),
                  ),
                ),
              ],
            ),
    );

    return screen;
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_todoList[index].titulo),
        value: _todoList[index].feita,
        secondary: CircleAvatar(
          child: Icon(_todoList[index].feita ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          checkTodo(index, c);
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = _todoList[index];
          _lastRemovedPos = index;
          _todoList.removeAt(index);

          var exclusaoDesfeita = false;

          final snack = SnackBar(
            content: Text("Tarefa ${_lastRemoved.titulo} removida."),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  exclusaoDesfeita = true;
                }),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack).closed.then((value) {
            if (!exclusaoDesfeita) {
              this.apagarTarefa(_lastRemoved).catchError((onError) {
                setState(() {
                  _todoList.insert(_lastRemovedPos, _lastRemoved);
                });
              });
            } else {
              setState(() {
                _todoList.insert(_lastRemovedPos, _lastRemoved);
              });
            }
          });
        });
      },
    );
  }

  Future<void> apagarTarefa(Tarefa lastRemoved) {
    return _tarefaProvider.apagarTarefa(_lastRemoved);
  }

  void addTodo() {
    if (!_form.currentState.validate()) return;
    _tarefaProvider
        .adicionarTarefa(Tarefa(titulo: _todoController.text.trim()))
        .then((tarefa) {
      setState(() {
        _todoList.add(tarefa);
        _todoController.text = "";
      });
    });
  }

  void checkTodo(index, bool c) {
    setState(() {
      _todoList[index].feita = c;
    });
    _tarefaProvider.editarTarefa(_todoList[index]).catchError((onError) {
      setState(() {
        _todoList[index].feita = !c;
      });
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    this.buscarTarefas();

    return null;
  }
}
