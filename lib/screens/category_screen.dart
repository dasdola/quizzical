import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/quiz_provider.dart';
import '../utils/app_theme.dart';
import '../utils/category_style.dart';
import '../utils/constants.dart';
import '../widgets/category_card.dart';
import '../widgets/error_banner.dart';
import 'configuration_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    // Loads on first visit only; the provider caches the list afterwards.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<QuizProvider>().loadCategories();
    });
  }

  void _openConfiguration(Category category) {
    context.read<QuizProvider>().selectCategory(category);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConfigurationScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      AppStrings.appName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose a category to focus on',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Consumer<QuizProvider>(
                      builder: (context, quiz, _) {
                        if (quiz.categoriesError != null &&
                            !quiz.categoriesLoading) {
                          return Align(
                            alignment: Alignment.topCenter,
                            child: ErrorBanner(
                              message: quiz.categoriesError!,
                              onRetry: () => quiz.loadCategories(force: true),
                            ),
                          );
                        }
                        if (quiz.categoriesLoading || quiz.categories.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(
                              semanticsLabel: 'Loading categories',
                            ),
                          );
                        }
                        return GridView.builder(
                          padding: const EdgeInsets.only(bottom: 24),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.95,
                          ),
                          itemCount: quiz.categories.length,
                          itemBuilder: (context, index) {
                            final category = quiz.categories[index];
                            return CategoryCard(
                              category: category,
                              color: kCategoryCardColors[
                                  index % kCategoryCardColors.length],
                              onTap: () => _openConfiguration(category),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
