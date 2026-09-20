import 'package:mobile/error_handler/error_result.dart'; 
import 'package:mobile/error_handler/failure.dart'; 
import '../repository/search_history_repository.dart';
import '../storage/search_history_local_ds.dart';

class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  SearchHistoryRepositoryImpl(this._ds);
  final SearchHistoryLocalDataSource _ds;

  @override
  Future<Result<List<String>>> getHistory() => _guard(_ds.read);

  @override
  Future<Result<List<String>>> add(String query) => _guard(() async {
        final q = query.trim();
        final items = await _ds.read();
        if (q.length < 2) return items;
        items
          ..removeWhere((e) => e.toLowerCase() == q.toLowerCase()) // dublikatsiz
          ..insert(0, q);
        final trimmed = items.take(SearchHistoryLocalDataSource.maxItems).toList();
        await _ds.write(trimmed);
        return trimmed;
      });

  @override
  Future<Result<List<String>>> remove(String query) => _guard(() async {
        final items = await _ds.read()
          ..removeWhere((e) => e == query);
        await _ds.write(items);
        return items;
      });

  @override
  Future<Result<List<String>>> clear() => _guard(() async {
        await _ds.write(const []);
        return <String>[];
      });

  Future<Result<List<String>>> _guard(Future<List<String>> Function() action) async {
    try {
      return Success(await action());
    } catch (_) {
      return Error<List<String>>(const CacheFailure());
    }
  }
}

