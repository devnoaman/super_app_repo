import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

extension SizingFromContext on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  Size get size => MediaQuery.of(this).size;
}

extension ThemeHelper on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
}

extension DateFormation on DateTime {
  String get toStringDate => DateFormat('yyyy-MM-dd').format(this);
  String get ddMMyyyyDate => DateFormat('dd-MM-yyyy').format(this);
  String get ymdDate => DateFormat('yyyy-MM-dd').format(this);
  String get hms => DateFormat('hh:mm a').format(this);
  String get lmd => DateFormat.jms('en').format(this);
}

extension PriceFormatter on num {
  String get toFormatedPrice {
    if (this is double) {
      return NumberFormat('###,###,###', 'ar-IQ').format(this);
    }
    return NumberFormat('###,###,###', 'ar-IQ').format(this);
  }

  String toIqdPrice([String? symbol, int? decimalDigits]) =>
      NumberFormat.currency(
        locale: 'ar_IQ',
        decimalDigits: decimalDigits ?? 0,
        symbol: (symbol == null || symbol == 'ar') ? 'د.ع' : 'IQD',

        // symbol==null ? :symbol=='ar'
      ).format(this);
  // String get ddMMyyyyDate => DateFormat('dd-MM-yyyy').format(this);
}

extension PriceFormation on double {
  String get toStringPrice => NumberFormat('###,###').format(this);
}

extension TextDirectionality on BuildContext {
  bool isRTL() {
    final currentDirection = Directionality.of(this);
    final rtl = currentDirection == TextDirection.rtl;
    return rtl;
  }
}

extension SpacingHelper on num {
  Widget get hGap => SizedBox(height: double.tryParse(toString()));
  Widget get wGap => SizedBox(width: double.tryParse(toString()));
}

extension NumDurationExtensions on num {
  Duration get microseconds => Duration(microseconds: round());
  Duration get ms => (this * 1000).microseconds;
  Duration get milliseconds => (this * 1000).microseconds;
  Duration get seconds => (this * 1000 * 1000).microseconds;
  Duration get minutes => (this * 1000 * 1000 * 60).microseconds;
  Duration get hours => (this * 1000 * 1000 * 60 * 60).microseconds;
  Duration get days => (this * 1000 * 1000 * 60 * 60 * 24).microseconds;
}

extension BorderExtension on num {
  BorderRadiusGeometry get cRadius => BorderRadius.circular(toDouble());
}

extension SymetricalPadding on double {
  EdgeInsetsGeometry get symetric => EdgeInsets.symmetric(
    horizontal: truncate().toDouble(),
    vertical: double.parse(toString().split('.')[1]),
  );
}

extension Paddinator on num {
  EdgeInsetsGeometry get allPadding => EdgeInsets.all(toDouble());
  EdgeInsetsGeometry get leftPadding => EdgeInsets.only(left: toDouble());
  EdgeInsetsGeometry get rightPadding => EdgeInsets.only(right: toDouble());
  EdgeInsetsGeometry get topPadding => EdgeInsets.only(top: toDouble());
  EdgeInsetsGeometry get bottomPadding => EdgeInsets.only(bottom: toDouble());
  EdgeInsetsGeometry get hPadding =>
      EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsetsGeometry get vPadding => EdgeInsets.symmetric(vertical: toDouble());
}
