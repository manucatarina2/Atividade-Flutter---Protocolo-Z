import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shelter.dart';
import '../../repositories/shelter_repository.dart';

final shelterRepositoryProvider = Provider((ref) => ShelterRepository());

final sheltersProvider = FutureProvider.autoDispose<List<Shelter>>((ref) async {
  return ref.watch(shelterRepositoryProvider).fetchShelters();
});
