import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/ex_category.dart';
import '../screens/budgetscreen.dart';

class BudgetCategory {
  String category;
  double amount;

  BudgetCategory({required this.category, required this.amount});
}
class BudgetCategories {
  static List<BudgetCategory> categories = [];
}



class BudgetForm extends StatefulWidget {
  const BudgetForm({Key? key}) : super(key: key);

  @override
  _BudgetFormState createState() => _BudgetFormState();
}

class _BudgetFormState extends State<BudgetForm> {
  final _formKey = GlobalKey<FormState>();
  String _category = 'Other';
  double _amount = 0.0;
  final List<String> _categoryOptions = [
    'Transport',
    'Sports',
    'Food',
    'Entertainment',
    'Education',
    'Other',
  ];

  void _saveForm() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    _formKey.currentState?.save();

    final existingCategoryIndex = BudgetCategories.categories.indexWhere((c) => c.category == _category);

    if (existingCategoryIndex >= 0) {
      setState(() {
        BudgetCategories.categories[existingCategoryIndex].amount = _amount;
      });
    } else {
      setState(() {
        BudgetCategories.categories.add(BudgetCategory(category: _category, amount: _amount));
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BudgetScreen(budgetCategories: BudgetCategories.categories)),
    );
  }





  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Set Budget Category-wise',
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                  ),
                  value: _category,
                  onChanged: (value) {
                    setState(() {
                      _category = value ?? '';
                    });
                  },
                  items: _categoryOptions
                      .map((category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid amount';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Please enter a positive amount';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _amount = double.parse(value!);
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
