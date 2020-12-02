class StatValueModel {
  String symbol;
  int symbolSubscriptIndex;
  String symbolSuperscript;
  String desc;
  double value;
  String unit;
  int precision;

  StatValueModel(
      {this.symbol,
        this.symbolSubscriptIndex,
        this.symbolSuperscript,
        this.desc,
        this.value,
        this.precision = 3,
        this.unit});
}