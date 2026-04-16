import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/catalogue.dart';
import '../models/raccourci.dart';
import '../services/catalogue_service.dart';
import '../services/storage_service.dart';

class CatalogueScreen extends StatefulWidget {
  /// true = premier lancement, false = accès depuis le menu
  final bool premierLancement;

  /// URLs déjà présentes dans la liste de l'utilisateur
  final Set<String> urlsExistantes;

  /// Si fourni, utilise ces catégories au lieu du catalogue embarqué
  final List<CatalogueCategorie>? categories;

  const CatalogueScreen({
    super.key,
    required this.premierLancement,
    required this.urlsExistantes,
    this.categories,
  });

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  final CatalogueService _catalogueService = CatalogueService();
  final StorageService _storage = StorageService();

  List<CatalogueCategorie> _categories = [];
  // Set des id catalogue cochés
  final Set<String> _selectionnes = {};
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final categories = widget.categories ?? await _catalogueService.chargerCategories();
    setState(() {
      _categories = categories;
      _chargement = false;
    });
  }

  bool _dejaAjoute(CatalogueRaccourci r) {
    return widget.urlsExistantes.contains(r.url);
  }

  bool _categorieEntierementCochee(CatalogueCategorie cat) {
    final disponibles = cat.shortcuts.where((r) => !_dejaAjoute(r)).toList();
    if (disponibles.isEmpty) return false;
    return disponibles.every((r) => _selectionnes.contains(r.id));
  }

  bool _categoriePArtiellementCochee(CatalogueCategorie cat) {
    final disponibles = cat.shortcuts.where((r) => !_dejaAjoute(r)).toList();
    final nbCoches = disponibles.where((r) => _selectionnes.contains(r.id)).length;
    return nbCoches > 0 && nbCoches < disponibles.length;
  }

  void _toggleCategorie(CatalogueCategorie cat) {
    final disponibles = cat.shortcuts.where((r) => !_dejaAjoute(r)).toList();
    final toutCoches = _categorieEntierementCochee(cat);
    setState(() {
      if (toutCoches) {
        for (final r in disponibles) {
          _selectionnes.remove(r.id);
        }
      } else {
        for (final r in disponibles) {
          _selectionnes.add(r.id);
        }
      }
    });
  }

  void _toggleRaccourci(CatalogueRaccourci r) {
    setState(() {
      if (_selectionnes.contains(r.id)) {
        _selectionnes.remove(r.id);
      } else {
        _selectionnes.add(r.id);
      }
    });
  }

  Future<void> _valider() async {
    // Construire la liste des raccourcis sélectionnés
    final nouveaux = <Raccourci>[];
    final base = DateTime.now().millisecondsSinceEpoch;
    var i = 0;
    for (final cat in _categories) {
      for (final r in cat.shortcuts) {
        if (_selectionnes.contains(r.id)) {
          nouveaux.add(Raccourci(
            id: (base + i).toString(),
            nom: r.label,
            url: r.url,
          ));
          i++;
        }
      }
    }

    // Charger les raccourcis existants et ajouter les nouveaux
    final existants = await _storage.charger();
    await _storage.sauvegarder([...existants, ...nouveaux]);

    if (widget.premierLancement) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);
    }

    if (!mounted) return;

    if (widget.premierLancement) {
      // Remplacer l'écran catalogue par HomeScreen
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pop(context, nouveaux.length);
    }
  }

  Future<void> _passer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  int get _nbSelectionnes => _selectionnes.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(
          widget.premierLancement ? 'Bienvenue dans Sésame' : 'Catalogue',
        ),
        automaticallyImplyLeading: !widget.premierLancement,
      ),
      body: _chargement
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (widget.premierLancement)
                  Container(
                    width: double.infinity,
                    color: Colors.blue.shade50,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: const Text(
                      'Sélectionnez les raccourcis à ajouter. '
                      'Vous pourrez en ajouter d\'autres plus tard.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (_, i) => _buildCategorie(_categories[i]),
                  ),
                ),
                _buildBoutons(),
              ],
            ),
    );
  }

  Widget _buildCategorie(CatalogueCategorie cat) {
    final toutCoches = _categorieEntierementCochee(cat);
    final partiel = _categoriePArtiellementCochee(cat);
    final tousDejaAjoutes = cat.shortcuts.every(_dejaAjoute);

    return ExpansionTile(
      initiallyExpanded: true,
      leading: tousDejaAjoutes
          ? const Icon(Icons.check_circle, color: Colors.grey)
          : Checkbox(
              value: toutCoches ? true : (partiel ? null : false),
              tristate: true,
              onChanged: (_) => _toggleCategorie(cat),
            ),
      title: Text(
        cat.label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: cat.shortcuts.map((r) => _buildRaccourci(r)).toList(),
    );
  }

  Widget _buildRaccourci(CatalogueRaccourci r) {
    final dejaAjoute = _dejaAjoute(r);
    final coche = _selectionnes.contains(r.id);

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      leading: dejaAjoute
          ? const Icon(Icons.check, color: Colors.grey, size: 20)
          : Checkbox(
              value: coche,
              onChanged: (_) => _toggleRaccourci(r),
            ),
      title: Text(
        r.label,
        style: TextStyle(
          color: dejaAjoute ? Colors.grey : null,
        ),
      ),
      subtitle: Text(
        Uri.tryParse(r.url)?.host ?? r.url,
        style: const TextStyle(fontSize: 11),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: dejaAjoute
          ? const Text(
              'déjà ajouté',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            )
          : null,
      onTap: dejaAjoute ? null : () => _toggleRaccourci(r),
    );
  }

  Widget _buildBoutons() {
    final label = _nbSelectionnes == 0
        ? 'Valider'
        : 'Ajouter $_nbSelectionnes raccourci${_nbSelectionnes > 1 ? 's' : ''}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            if (widget.premierLancement)
              TextButton(
                onPressed: _passer,
                child: const Text('Passer'),
              ),
            if (widget.premierLancement) const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _nbSelectionnes > 0 || widget.premierLancement
                    ? _valider
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
