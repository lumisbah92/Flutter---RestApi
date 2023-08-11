import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo_app/services/todo_service.dart';

class AddTodoPage extends StatefulWidget {
  final Map? todo;

  const AddTodoPage({
    super.key,
    this.todo,
  });

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (widget.todo != null) {
      isEdit = true;
      final title = todo!['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Todo" : "Add Todo"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: "Title"),
          ),
          SizedBox(height: 20),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(hintText: "Description"),
            minLines: 5,
            maxLines: 10,
            keyboardType: TextInputType.multiline,
          ),
          SizedBox(height: 20),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black26,
                onPrimary: Colors.white,
              ),
              onPressed: isEdit ? updateData : submitData,
              child: Text(isEdit ? "Update" : "Submit")),
        ],
      ),
    );
  }

  Future<void> submitData() async {
    // Get Data from Form
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    // Submit data to the server
    final isSuccess = await TodoService.submitData(body);

    // show success or fail message based on status
    if (isSuccess) {
      titleController.text = "";
      descriptionController.text = "";
      showToast("Creation Successful", Colors.green);
    } else {
      showToast("Creation Failed", Colors.red);
    }
  }

  Future<void> updateData() async {
    // Get Data from Form
    final todo = widget.todo;
    if (todo == null) {
      showToast("You Cannot Edit Todo", Colors.red);
      return;
    }
    final id = todo['_id'];

    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    // Submit updated data to the server
    final isSuccess = await TodoService.updateData(id, body);

    // show success or fail message based on status
    if (isSuccess) {
      showToast("Update Successful", Colors.green);
    } else {
      showToast("Update Failed", Colors.red);
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
