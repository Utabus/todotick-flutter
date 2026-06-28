import '../../domain/entities/category.dart';

class CategoryRepository {
  final List<Category> _categories = [
    const Category(
      id: 'all',
      name: 'Tất cả',
      colorValue: 0xFF2563EB,
      icon: '📋',
    ),
    const Category(
      id: '1',
      name: 'Công việc',
      colorValue: 0xFF3B82F6,
      icon: '💼',
    ),
    const Category(
      id: '2',
      name: 'Riêng tư',
      colorValue: 0xFF22C55E,
      icon: '🏠',
    ),
  ];

  Future<List<Category>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _categories;
  }

  Future<void> addCategory(Category category) async {
    _categories.add(category);
  }
}
