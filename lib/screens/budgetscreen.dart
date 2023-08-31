

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jupiter_clone/widgets/category_screen/category_card.dart';
import 'package:provider/provider.dart';
import '../widgets/budgetform.dart';



class BudgetScreen extends StatelessWidget {
  final List<BudgetCategory> budgetCategories;

  const BudgetScreen({Key? key, required this.budgetCategories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyNotifier>(context);
    final currencySymbol = currencyProvider.currencySymbol;
    Map<String, double> symtomul = {
      '₹' : 1,
      '\$': 0.012,
      '€' : 0.011,
      '£' : 0.0097,
      '¥' : 1.68,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budget Category-wise',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: budgetCategories.length,
                itemBuilder: (context, index) {
                  final category = budgetCategories[index];

                  return ListTile(
                    title: Text(category.category),
                    trailing: Text(
                      '$currencySymbol ${NumberFormat.currency(
                        locale: 'en_IN',
                        symbol: '',
                      ).format(category.amount*symtomul[currencySymbol]!)}',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => BudgetForm(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}



