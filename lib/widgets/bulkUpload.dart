import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, rootBundle;
import 'package:provider/provider.dart';
import '../models/database_provider.dart';
import '../models/expense.dart';


class bulkUpload extends StatefulWidget {
  const bulkUpload({Key? key}) : super(key: key);

  @override
  State<bulkUpload> createState() => _bulkUploadState();
}

class _bulkUploadState extends State<bulkUpload> {
  List<List<dynamic>> _data = [];
  var table;
  String? filePath;

  // This function is triggered when the  button is pressed

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    return Scaffold(
        // extendBody: true,
        appBar: AppBar (
          title: const Text('Upload Excel File'),
          backgroundColor: Colors.blue[400],
          // systemOverlayStyle: const SystemUiOverlayStyle(
          //   // Status bar color
          //   statusBarColor: Colors.white,
          //   // Status bar brightness (optional)
          //   statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          //   statusBarBrightness: Brightness.light, // For iOS (dark icons)
          // ),
          // title: const Text("Bulk Upload",
          //     style: TextStyle(color: Colors.white,
          //       fontSize: 20.0,)
          // ),
        ),
        body: SafeArea(
          child: Column(
          children: [
            ElevatedButton(
              child: const Text("Upload FIle"),
              onPressed:(){
                _pickFile();
              },
            ),

            ListView.builder(
              itemCount: _data.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (_, index) {
                return Card(
                  margin: const EdgeInsets.all(3),
                  color: index == 0 ? Colors.amber : Colors.white,
                  child: ListTile(
                    leading: Text(_data[index][0].value.toString(),textAlign: TextAlign.center,
                      style: TextStyle(fontSize: index == 0 ? 18 : 15, fontWeight:index == 0 ? FontWeight.bold :FontWeight.normal,color: index == 0 ? Colors.red : Colors.black),),
                    title: Text(_data[index][1].value.toString(),textAlign: TextAlign.center,
                      style: TextStyle(fontSize: index == 0 ? 18 : 15, fontWeight: index == 0 ? FontWeight.bold :FontWeight.normal,color: index == 0 ? Colors.red : Colors.black),),
                    trailing: Text(_data[index][2].value.toString(),textAlign: TextAlign.center,
                      style: TextStyle(fontSize: index == 0 ? 18 : 15, fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,color: index == 0 ? Colors.red : Colors.black),),

                  ),

                );

              },

            ),
            // Container(
            //   child:  ElevatedButton(
            //     onPressed: ()async{
            //       // set loading to true here

            //       for (var element in _data.skip(1))  // for skip first value bcs its contain name
            //           {
            //         // var mydata = {
            //         //   "data": {
            //         //     "certificateType": "ProofOfEducation",
            //         //     "membershipNum": element[0],   if you want to iterate only name then use element[0]
            //         //     "registrationNum": element[1],
            //         //     "serialNum": element[2],
            //         //     "bcName": element[3],
            //         //     "bcExam": element[4],
            //         //     "date":element[5]
            //         //   },
            //         //
            //         // };
            //         ScaffoldMessenger.of(context).showSnackBar(  SnackBar(
            //           content: Text(element.toString()),
            //         ));
            //       }

            //     }, child: const Text("Iterate Data"),

            //   ),

            // ),
            ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.red[400]),
              ),
              onPressed: () async {
                int i=1;
                print('start');

                while(i < table.maxRows){
                  var _title = table.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i))?.value;
                  var _amount = table.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i))?.value;
                  var _date = table.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i))?.value;
                  var _initialValue = table.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i))?.value;
                  print('eee');
                  final file = Expense(
                    id: 0,
                    title: _title.toString(),
                    amount: double.parse(_amount.toString()),
                    date: DateTime.parse(_date.toString()),
                    category: _initialValue.toString(),
                  );
                  print(i);
                  await provider.addExpense(file);
                  i = i+1;
                  print(i);
                }
                print('ok');
                Navigator.of(context).pop();
                print('ok1');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          ],
        ),
        )
    );

  }

  void _pickFile() async {

    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    // if no file is picked
    if (result == null) return;
    final file = result?.files.first;
    print('test34');
    final bytes = result.files.first.bytes;
    if (bytes == null) {
      // Handle error: Unable to read file contents
      return;
    }
    final excel = Excel.decodeBytes(bytes);
    // Parse the Excel file and store its contents in a List<List<dynamic>> variable
    table = excel.tables[excel.tables.keys.first]!;

    final value = table.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))?.value;
    print(value);

    final rows = table.rows;
    final data = <List<dynamic>>[];
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      data.add(row);
    }
    setState(() {
      _data = data;
    });
  }

}