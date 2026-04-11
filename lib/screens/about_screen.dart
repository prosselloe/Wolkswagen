import 'package:volkswagen/models/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../l10n/app_localizations.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  String _readmeContent = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_readmeContent.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _readmeContent = l10n.loading;
      });
      _loadReadme();
    }
  }

  Future<void> _loadReadme() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final content = await rootBundle.loadString('README.md');
      final creditsStartIndex = content.indexOf('## Crèdits');
      if (!mounted) return;
      setState(() {
        if (creditsStartIndex != -1) {
            _readmeContent = content.substring(0, creditsStartIndex);
        } else {
            _readmeContent = content;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _readmeContent = l10n.errorLoadingInfo;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final l10n = AppLocalizations.of(context)!;
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (!mounted) return; 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotOpenUrl(url))),
      );
    }
  }

  Future<void> _exportModelsToCsv() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final List<Model> allModels = [];
      final dbFiles = manifestMap.keys.where((String key) => key.startsWith('assets/data/db_')).toList();

      for (String dbFile in dbFiles) {
        final String modelsJsonString = await rootBundle.loadString(dbFile);
        final List<dynamic> modelsJson = json.decode(modelsJsonString);
        allModels.addAll(modelsJson.map((json) => Model.fromJson(json)));
      }

      List<List<dynamic>> rows = [];
      rows.add(['ID', 'Name', 'Description', 'Year', 'Image URL']);
      for (var model in allModels) {
        rows.add([model.id, model.name, model.description, model.year, model.imageUrl]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/models.csv';
      final file = File(path);
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(path)], text: l10n.csvDataMessage);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorExportingData(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutScreenTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(data: _readmeContent),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _exportModelsToCsv,
              icon: const Icon(Icons.download),
              label: Text(l10n.exportModelsToCsv),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.credits,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildCreditItem(
              context,
              'Amics del Volkswagen de Catalunya',
              'Grup d\'amics que tenen una passió comuna: els seus VW Escarabats, que es va fundar l\'any 1983',
              'https://www.avwc.org/edatvw2.php',
            ),
            _buildCreditItem(
              context,
              'Amics dels Escarabats de ses Illes Balears',
              'T1, T2, VW, VolksWagen, AirCooled, Beetle, Karmann Ghia, Kubelwagen, Buggy',
              'http://aeib.info',
            ),
            _buildCreditItem(
              context,
              'TheSamba.com',
              'Classified ads, photos, shows, links, forums, and technical information for the Volkswagen automobile',
              'https://www.thesamba.com/vw/archives/info/chassisdating.php',
            ),
            _buildCreditItem(
              context,
              'Google Firebase Gemini',
              'Tecnologia d\'IA generativa',
              'https://firebase.google.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditItem(BuildContext context, String title, String subtitle, String url) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => _launchURL(url),
      ),
    );
  }
}
