Версия Flutter: 3.16.5
Версия Dart: 3.2.3
Рабочую версию приложения можно посмотреть на сайте: https://thatnetwork.ru/#/tages-test

Начальное состояние
![1](https://github.com/DmitryGaimaldinov/tages_test/assets/123044629/eda796e8-a7ae-4e65-b02d-ff038ab083b6)![1_land](https://github.com/DmitryGaimaldinov/tages_test/assets/123044629/84c9252f-397a-42bc-af28-d0c83cadf254)

Успешное снятие денег
![2_land](https://github.com/DmitryGaimaldinov/tages_test/assets/123044629/04c89e50-f416-4afc-9c53-c8a47d827e0e)
![2](https://github.com/DmitryGaimaldinov/tages_test/assets/123044629/09516dd8-7578-4d80-9129-784b586c6b04)


Ошибка снятия из-за недопустимого ввода
![3_land](https://github.com/DmitryGaimaldinov/tages_test/assets/123044629/6ec742f3-c8b1-469e-8358-dc5fa3164805)
![3](https://github.com/DmitryGaimaldinov/tages_test/assets/123044629/e30a8d1f-2b9f-4f28-b403-4c9c864da368)



Ошибка снятия, когда в банкомате не хватает купюр
![4_land](https://github.com/DmitryGaimaldinov/tages_test/assets/123044629/7935625c-e67f-4a1b-ae1c-b4be30391ba9)
![4](https://github.com/DmitryGaimaldinov/tages_test/assets/123044629/f5bc5eaf-9d32-4424-8c31-efa628fffaef)



Алгоритм снятия денег, не допускающий просчётов (Находится в файле home_bloc):
```
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
```
