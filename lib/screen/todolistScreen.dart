import 'package:flutter/material.dart';
import 'package:sqliteproj/database/db_helper.dart';
import 'package:sqliteproj/database/repository.dart';
import 'package:sqliteproj/model/todo_model.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  late TodoEntityRepository _todoRepository;

  List<Todo> _todos = [];
  List<Todo> _filteredTodos = [];
  String? _descriptionError; // Error message for description validation

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final db = await DBHelper.dbHero.dataBase;
    _todoRepository = TodoEntityRepository(database: db);
    _loadTodos();
  }

  void _loadTodos() async {
    final todos = await _todoRepository.getAll();
    setState(() {
      _todos = todos;
      _filteredTodos = todos; // Initialize filtered list
    });
  }

  void _searchTodos(String query) async {
    if (query.isNotEmpty) {
      final searchResults = await _todoRepository.quickSearch(query);
      setState(() {
        _filteredTodos = searchResults;
      });
    } else {
      // If the search field is empty, reset to show all todos
      setState(() {
        _filteredTodos = _todos;
      });
    }
  }

  void _addTodo() async {
    final name = _nameController.text;
    final description = _descriptionController.text;

    setState(() {
      _descriptionError =
          description.isEmpty ? 'Please enter a description.' : null;
    });

    if (name.isNotEmpty && description.isNotEmpty) {
      final todo = Todo(name: name, description: description);
      await _todoRepository.create(todo);
      _nameController.clear();
      _descriptionController.clear();
      _descriptionError = null; // Clear error when successfully added
      _loadTodos();
      Navigator.of(context).pop(); // Close the dialog after successfully adding
    }
  }

  void _showAddTodoDialog() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Todo Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  errorText:
                      _descriptionError, // Display error message if present
                ),
                onChanged: (value) {
                  // Update error message state when user types
                  setState(() {
                    _descriptionError =
                        value.isEmpty ? 'Please enter a description.' : null;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                _addTodo(); // Attempt to add the Todo
                setState(() {}); // Update the dialog state
              },
              child: Text('Add', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  void _updateTodo(Todo todo) async {
    final updatedTodo = Todo(
      id: todo.id,
      name: _nameController.text,
      description: _descriptionController.text,
    );
    await _todoRepository.update(updatedTodo);
    _nameController.clear();
    _descriptionController.clear();
    _loadTodos();
  }

  void _deleteTodo(int id) async {
    await _todoRepository.delete(id);
    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search Todos...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black54),
          ),
          onChanged: _searchTodos,
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Your Todos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredTodos.length,
                itemBuilder: (context, index) {
                  final todo = _filteredTodos[index];
                  return Dismissible(
                    key: Key(todo.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Delete Todo'),
                          content: Text(
                              'Are you sure you want to delete this todo?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Text('Cancel',
                                  style: TextStyle(color: Colors.black)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: Text('Delete',
                                  style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      _deleteTodo(todo.id!);
                    },
                    child: ListTile(
                      title: Text(
                        todo.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        todo.description,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit, color: Colors.black),
                        onPressed: () {
                          _nameController.text = todo.name;
                          _descriptionController.text = todo.description;
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Edit Todo'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: _nameController,
                                    decoration:
                                        InputDecoration(labelText: 'Todo Name'),
                                  ),
                                  TextField(
                                    controller: _descriptionController,
                                    decoration: InputDecoration(
                                        labelText: 'Description'),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel',
                                      style: TextStyle(color: Colors.black)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _updateTodo(todo);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Update',
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: Icon(Icons.add, color: Colors.black),
        backgroundColor: const Color.fromARGB(154, 217, 214, 214),
      ),
    );
  }
}
