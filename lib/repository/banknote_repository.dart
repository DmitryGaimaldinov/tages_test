abstract class BanknoteRepository {

  Future<Map<int, int>> withdraw(Map<int, int> banknotes);

  Future<Map<int, int>> getLimits();

  Future<Map<int, int>> refreshLimits();
}

