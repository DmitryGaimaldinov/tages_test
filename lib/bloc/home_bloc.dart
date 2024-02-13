import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tages_test/repository/banknote_repository.dart';

import 'dart:math' as math;

import 'package:tages_test/bloc/home_state.dart';

// Для простоты был взят Cubit вместо Bloc'а
class HomeBloc extends Cubit<HomeState> {

  final BanknoteRepository _banknoteRepository;

  HomeBloc({ required BanknoteRepository banknoteRepository}) :
        _banknoteRepository = banknoteRepository,
        super(HomeStateInitializing()) {
    _init();
  }

  Future<void> _init() async {
    final limits = await _banknoteRepository.getLimits();
    emit(HomeStateLoaded(limits: limits));
  }

  Future<void> withdrawMoney(int amount) async {
    if (state is HomeStateLoaded) {
      final state = this.state as HomeStateLoaded;

      // Сумма должна быть кратна 100, т.к. 100 - меньшая купюра
      if (amount % 100 != 0) {
        emit(HomeStateLoaded(limits: state.limits, errorText: "Банкомат не может выдать запрашиваемую сумму 😢. Она должна быть кратна 100"));
        return;
      }

      Map<int, int>? withdrawnBanknotes = _getWithdrawBanknotes(amount, state.limits);
      if (withdrawnBanknotes != null) {
        final newLimits = await _banknoteRepository.withdraw(withdrawnBanknotes);
        emit(HomeStateLoaded(limits: newLimits, withdrawnBanknotes: withdrawnBanknotes));
      } else {
        emit(HomeStateLoaded(limits: state.limits, errorText: "Банкомат не может выдать запрашиваемую сумму 😢"));
      }
    }
  }

  Future<void> refresh() async {
    final newLimits = await _banknoteRepository.refreshLimits();
    emit(HomeStateLoaded(limits: newLimits));
  }


  Map<int, int>? _getWithdrawBanknotes(int amount, Map<int, int> limits) {

    // Получает на вход итоговую сумму, которую нужно снять,
    // и словарь со свободными купюрами и их количеством.
    // Возвращает словарь со всеми снятыми купюрами и их количеством
    Map<int, int>? recursive(int amount, Map<int, int> banknotes) {
      if (amount == 0) return {}; // Вся сумма успешно снята
      if (banknotes.isEmpty) return null; // Банкноты кончились, сумму нельзя снять

      // Самая большая купюра
      int banknote = banknotes.keys.first;

      // Берём из банкомата столько купюр, сколько можем,
      // но чтобы их сумма не превысила amount
      int maxCount = math.min((amount / banknote).floor(), limits[banknote]!);

      // Проходимся по купюрам так, что берём их сначала макс кол-во.
      // Если с таким кол-вом не получается снять деньги с банкомата,
      // то берём на одну купюру меньше, и так пока вообще не возьмём купюру.
      for (int takeCount = maxCount; takeCount >= 0; takeCount--) {
        // Дальше уже берём другие купюры
        Map<int, int>? result = recursive(amount - takeCount * banknote, banknotes..remove(banknote));


        if (result != null) {
          return (takeCount != 0)
              ? { banknote: takeCount, ...result} // Если брали текущую купюру, добавляем её в итоговый результат
              : result;
        }
      }
      return null;
    }

    return recursive(
        amount,
        // Сортируем банкноты по ценности. Сначала крупные
        Map.fromEntries(limits.entries.toList()..sort((b1, b2) => b2.key.compareTo(b1.key))));
  }
}
