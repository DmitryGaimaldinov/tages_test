import 'banknote_repository.dart';

class MemoryBanknoteRepository extends BanknoteRepository {

  Map<int, int> _initLimits = {
    100: 50,
    200: 100,
    500: 5,
    1000: 10,
    2000: 100,
    5000: 10,
  };

  // Заполнены как в макете Figma.
  // Ключ - куплюра (для простоты сделал через int). Значение - количество.
  late Map<int, int> _limits = Map.of(_initLimits);

  @override
  Future<Map<int, int>> getLimits() async => Map.unmodifiable(_limits);

  @override
  Future<Map<int, int>> withdraw(Map<int, int> banknotes) async {
    banknotes.forEach((key, value) {
      _limits[key] = _limits[key]! - value;
    });

    return getLimits();
  }

  @override
  Future<Map<int, int>> refreshLimits() {
    _limits = Map.of(_initLimits);
    return getLimits();
  }
}