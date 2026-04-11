import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:volkswagen/providers/locale_provider.dart';
import 'package:volkswagen/providers/model_provider.dart';
import 'package:volkswagen/models/vw_model.dart';
import 'package:volkswagen/widgets/plant_map.dart';
import 'package:volkswagen/widgets/chassis_search_dialog.dart';
import 'package:volkswagen/widgets/vin_decoder_dialog.dart';
import 'package:volkswagen/screens/about_screen.dart';
import 'package:volkswagen/services/vin_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ca', null);
  await VinService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ModelProvider()),
        ChangeNotifierProvider(create: (context) => LocaleProvider()),
      ],
      child: const VWClassicsApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'details',
          builder: (BuildContext context, GoRouterState state) {
            final VWModel model = state.extra as VWModel;
            return DetailScreen(model: model);
          },
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutScreen(),
        ),
      ],
    ),
  ],
);

class VWClassicsApp extends StatelessWidget {
  const VWClassicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Color(0xFF001e50); // VW Blue
    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.exo2(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.exo2(fontSize: 24, fontWeight: FontWeight.w600),
      bodyMedium: GoogleFonts.lato(fontSize: 14, height: 1.5),
       bodySmall: GoogleFonts.lato(fontSize: 12),
      labelLarge: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
        surface: const Color(0xFFf5f5f5),
      ),
      textTheme: appTextTheme,
      scaffoldBackgroundColor: const Color(0xFFf5f5f5),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF001e50),
        foregroundColor: Colors.white, // This will make icons white
        titleTextStyle: GoogleFonts.exo2(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Explicitly set text color to white
        ),
        elevation: 2,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        prefixIconColor: Colors.grey[600],
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.exo2(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: const Color(0xFF1E1E1E),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2d3436),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        prefixIconColor: Colors.grey[400],
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        collapsedBackgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp.router(
          routerConfig: _router,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          locale: localeProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _imagesPrecached = false;
  bool _isMapVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<ModelProvider>(context, listen: false);

    if (!_imagesPrecached && provider.allModels.isNotEmpty) {
      _precacheImages(provider.allModels);
      _imagesPrecached = true;
    }
  }

  Future<void> _precacheImages(List<VWModel> models) async {
    for (final model in models) {
      if (mounted) {
        await precacheImage(AssetImage(model.imageUrl), context);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<ModelProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final availablePlants = provider.getAvailablePlants();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.go('/about'),
            tooltip: l10n.aboutScreenTitle,
          ),
          IconButton(
            icon: const Icon(Icons.pin_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const VinDecoderDialog(),
              );
            },
            tooltip: l10n.vinDecoderTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.numbers),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const ChassisSearchDialog(),
              );
            },
            tooltip: l10n.chassisSearchTooltip,
          ),
          if (availablePlants.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.factory_outlined),
              tooltip: l10n.filterByPlantTooltip,
              onOpened: () {
                if (mounted) {
                  setState(() {
                    _isMapVisible = true;
                  });
                }
              },
              onCanceled: () {
                if (provider.selectedPlant == null) {
                  setState(() {
                    _isMapVisible = false;
                  });
                }
              },
              onSelected: (String? plantName) {
                provider.filterByPlant(plantName);
                if (plantName == null) {
                  setState(() {
                    _isMapVisible = false;
                  });
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: null,
                    child: Text(l10n.allPlants),
                  ),
                  ...availablePlants.map((plant) {
                    return PopupMenuItem<String>(
                      value: plant.name,
                      child: Row(
                        children: [
                          Text(plant.flag),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(plant.name, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    );
                  }),
                ];
              },
            ),
          PopupMenuButton<SortType>(
            icon: const Icon(Icons.sort),
            tooltip: l10n.sortTooltip,
            onSelected: (SortType type) {
              provider.sort(type);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortType>>[
              PopupMenuItem<SortType>(
                value: SortType.byName,
                child: Text(l10n.sortByName),
              ),
              PopupMenuItem<SortType>(
                value: SortType.byYear,
                child: Text(l10n.sortByYear),
              ),
              PopupMenuItem<SortType>(
                value: SortType.byUnits,
                child: Text(l10n.sortByUnits),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<SortType>(
                value: SortType.none,
                child: Text(l10n.defaultSort),
              ),
            ],
          ),
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            tooltip: l10n.languageTooltip,
            onSelected: (Locale locale) {
              localeProvider.setLocale(locale);
            },
            itemBuilder: (BuildContext context) {
              return AppLocalizations.supportedLocales.map((locale) {
                return PopupMenuItem<Locale>(
                  value: locale,
                  child: Text(localeProvider.getLocaleName(locale.languageCode)),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => provider.search(value),
                  decoration: InputDecoration(
                    hintText: l10n.searchModelsHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: l10n.clearSearch,
                            onPressed: () {
                              _searchController.clear();
                              provider.search('');
                            },
                          )
                        : null,
                  ),
                ),
                if (provider.selectedPlant != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Chip(
                      label: Text(
                        l10n.activeFilter(provider.selectedPlant!),
                      ),
                      onDeleted: () {
                        provider.filterByPlant(null);
                        setState(() {
                          _isMapVisible = false;
                        });
                      },
                      deleteIcon: const Icon(Icons.close, size: 18),
                    ),
                  ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isMapVisible ? 250 : 0,
            child: _isMapVisible ? const PlantMap() : const SizedBox.shrink(),
          ),
          Expanded(
            child: Consumer<ModelProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(child: Text(l10n.loading));
                }

                if (provider.models.isEmpty) {
                  return Center(child: Text(l10n.noResultsFound));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.models.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    childAspectRatio: 4 / 3.5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final model = provider.models[index];

                    return Card(
                      elevation: 2,
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => context.go('/details', extra: model),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Hero(
                                tag: model.name,
                                child: Image.asset(
                                  model.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      model.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(fontSize: 18),
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            model.productionYears,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    color: Colors.grey[600]),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.build_sharp,
                                                size: 16,
                                                color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              NumberFormat.compact().format(model.unitsProduced),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                      color:
                                                          Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final VWModel model;

  const DetailScreen({super.key, required this.model});
  String _getDescription(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    final languageCode = locale?.languageCode ?? 'ca';
    switch (languageCode) {
      case 'en':
        return model.descriptionEn;
      case 'es':
        return model.descriptionEs;
      case 'fr':
        return model.descriptionFr;
      case 'pt':
        return model.descriptionPt;
      default:
        return model.descriptionCa;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              child: Text(
                model.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (model.isCabriolet)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(Icons.beach_access, color: colorScheme.secondary),
              ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).brightness == Brightness.light ? colorScheme.primary: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: model.name,
              child: Image.asset(
                model.imageUrl,
                height: 350,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 350,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.name,
                    style: textTheme.displayLarge?.copyWith(
                      fontSize: 36,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    model.productionYears,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.secondary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _getDescription(context),
                    style: textTheme.bodyMedium?.copyWith(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: colorScheme.outline.withAlpha(51),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.technicalSheet,
                            style: textTheme.titleLarge,
                          ),
                          const Divider(height: 24),
                          if (model.designer != null)
                            _buildDetailRow(
                              l10n.designer,
                              model.designer!,
                              textTheme,
                              colorScheme,
                              icon: Icons.design_services,
                            ),
                          _buildDetailRow(
                            l10n.unitsProduced,
                            NumberFormat.decimalPattern('ca').format(model.unitsProduced),
                            textTheme,
                            colorScheme,
                            icon: Icons.build_sharp,
                          ),
                          if (model.engine != null)
                            _buildDetailRow(
                              l10n.engine,
                              model.engine!,
                              textTheme,
                              colorScheme,
                              icon: Icons.engineering,
                            ),
                          if (model.topSpeed != null)
                            _buildDetailRow(
                              l10n.topSpeed,
                              model.topSpeed!,
                              textTheme,
                              colorScheme,
                              icon: Icons.speed,
                            ),
                          if (model.manufacturingPlant != null)
                            _buildDetailRow(
                              l10n.manufacturingPlant,
                              model.manufacturingPlant!,
                              textTheme,
                              colorScheme,
                              icon: Icons.factory,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (model.versions.isNotEmpty) ...[
                    Text(l10n.modelYearsAndChassis,
                        style: textTheme.titleLarge),
                    ...model.versions.map((version) => Card(
                          margin: const EdgeInsets.only(top: 12, bottom: 12),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.modelYear(version.modelYear),
                                  style: textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${DateFormat.yMMMMd('ca').format(DateTime.parse(version.dateFrom))} - ${DateFormat.yMMMMd('ca').format(DateTime.parse(version.dateTo))}',
                                  style: textTheme.bodySmall,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.confirmation_number_outlined,
                                        size: 16, color: colorScheme.secondary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${version.chassisFrom} - ${version.chassisTo}',
                                        style: textTheme.bodySmall?.copyWith(
                                            color: colorScheme.secondary,
                                            fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),)
                  ],
                  const SizedBox(height: 24),
                  Consumer<ModelProvider>(
                    builder: (context, provider, child) {
                      final related = provider.allModels
                          .where((m) => model.relatedModels.contains(m.id))
                          .toList();

                      if (related.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.relatedModels, style: textTheme.titleLarge),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: related.length,
                              itemBuilder: (context, index) {
                                final relatedModel = related[index];
                                return SizedBox(
                                  width: 150,
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    margin: const EdgeInsets.only(right: 16),
                                    child: InkWell(
                                      onTap: () {
                                        context.pushReplacement('/details', extra: relatedModel);
                                      },
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Image.asset(
                                              relatedModel.imageUrl,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.broken_image, color: Colors.grey),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              relatedModel.name,
                                              style: textTheme.bodySmall,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String title,
    String content,
    TextTheme textTheme,
    ColorScheme colorScheme, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: colorScheme.primary, size: 22),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.labelLarge),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
