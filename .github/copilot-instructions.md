<!-- Copilot instructions for working on the RPL-Dollars Flutter app -->
# RPL-Dollars — Quick Agent Guide

Purpose: Help AI coding agents become productive quickly by describing the app structure, key patterns, and concrete developer workflows.

1. Big picture
- Single-app Flutter project using local Hive DB for persistence. See [lib/main.dart](lib/main.dart#L1) for app bootstrap: adapters are registered and boxes opened before `runApp()`.
- State is provided via `provider` ChangeNotifiers: `CategoryProvider` and `TransactionProvider` (see [lib/providers](lib/providers)).
- Data flow: UI -> Provider -> Hive box. Providers load/save directly to Hive boxes named `transactions` and `categories`.

2. Key files & responsibilities
- App bootstrap: [lib/main.dart](lib/main.dart#L1)
- Models (Hive annotated): [lib/models/transaction_model.dart](lib/models/transaction_model.dart#L1), [lib/models/category_model.dart](lib/models/category_model.dart#L1)
- Providers: [lib/providers/transaction_provider.dart](lib/providers/transaction_provider.dart#L1), [lib/providers/category_provider.dart](lib/providers/category_provider.dart#L1)
- Screens: [lib/screens](lib/screens) (e.g., [add_transaction_screen.dart](lib/screens/add_transaction_screen.dart#L1))
- Shared UI: [lib/widgets](lib/widgets) — note `GlassCard` is used extensively for the app’s visual style.
- Theme/colors: [lib/utils/theme.dart](lib/utils/theme.dart), [lib/utils/colors.dart](lib/utils/colors.dart)

3. Project-specific conventions (do not assume defaults)
- Persistence: Models use Hive annotations and generated adapters (`*.g.dart`). Always re-run codegen after model changes.
- Box names are literal strings: `transactions` and `categories`. Providers access boxes via `Hive.box('transactions')`.
- IDs are generated with `uuid.v4()` (see `CategoryProvider` and screens that create transactions).
- Icons are stored as `iconCodePoint` (an integer). To render: `IconData(iconCodePoint, fontFamily: 'MaterialIcons')`.
- Transaction sorting: `TransactionProvider.transactions` sorts by `date` on every getter call — be mindful of performance for large datasets.

4. Developer workflows & commands
- Install deps: `flutter pub get`
- Run app: `flutter run` (mobile) or use Flutter tooling in your environment.
- Hive codegen: after changing model annotations, run:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
- To regenerate repeatedly during development:
  ```bash
  flutter pub run build_runner watch
  ```
- Tests: `flutter test`

5. Integration & runtime caveats
- `main()` must call `await Hive.initFlutter()` and register adapters before opening boxes — moving provider creation before boxes are opened will break providers that access boxes in their constructors.
- Providers call `load*()` in their constructors and call `notifyListeners()` after loading. Prefer calling provider methods (e.g., `addTransaction`) rather than manipulating boxes directly in widgets.

6. Typical change pattern (example)
- Change a model (e.g., add a field to `TransactionModel` in [lib/models/transaction_model.dart](lib/models/transaction_model.dart#L1)).
- Run the build_runner codegen command above.
- Update any providers that read/write the new field and adjust UI/screens that display or populate it.

7. Areas to review first when debugging
- If the app fails at startup, check `main.dart` for adapter registration and box opening order.
- If categories/transactions appear missing, inspect `CategoryProvider.loadCategories()` and `_addDefaultCategories()` in [lib/providers/category_provider.dart](lib/providers/category_provider.dart#L1).
- If icons fail to render, confirm `iconCodePoint` values and usage in `CategoryProvider.getIconForCategory()`.

8. Examples (concrete snippets to replicate)
- Creating a transaction ID: `final id = const Uuid().v4();` (used in `add_transaction_screen.dart`).
- Formatting currency: `NumberFormat('#,##0', 'id_ID').format(amount)` (see numeric display in `add_transaction_screen.dart`).

9. Where to look for test/CI conventions
- No CI files detected in repo root. Use standard `flutter test` and include `build_runner` step when codegen changes exist.

10. If you make edits
- Regenerate Hive adapters when models change.
- Preserve `Hive.registerAdapter(...)` order in `main.dart` if you add new typeIds.
- Keep box names consistent; do not rename boxes without a migration plan.

If anything above is unclear or you want the agent to focus on a different area (migration, adding feature X, or writing tests), tell me which area and I'll iterate the instructions. 
