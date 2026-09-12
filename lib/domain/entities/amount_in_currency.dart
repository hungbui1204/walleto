class AmountInCurrency {
  const AmountInCurrency({required this.amount, required this.currencyCode, this.sign = 1});

  final double amount;
  final String currencyCode;
  final int sign;
}
