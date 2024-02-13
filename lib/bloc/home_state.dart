sealed class HomeState {
  const HomeState();
}

class HomeStateInitializing extends HomeState {}

class HomeStateLoaded extends HomeState {

  final Map<int, int> limits;
  final Map<int, int>? withdrawnBanknotes;
  final String? errorText;


  const HomeStateLoaded({
    required this.limits,
    this.withdrawnBanknotes,
    this.errorText
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeStateLoaded &&
          runtimeType == other.runtimeType &&
          limits == other.limits &&
          withdrawnBanknotes == other.withdrawnBanknotes &&
          errorText == other.errorText;

  @override
  int get hashCode => limits.hashCode ^ withdrawnBanknotes.hashCode ^ errorText.hashCode;
}
