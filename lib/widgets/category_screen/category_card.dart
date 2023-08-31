import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/ex_category.dart';
import '../../screens/expense_screen.dart';
import '../../screens/settings_screen.dart';

// class CategoryCard extends StatelessWidget {
//   final ExpenseCategory category;
//   const CategoryCard(this.category, {super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       onTap: () {
//         Navigator.of(context).pushNamed(
//           ExpenseScreen.name,
//           arguments: category.title, // for expensescreen.
//         );
//       },
//       leading: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Icon(category.icon),
//       ),
//       title: Text(category.title),
//       subtitle: Text('entries: ${category.entries}'),
//       trailing: Text(NumberFormat.currency(locale: 'en_IN', symbol: '₹')
//           .format(category.totalAmount)),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CurrencyNotifier extends ChangeNotifier {
  String _currencySymbol = '₹';
  double _currencyMul = 1;

  String get currencySymbol => _currencySymbol;
  double get currencyMul => _currencyMul;

  void setCurrencySymbol(String symbol, var mul) {
    _currencySymbol = symbol;
    _currencyMul = mul;
    notifyListeners();
  }
}



class CategoryCard extends StatelessWidget {
  final ExpenseCategory category;
  const CategoryCard(this.category, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyNotifier>(
      builder: (context, currencyNotifier, child) {
        final currencySymbol = currencyNotifier.currencySymbol;
        final currencyMul = currencyNotifier.currencyMul;
        return ListTile(
          onTap: () {
            Navigator.of(context).pushNamed(
              ExpenseScreen.name,
              arguments: category.title, // for expensescreen.
            );
          },
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(category.icon),
          ),
          title: Text(category.title),
          subtitle: Text('entries: ${category.entries}'),
          trailing: Text(
            '$currencySymbol ${NumberFormat.currency(
              locale: 'en_IN',
              symbol: '',
            ).format(category.totalAmount*currencyMul)}',
          ),
        );
      },
    );
  }
}







