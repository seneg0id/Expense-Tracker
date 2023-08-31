import 'dart:ffi';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/icons.dart';
import '../widgets/budgetform.dart';
import './ex_category.dart';
import './expense.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseProvider with ChangeNotifier {
  String _searchText = '';
  String get searchText => _searchText;
  set searchText(String value) {
    _searchText = value;
    notifyListeners();
    // when the value of the search text changes it will notify the widgets.
  }

  // in-app memory for holding the Expense categories temporarily
  List<ExpenseCategory> _categories = [];
  List<ExpenseCategory> get categories => _categories;

  List<Expense> _expenses = [];
  // when the search text is empty, return whole list, else search for the value
  List<Expense> get expenses {
    return _searchText != ''
        ? _expenses
            .where((e) =>
                e.title.toLowerCase().contains(_searchText.toLowerCase()))
            .toList()
        : _expenses;
  }

  Database? _database;
  Future<Database> get database async {
    // database directory
    final dbDirectory = await getDatabasesPath();
    // database name
    const dbName = 'expense_tc.db';
    // full path
    final path = join(dbDirectory, dbName);

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb, // will create this separately
    );

    return _database!;
  }

  // _createDb function
  static const cTable = 'categoryTable';
  static const eTable = 'expenseTable';
  Future<void> _createDb(Database db, int version) async {
    // this method runs only once. when the database is being created
    // so create the tables here and if you want to insert some initial values
    // insert it in this function.

    await db.transaction((txn) async {
      // category table
      await txn.execute('''CREATE TABLE $cTable(
        title TEXT,
        entries INTEGER,
        totalAmount TEXT
      )''');
      // expense table
      await txn.execute('''CREATE TABLE $eTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount TEXT,
        date TEXT,
        category TEXT
      )''');

      // insert the initial categories.
      // this will add all the categories to category table and initialize the 'entries' with 0 and 'totalAmount' to 0.0
      for (int i = 0; i < icons.length; i++) {
        await txn.insert(cTable, {
          'title': icons.keys.toList()[i],
          'entries': 0,
          'totalAmount': (0.0).toString(),
        });
      }
    });
  }

  // method to fetch categories

  Future<List<ExpenseCategory>> fetchCategories() async {
    // get the database
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(cTable).then((data) {
        // 'data' is our fetched value
        // convert it from "Map<String, object>" to "Map<String, dynamic>"
        final converted = List<Map<String, dynamic>>.from(data);
        // create a 'ExpenseCategory'from every 'map' in this 'converted'
        List<ExpenseCategory> nList = List.generate(converted.length,
            (index) => ExpenseCategory.fromString(converted[index]));
        // set the value of 'categories' to 'nList'
        _categories = nList;
        // return the '_categories'
        return _categories;
      });
    });
  }

  Future<void> updateCategory(
    String category,
    int nEntries,
    double nTotalAmount,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .update(
        cTable, // category table
        {
          'entries': nEntries, // new value of 'entries'
          'totalAmount': nTotalAmount.toString(), // new value of 'totalAmount'
        },
        where: 'title == ?', // in table where the title ==
        whereArgs: [category], // this category.
      )
          .then((_) {
            print(category);
        // after updating in database. update it in our in-app memory too.
        var file =
            _categories.firstWhere((element) => element.title == category);
        print('sd');
        file.entries = nEntries;
        file.totalAmount = nTotalAmount;
        notifyListeners();
      });
    });
  }
  // method to add an expense to database
  triggerNotification(st){
    AwesomeNotifications().createNotification(
      content: NotificationContent(id: 10,
        channelKey: 'basic_channel',
        title: 'Budget Exceeded',
        body: 'Your Budget for $st category is exceeded',
      ),
    );
  }

  Future<void> addExpense(Expense exp) async {
    if(exp.amount < 0){
      return;
    }
    final db = await database;
    await db.transaction((txn) async {
      await txn
          .insert(
        eTable,
        exp.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      )
          .then((generatedId) {
        // after inserting in a database. we store it in in-app memory with new expense with generated id
        final file = Expense(
            id: generatedId,
            title: exp.title,
            amount: exp.amount,
            date: exp.date,
            category: exp.category);
        // add it to '_expenses'

        _expenses.add(file);

        // notify the listeners about the change in value of '_expenses'
        notifyListeners();
        var ex = findCategory(exp.category);
        print(exp.category+'13');
        updateCategory(
            exp.category, ex.entries + 1, ex.totalAmount + exp.amount);
        print(exp.category+'23');
        var budget_check = ex.totalAmount + exp.amount;
        print(budget_check);
        var eCI= BudgetCategories.categories.indexWhere((c) => c.category == exp.category);
        if (eCI >= 0){
          var budget = BudgetCategories.categories[eCI].amount;
          print(budget);
          if(budget_check > budget) {
            print(budget_check);
            triggerNotification(exp.category);
          };
        };

        // after we inserted the expense, we need to update the 'entries' and 'totalAmount' of the related 'category'


      });
    });
  }

  Future<void> deleteExpense(int expId, String category, double amount) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(eTable, where: 'id == ?', whereArgs: [expId]).then((_) {
        // remove from in-app memory too
        _expenses.removeWhere((element) => element.id == expId);
        notifyListeners();
        // we have to update the entries and totalamount too

        var ex = findCategory(category);
        updateCategory(category, ex.entries - 1, ex.totalAmount - amount);
      });
    });
  }



  Future<List<Expense>> fetchExpenses(String category) async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(eTable,
          where: 'category == ?', whereArgs: [category]).then((data) {
        final converted = List<Map<String, dynamic>>.from(data);
        //
        List<Expense> nList = List.generate(
            converted.length, (index) => Expense.fromString(converted[index]));
        _expenses = nList;
        return _expenses;
      });
    });
  }

  Future<List<Expense>> fetchAllExpenses() async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.query(eTable).then((data) {
        final converted = List<Map<String, dynamic>>.from(data);
        List<Expense> nList = List.generate(
            converted.length, (index) => Expense.fromString(converted[index]));
        _expenses = nList;
        return _expenses;
      });
    });
  }

  ExpenseCategory findCategory(String title) {
    print('sea'+title);
    return _categories.firstWhere((element) => element.title == title);
  }

  Map<String, dynamic> calculateEntriesAndAmount(String category) {
    double total = 0.0;
    var list = _expenses.where((element) => element.category == category);
    for (final i in list) {
      total += i.amount;
    }
    return {'entries': list.length, 'totalAmount': total};
  }

  double calculateTotalExpenses() {
    return _categories.fold(
        0.0, (previousValue, element) => previousValue + element.totalAmount);
  }

  List<Map<String, dynamic>> calculateWeekExpenses() {
    List<Map<String, dynamic>> data = [];

    // we know that we need 7 entries
    for (int i = 0; i < 7; i++) {
      // 1 total for each entry
      double total = 0.0;
      // subtract i from today to get previous dates.
      final weekDay = DateTime.now().subtract(Duration(days: i));

      // check how many transacitons happened that day
      for (int j = 0; j < _expenses.length; j++) {
        if (_expenses[j].date.year == weekDay.year &&
            _expenses[j].date.month == weekDay.month &&
            _expenses[j].date.day == weekDay.day) {
          // if found then add the amount to total
          total += _expenses[j].amount;
        }
      }

      // add to a list
      data.add({'day': weekDay, 'amount': total});
    }
    // return the list
    return data;
  }

  Future<File> exportToCsv() async {
    // Open the database
    final db = await database;

    // Retrieve the data from both tables
    final List<Map<String, dynamic>> table1Data = await db.query(cTable);
    final List<Map<String, dynamic>> table2Data = await db.query(eTable);

    // Convert the data to a list of lists that can be exported to CSV
    List<List<dynamic>> csvData = [];

    // Add the headers for table1
    csvData.add([cTable, 'title', 'entries', 'totalAmount']);

    // Add the data for table1
    for (var row in table1Data) {
      csvData.add([cTable, row['title'], row['entries'], row['totalAmount']]);
    }

    // Add the headers for table2
    csvData.add([eTable, 'id', 'title', 'amount', 'date', 'category']);

    // Add the data for table2
    for (var row in table2Data) {
      csvData.add([eTable, row['id'], row['title'], row['amount'], row['date'], row['category']]);
    }
    for(var item in BudgetCategories.categories) {
      if(item.amount != 0) {
        csvData.add([item.category, item.amount]);
      }
    }
    // Generate the CSV file
    String csv = ListToCsvConverter().convert(csvData);
    // Get the documents directory on Android
    final Directory? directory = await getExternalStorageDirectory();
    final String? documentPath = directory?.path;

    // Write the CSV to a file
    final File file = File('$documentPath/export.csv');
    await file.writeAsString(csv);
    print('CSV file saved to: ${file.path}');
    for(int i=0; i<_categories.length; i++){
      _categories[i].entries = 0;
      _categories[i].totalAmount = 0;
    }
    return file;
  }

  Future<void> updateDatabaseFromCsv(File csvFile) async {
    // final dbDirectory = await getDatabasesPath();
    // // database name
    // const dbName = 'expense_tc.db';
    // // full path
    // final path = join(dbDirectory, dbName);
    for(int i=0; i<_categories.length; i++){
      print(_categories[i].title);
      // _categories[i].entries = 0;
      // _categories[i].totalAmount = 0;
    }
    _expenses.clear();
    BudgetCategories.categories.clear();
    final db = await database;
    await db.transaction((txn) async {
      // Drop the category table if it exists
      await txn.execute('DROP TABLE IF EXISTS $cTable');

      // Drop the expense table if it exists
      await txn.execute('DROP TABLE IF EXISTS $eTable');
    });

    // await _createDb(db, 1);
    await db.transaction((txn) async {
      // category table
      await txn.execute('''CREATE TABLE $cTable(
        title TEXT,
        entries INTEGER,
        totalAmount TEXT
      )''');
      // expense table
      await txn.execute('''CREATE TABLE $eTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        amount TEXT,
        date TEXT,
        category TEXT
      )''');


      // insert the initial categories.
      // this will add all the categories to category table and initialize the 'entries' with 0 and 'totalAmount' to 0.0
      for (int i = 0; i < icons.length; i++) {
        await txn.insert(cTable, {
          'title': icons.keys.toList()[i],
          'entries': 0,
          'totalAmount': (0.0).toString(),
        });
      }
    });
    await db.transaction((txn) async {
      await txn.query(cTable).then((data) {
        // 'data' is our fetched value
        // convert it from "Map<String, object>" to "Map<String, dynamic>"
        final converted = List<Map<String, dynamic>>.from(data);
        // create a 'ExpenseCategory'from every 'map' in this 'converted'
        List<ExpenseCategory> nList = List.generate(converted.length,
                (index) => ExpenseCategory.fromString(converted[index]));
        // set the value of 'categories' to 'nList'
        _categories = nList;
      });
    });
    for(int i=0; i<_categories.length; i++){
      print(_categories[i].title);
    }

    // _database = await openDatabase(
    //   path,
    //   version: 1,
    //   onCreate: _createDb, // will create this separately
    // );
    final csvData = await csvFile.readAsString();
    // print(csvData);
    if(csvData != '') {
      List<List<dynamic>> csvTable = CsvToListConverter().convert(csvData);
      List<Map<String, dynamic>> rowsAsMaps = [];
      print('updateshit');
      // for (int i = 0; i < csvTable.length; i++) {
      //   for (int j = 0; j < csvTable[i].length; j++) {
      //     print(csvTable[i][j]);
      //   }
      // }
      int i = 0;
      while (csvTable[i][0] != 'expenseTable') {
        i++;
      }
      i++;
      print('signinscreen');
      for (; i < csvTable.length; i++) {
        if (csvTable[i][0] == 'expenseTable') {
          var _title = csvTable[i][2];
          var _amount = csvTable[i][3];
          var _date = csvTable[i][4];
          var _initialValue = csvTable[i][5];

          final exp = Expense(
            id: 0,
            title: _title.toString(),
            amount: double.parse(_amount.toString()),
            date: DateTime.parse(_date.toString()),
            category: _initialValue.toString(),
          );
          if (exp.amount < 0) {
            continue;
          }
          final db = await database;
          await db.transaction((txn) async {
            await txn
                .insert(
              eTable,
              exp.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            )
                .then((generatedId) {
              // after inserting in a database. we store it in in-app memory with new expense with generated id
              final file = Expense(
                  id: generatedId,
                  title: exp.title,
                  amount: exp.amount,
                  date: exp.date,
                  category: exp.category);
              // add it to '_expenses'

              _expenses.add(file);

              // notify the listeners about the change in value of '_expenses'
              notifyListeners();
              print(_categories.length);
              for (int i = 0; i < _categories.length; i++) {
                print(_categories[i].title);
                print(_categories[i].totalAmount);
              }
              var ex = findCategory(exp.category);
              print(exp.category + '13');
              updateCategory(
                  exp.category, ex.entries + 1, ex.totalAmount + exp.amount);
              print(exp.category + '23');
              var budget_check = ex.totalAmount + exp.amount;
              print(budget_check);
              var eCI = BudgetCategories.categories.indexWhere((c) =>
              c.category == exp.category);
              if (eCI >= 0) {
                var budget = BudgetCategories.categories[eCI].amount;
                print(budget);
                if (budget_check > budget) {
                  print(budget_check);
                  triggerNotification(exp.category);
                };
              };

              // after we inserted the expense, we need to update the 'entries' and 'totalAmount' of the related 'category'


            });
          });
        }
        else{
          BudgetCategories.categories.add(BudgetCategory(category: csvTable[i][0], amount: csvTable[i][1]));
        }
      }
    }

// Iterate over each row (skip the first row which contains headers)
//     for (int i = 1; i < csvTable.length; i++) {
//       Map<String, dynamic> rowAsMap = {};
//       // Iterate over each column in the row
//       for (int j = 0; j < csvTable[i].length; j++) {
//         // Get the header value from the first row
//         String header = csvTable[0][j].toString();
//         // Get the value of the current cell in the row
//         dynamic value = csvTable[i][j];
//         // Add the key-value pair to the rowAsMap
//         rowAsMap[header] = value;
//       }
//       rowsAsMaps.add(rowAsMap);
//     }

  }

}