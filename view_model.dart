import 'package:flutter/material.dart';

/// {@tool snippet}
///
/// * This example shows how to use ViewModel
///
///  ```dart
/// class HomeViewModel extends ViewModel {
///   int count;
///   ValueNotifier<int> countNotifier;
///
///   HomeViewModel()
///       : count = 0,
///         countNotifier = ValueNotifier(0);
///
///   void increase() {
///     count = count + 1;
///     updateUI();
///     // only update widget using [ValueListenableBuilder]
///     countNotifier.value++;
///   }
///
///   @override
///   void dispose() {
///     countNotifier.dispose();
///   }
///
///   @override
///   void afterFirstLayout(BuildContext context) {}
/// }
///  ```
/// {@end-tool}
abstract class ViewModel {
  late BuildContext context;
  late void Function() updateUI;

  void afterFirstLayout(BuildContext context);

  void dispose();
}

/// {@tool snippet}
///
/// * This example shows how to use View View<ViewModel>
///
///  ```dart
// class HomeView extends View<HomeViewModel> {
///   const HomeView({super.key});
///
///   @override
///   ViewState<HomeView, HomeViewModel> createState() => _HomeViewState();
///
///   @override
///   HomeViewModel createViewModel() => HomeViewModel();
/// }
///  ```
/// {@end-tool}
abstract class View<TViewModel extends ViewModel> extends StatefulWidget {
  const View({super.key});

  @override
  ViewState createState();

  @protected
  @factory
  TViewModel createViewModel();
}

/// {@tool snippet}
///
/// * This example shows how to use ViewState
///
///  ```dart
/// class _HomeViewState extends ViewState<HomeView, HomeViewModel> {
///
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       children: <Widget>[
///         // * listen countNotifier and rebuild
///         ValueListenableBuilder<int>(
///           valueListenable: viewModel.countNotifier,
///           builder: (context, countN, child) {
///             return Text(
///               '$countN',
///               style: Theme.of(context).textTheme.headlineMedium,
///             );
///           },
///         ),
///         // * rebuild when updateUI call
///         Text(
///           '${viewModel.count}',
///           style: Theme.of(context)
///               .textTheme
///               .headlineMedium
///               ?.copyWith(color: Colors.pink),
///         ),
///         // * call action in viewModel (should have all logic in here 
///         // * ex: call api, refesh, ...)
///         FloatingActionButton(
///           onPressed: () => viewModel.increase(),
///           tooltip: 'Increse',
///           child: const Icon(Icons.add),
///         ),
///       ],
///     );
///   }
/// }
///  ```
/// {@end-tool}
abstract class ViewState<TView extends View<TViewModel>,
    TViewModel extends ViewModel> extends State<TView> {
  late final TViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = widget.createViewModel();
    viewModel.updateUI = updateUI;
    viewModel.context = context;

    WidgetsBinding.instance.endOfFrame.then(
      (_) {
        if (mounted) viewModel.afterFirstLayout(context);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.dispose();
  }

  updateUI() {
    if (mounted) setState(() {});
  }
}
