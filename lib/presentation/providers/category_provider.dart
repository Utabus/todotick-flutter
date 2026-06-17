import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_ai/domain/entities/category.dart';
import 'package:flutter_application_ai/data/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider((ref) => CategoryRepository());

final categoryListProvider =
    AsyncNotifierProvider<CategoryListNotifier, List<Category>>(() {
  return CategoryListNotifier();
});

class CategoryListNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    return ref.read(categoryRepositoryProvider).getCategories();
  }

  Future<void> addCategory(Category category) async {
    await ref.read(categoryRepositoryProvider).addCategory(category);
    state = AsyncData(
        await ref.read(categoryRepositoryProvider).getCategories());
  }
}
