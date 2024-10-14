import 'package:flutter/material.dart';
import 'package:sqliteproj/database/db_helper.dart'; // Fixed path typo
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
    if (name.isNotEmpty && description.isNotEmpty) {
      final todo = Todo(name: name, description: description);
      await _todoRepository.create(todo);
      _nameController.clear();
      _descriptionController.clear();
      _loadTodos();
    } else {
      // Show warning dialog if description is empty
      _showWarningDialog();
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Warning'),
        content: Text('Please enter a description to save the Todo.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
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
            hintStyle: TextStyle(color: Colors.black54), // Hint text color
          ),
          onChanged: _searchTodos, // Trigger search on text change
          style: TextStyle(color: Colors.black), // Input text color
        ),
        backgroundColor: Colors.white, // AppBar background color
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black), // Icon color
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
                    key: Key(todo.id.toString()), // Unique key for each todo
                    direction:
                        DismissDirection.endToStart, // Swipe right to left
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      // Show delete confirmation dialog
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
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                    color: Colors
                                        .black), // Set text color to black
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: Text(
                                'Delete',
                                style: TextStyle(
                                    color: Colors
                                        .black), // Set text color to black
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) {
                      // Delete the todo if confirmed
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
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: Colors
                                            .black), // Set text color to black
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _updateTodo(todo);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Update',
                                    style: TextStyle(
                                        color: Colors
                                            .black), // Set text color to black
                                  ),
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
        onPressed: () {
          _nameController.clear();
          _descriptionController.clear();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
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
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.black), // Set text color to black
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _addTodo(); // This will check if the description is empty
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Add',
                    style: TextStyle(
                        color: Colors.black), // Set text color to black
                  ),
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.black), // Set icon color to black
        backgroundColor: const Color.fromARGB(
            154, 217, 214, 214), // Background color for the button
      ),
    );
  }
}
