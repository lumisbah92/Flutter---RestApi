import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_app/services/todo_service.dart';

import 'add_todo.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Todo List",
        ),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
              child: Text(
                "No Todo Item",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.indigo,
                  ),
                  padding: EdgeInsets.only(left: 5, right: 5, top: 5),
                  margin: EdgeInsets.all(5),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                      backgroundColor: Colors.indigoAccent,
                    ),
                    title: Text(item['title']),
                    subtitle: Text(item['description']),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            child: Text("Edit"),
                            value: "Edit",
                          ),
                          PopupMenuItem(
                            child: Text("Delete"),
                            value: "Delete",
                          ),
                        ];
                      },
                      onSelected: (value) {
                        if (value == "Edit") {
                          navigateToEditTodoPage(item);
                        } else if (value == "Delete") {
                          deleteById(id);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: Text(
          "Add Todo",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black26,
      ),
    );
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToEditTodoPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> fetchTodo() async {
    final result = await TodoService.fetchTodo();
    if (result != null) {
      setState(() {
        items = result;
      });
    } else {
      showToast("Something went wrong here", Colors.red);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteById(String id) async {
    final isSuccess = await TodoService.deleteById(id);
    if (isSuccess) {
      final filteredItem =
          items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filteredItem;
      });
      showToast("Item Deleted Successfully", Colors.green);
    } else {
      showToast("Item Deletion Failed", Colors.red);
    }
  }

  void showToast(String message, Color bgcolor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      textColor: Colors.white,
      backgroundColor: bgcolor,
    );
  }
}
