import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../widgets/theme_switcher.dart';

class IsoHomePage extends StatefulWidget {
  const IsoHomePage({super.key});

  @override
  State<IsoHomePage> createState() => _IsoHomePageState();
}

class _IsoHomePageState extends State<IsoHomePage> {
  // --- STATE ---
  String? selectedOs;
  String? selectedWindowsType; // 'Customer' or 'Server' for Windows
  String? selectedLinuxDistro;
  String? selectedVersion;
  int step = 0;
  bool isDark = false;

  Map<String, dynamic>? remoteIsoLinks;
  bool isLoadingLinks = true;
  String? loadError;

  // New: generic for any OS with distros
  String? selectedDistroCategory; // e.g. 'Linux', 'NAS', etc.
  String? selectedDistro;

  void toggleTheme() => setState(() => isDark = !isDark);

  @override
  void initState() {
    super.initState();
    fetchIsoLinks();
  }

  Future<void> fetchIsoLinks() async {
    setState(() {
      isLoadingLinks = true;
      loadError = null;
    });
    try {
      final url = Uri.parse(
        'https://gist.githubusercontent.com/fabienmillet/91f9d1fb929c15a85bf500f6cbacf6de/raw/8cb9470d40379a0a7f4c419e16bfc71b2b3f950e/os.json?v=${DateTime.now().millisecondsSinceEpoch}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          remoteIsoLinks = json.decode(response.body);
          isLoadingLinks = false;
        });
      } else {
        setState(() {
          loadError =
              'Erreur de chargement des liens ISO (code {response.statusCode})';
          isLoadingLinks = false;
        });
      }
    } catch (e) {
      setState(() {
        loadError = 'Erreur de chargement des liens ISO ($e)';
        isLoadingLinks = false;
      });
    }
  }

  void reset() {
    setState(() {
      step = 0;
      selectedOs = null;
      selectedWindowsType = null;
      selectedLinuxDistro = null;
      selectedVersion = null;
      selectedDistroCategory = null;
      selectedDistro = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingLinks) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (loadError != null) {
      return Scaffold(
        body: Center(
          child: Text(loadError!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF181A20)
          : const Color(0xFFF5F6FA),
      appBar: null,
      body: Stack(
        children: [
          ThemeSwitcher(isDark: isDark, toggleTheme: toggleTheme),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF24272A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black54 : Colors.black12,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                child: _buildStep(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() {
    if (remoteIsoLinks == null) return const SizedBox.shrink();
    switch (step) {
      case 0:
        return _Step0(
          isDark: isDark,
          remoteIsoLinks: remoteIsoLinks!,
          onOsSelected: (os) {
            final osData = remoteIsoLinks![os] ?? {};
            
            // Vérifier si c'est un OS avec une structure spéciale "distros" qui a besoin d'un choix de type
            // (comme Windows avec Customer/Server)
            if (osData['distros'] != null && osData['distros'] is Map) {
              final distros = osData['distros'] as Map<String, dynamic>;
              
              // Si il y a exactement 2 distros et qu'elles ont toutes des versions, 
              // c'est probablement un OS comme Windows qui nécessite un choix de type
              if (distros.length == 2 && 
                  distros.values.every((distro) => distro is Map && distro['versions'] != null)) {
                // Structure Windows-like : montrer le choix de type
                setState(() {
                  step = 2; // Type selection step
                  selectedOs = os;
                  selectedDistroCategory = null;
                  selectedDistro = null;
                });
              } else {
                // Structure générique : traiter comme distros normales (Linux, NAS, ...)
                setState(() {
                  selectedDistroCategory = os;
                  step = 1;
                });
              }
            } else if (osData['versions'] != null) {
              // OS avec versions directes (macOS)
              setState(() {
                selectedOs = os;
                step = 3;
              });
            } else {
              // Should not happen, fallback
              setState(() {
                selectedOs = os;
                step = 0;
              });
            }
          },
        );
      case 1:
        // Generic distros step (for Linux, NAS, ...)
        final osData = remoteIsoLinks![selectedDistroCategory] ?? {};
        final distros = Map<String, dynamic>.from(osData['distros'] ?? {});
        return _DistrosStep(
          isDark: isDark,
          category: selectedDistroCategory!,
          distros: distros,
          onBack: reset,
          onDistroSelected: (distro) {
            final distroData = distros[distro] ?? {};
            if (distroData['iso'] != null &&
                (distroData['iso'] as String).isNotEmpty) {
              // Direct ISO download
              final url = distroData['iso'];
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            } else if (distroData['versions'] != null &&
                distroData['versions'] is Map) {
              setState(() {
                selectedDistro = distro;
                step = 4;
              });
            } else {
              // No ISO or versions, show error
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Aucune version ou ISO disponible pour cette distribution.',
                  ),
                ),
              );
            }
          },
        );
      case 2:
        // Type selection step (for OS with exactly 2 distro types like Windows Customer/Server)
        final osData = remoteIsoLinks![selectedOs] ?? {};
        final distros = Map<String, dynamic>.from(osData['distros'] ?? {});
        return _TypeSelectionStep(
          isDark: isDark,
          osName: selectedOs!,
          distros: distros,
          onBack: reset,
          onTypeSelected: (type) {
            setState(() {
              selectedWindowsType = type;
              step = 3;
              // Réinitialiser les variables de distro pour éviter les conflits
              selectedDistroCategory = null;
              selectedDistro = null;
            });
          },
        );
      case 3:
        // Version selection: for OS with types (like Windows) or direct versions (like macOS)
        if (selectedOs != null && selectedWindowsType != null) {
          // OS with type selection (like Windows Customer/Server)
          final osData = remoteIsoLinks![selectedOs] ?? {};
          final distros = osData['distros'] as Map<String, dynamic>? ?? {};
          final type = selectedWindowsType!;
          final typeData = distros[type] as Map<String, dynamic>? ?? {};
          final versions = typeData['versions'] as Map<String, dynamic>? ?? {};
          
          // Génération dynamique du nom d'affichage
          String displayName = selectedOs!;
          if (selectedOs == 'Windows' && type == 'Server') {
            displayName = 'Windows Server';
          } else if (selectedOs == 'Windows' && type == 'Customer') {
            displayName = 'Windows';
          } else {
            displayName = '$selectedOs $type';
          }
          
          return _VersionStep(
            isDark: isDark,
            os: displayName,
            iconUrl: typeData['icon'] ?? osData['icon'] ?? '',
            versions: versions,
            onBack: () {
              setState(() {
                step = selectedWindowsType == null ? 0 : 2;
                selectedVersion = null;
              });
            },
            onVersionSelected: (ver) {
              setState(() {
                selectedVersion = ver;
                step = 5;
              });
            },
          );
        } else if (selectedOs != null) {
          // OS with direct versions (like macOS)
          final osData = remoteIsoLinks![selectedOs];
          final versions = Map<String, dynamic>.from(osData?['versions'] ?? {});
          return _VersionStep(
            isDark: isDark,
            os: selectedOs!,
            iconUrl: osData?['icon'] ?? '',
            versions: versions,
            onBack: () {
              setState(() {
                step = 0;
                selectedVersion = null;
              });
            },
            onVersionSelected: (ver) {
              setState(() {
                selectedVersion = ver;
                step = 5;
              });
            },
          );
        }
        return const SizedBox.shrink();
      case 4:
        // Generic: select version for selected distro (Linux, NAS, ...)
        final osData = remoteIsoLinks![selectedDistroCategory] ?? {};
        final distros = Map<String, dynamic>.from(osData['distros'] ?? {});
        if (selectedDistro == null || !distros.containsKey(selectedDistro)) {
          return Center(
            child: Text(
              "Erreur : distribution inconnue ($selectedDistro)",
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
          );
        }
        final distroData = distros[selectedDistro] ?? {};
        final versions = Map<String, dynamic>.from(
          distroData['versions'] ?? {},
        );
        if (versions.isEmpty) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark ? Colors.white : Colors.deepPurple,
                    ),
                    onPressed: () {
                      setState(() {
                        step = 1;
                        selectedVersion = null;
                      });
                    },
                  ),
                  Text(
                    selectedDistro!,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                "Aucune version disponible pour $selectedDistro",
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ],
          );
        }
        return _VersionStep(
          isDark: isDark,
          os: selectedDistro!,
          iconUrl: distroData['icon'] ?? '',
          versions: versions,
          onBack: () {
            setState(() {
              step = 1;
              selectedVersion = null;
            });
          },
          onVersionSelected: (ver) {
            setState(() {
              selectedVersion = ver;
              step = 5;
            });
          },
        );
      case 5:
        // Download step - Complètement dynamique
        if (selectedVersion != null) {
          // Cas 1: OS avec types (comme Windows Customer/Server)
          if (selectedOs != null && selectedWindowsType != null) {
            final osData = remoteIsoLinks![selectedOs] ?? {};
            final distros = osData['distros'] as Map<String, dynamic>? ?? {};
            final typeData = distros[selectedWindowsType!] as Map<String, dynamic>? ?? {};
            
            // Génération dynamique du nom d'affichage
            String osDisplayName = selectedOs!;
            if (selectedOs == 'Windows' && selectedWindowsType == 'Server') {
              osDisplayName = 'Windows Server';
            } else if (selectedOs == 'Windows' && selectedWindowsType == 'Customer') {
              osDisplayName = 'Windows';
            } else {
              osDisplayName = '$selectedOs $selectedWindowsType';
            }
            
            return _DownloadStep(
              isDark: isDark,
              os: osDisplayName,
              version: selectedVersion!,
              osData: typeData,
              onBack: () {
                setState(() {
                  step = 3;
                });
              },
            );
          } 
          // Cas 2: OS avec versions directes (comme macOS)
          else if (selectedOs != null) {
            return _DownloadStep(
              isDark: isDark,
              os: selectedOs!,
              version: selectedVersion!,
              osData: remoteIsoLinks![selectedOs]!,
              onBack: () {
                setState(() {
                  step = 3;
                });
              },
            );
          } 
          // Cas 3: Distros génériques (Linux, NAS, etc.)
          else if (selectedDistroCategory != null && selectedDistro != null) {
            final osData = remoteIsoLinks![selectedDistroCategory] ?? {};
            final distros = osData['distros'] ?? {};
            final distroData = distros[selectedDistro] ?? {};
            return _DownloadStep(
              isDark: isDark,
              os: selectedDistro!,
              version: selectedVersion!,
              osData: distroData,
              onBack: () {
                setState(() {
                  step = 4;
                });
              },
            );
          }
        }
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }
}

// --- Step 0: OS Selection ---
class _Step0 extends StatelessWidget {
  final bool isDark;
  final Map<String, dynamic> remoteIsoLinks;
  final void Function(String) onOsSelected;
  const _Step0({
    required this.isDark,
    required this.remoteIsoLinks,
    required this.onOsSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Liste dynamique des OS à partir des clés du JSON, sauf si la clé commence par _
    final mainOsList = [...remoteIsoLinks.keys];
    return Column(
      key: const ValueKey('step0'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '2C2T-ISO',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: isDark ? Colors.white : Colors.deepPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 36),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 32,
          runSpacing: 32,
          children: [
            for (final os in mainOsList)
              Builder(
                builder: (context) {
                  final osData = remoteIsoLinks[os] ?? {};
                  // Si c'est un OS à ISO direct (clé 'iso' présente au niveau racine)
                  if (osData['iso'] != null &&
                      (osData['iso'] as String).isNotEmpty) {
                    return GestureDetector(
                      onTap: () async {
                        final url = osData['iso'];
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Impossible d\'ouvrir le lien de téléchargement.',
                              ),
                            ),
                          );
                        }
                      },
                      child: _OsTile(
                        label: os,
                        iconUrl: osData['icon'] ?? '',
                        isDark: isDark,
                      ),
                    );
                  }
                  // Sinon, comportement normal (sélection de versions/distros)
                  return GestureDetector(
                    onTap: () => onOsSelected(os),
                    child: _OsTile(
                      label: os,
                      iconUrl: osData['icon'] ?? '',
                      isDark: isDark,
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

// Nouvelle étape pour choisir le type d'OS (ex: Windows Customer/Server) - Dynamique
class _TypeSelectionStep extends StatelessWidget {
  final bool isDark;
  final String osName;
  final Map<String, dynamic> distros;
  final VoidCallback onBack;
  final void Function(String) onTypeSelected;
  
  const _TypeSelectionStep({
    required this.isDark,
    required this.osName,
    required this.distros,
    required this.onBack,
    required this.onTypeSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    final distroList = distros.keys.toList();
    
    return Column(
      key: const ValueKey('typeSelectionStep'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.deepPurple,
              ),
              onPressed: onBack,
            ),
            Text(
              osName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isDark ? Colors.white : Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Wrap(
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          spacing: 32,
          runSpacing: 32,
          children: [
            for (final distroType in distroList)
              GestureDetector(
                onTap: () => onTypeSelected(distroType),
                child: _OsTile(
                  label: _getDistroDisplayName(osName, distroType),
                  iconUrl: distros[distroType]['icon'] ?? '',
                  isDark: isDark,
                ),
              ),
          ],
        ),
      ],
    );
  }
  
  // Méthode pour générer des noms d'affichage appropriés
  String _getDistroDisplayName(String osName, String distroType) {
    if (osName == 'Windows') {
      return distroType == 'Server' ? 'Windows Server' : 'Windows';
    }
    // Pour d'autres OS futurs, on peut ajouter d'autres logiques ici
    return '$osName $distroType';
  }
}

// --- Generic Distros Step (for any OS with distros: Linux, NAS, etc.)
class _DistrosStep extends StatelessWidget {
  final bool isDark;
  final String category;
  final Map<String, dynamic> distros;
  final VoidCallback onBack;
  final void Function(String) onDistroSelected;
  const _DistrosStep({
    required this.isDark,
    required this.category,
    required this.distros,
    required this.onBack,
    required this.onDistroSelected,
  });
  @override
  Widget build(BuildContext context) {
    final distroList = distros.keys.toList();
    return Column(
      key: const ValueKey('distrosStep'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.deepPurple,
              ),
              onPressed: onBack,
            ),
            Text(
              category,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.deepPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 24,
          children: [
            for (final distro in distroList)
              GestureDetector(
                onTap: () => onDistroSelected(distro),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF34373B)
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.deepPurple,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      distros[distro]['icon'] != null &&
                              distros[distro]['icon'] is String &&
                              (distros[distro]['icon'] as String).isNotEmpty
                          ? Image.network(
                              distros[distro]['icon'],
                              height: 48,
                              width: 48,
                              errorBuilder: (c, e, s) =>
                                  const Icon(Icons.laptop),
                            )
                          : const Icon(Icons.laptop),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 100,
                        child: Text(
                          distro,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// --- OS Tile (for OS selection and Windows type selection)
class _OsTile extends StatelessWidget {
  final String label;
  final String iconUrl;
  final bool isDark;
  const _OsTile({
    required this.label,
    required this.iconUrl,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF34373B) : const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.deepPurple,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Appliquer l'effet ColorFiltered uniquement pour l'icône macOS en dark mode
          (label == 'macOS' && isDark && iconUrl.isNotEmpty)
              ? ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.network(
                    iconUrl,
                    height: 48,
                    width: 48,
                    errorBuilder: (c, e, s) => const Icon(Icons.laptop),
                  ),
                )
              : (iconUrl.isNotEmpty
                    ? Image.network(
                        iconUrl,
                        height: 48,
                        width: 48,
                        errorBuilder: (c, e, s) => const Icon(Icons.laptop),
                      )
                    : const Icon(Icons.laptop)),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.deepPurple,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionStep extends StatelessWidget {
  final bool isDark;
  final String os;
  final String iconUrl;
  final Map
  versions; // Utiliser Map sans <String, dynamic> pour garder LinkedHashMap
  final VoidCallback onBack;
  final void Function(String) onVersionSelected;
  const _VersionStep({
    required this.isDark,
    required this.os,
    required this.iconUrl,
    required this.versions,
    required this.onBack,
    required this.onVersionSelected,
  });
  @override
  Widget build(BuildContext context) {
    // Utilise l'ordre exact du JSON (LinkedHashMap)
    final versionList = versions.keys.toList();
    return Column(
      key: const ValueKey('versionStep'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.deepPurple,
              ),
              onPressed: onBack,
            ),
            Text(
              os,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: isDark ? Colors.white : Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        (os == 'macOS' && isDark && iconUrl.isNotEmpty)
            ? ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                child: Image.network(
                  iconUrl,
                  height: 80,
                  errorBuilder: (c, e, s) => const Icon(Icons.laptop),
                ),
              )
            : (iconUrl.isNotEmpty
                  ? Image.network(
                      iconUrl,
                      height: 80,
                      errorBuilder: (c, e, s) => const Icon(Icons.laptop),
                    )
                  : const Icon(Icons.laptop)),
        const SizedBox(height: 24),
        Text(
          'Choisis la version',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isDark ? Colors.white : Colors.deepPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 18,
          runSpacing: 18,
          children: [
            for (final ver in versionList)
              GestureDetector(
                onTap: () => onVersionSelected(ver),
                child: Container(
                  width: 100,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF34373B)
                        : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white24 : Colors.deepPurple,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      versions[ver]['icon'] != null
                          ? Image.network(
                              versions[ver]['icon'],
                              height: 32,
                              width: 32,
                              errorBuilder: (c, e, s) =>
                                  const Icon(Icons.laptop),
                            )
                          : const Icon(Icons.laptop),
                      const SizedBox(height: 8),
                      Text(
                        ver,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DownloadStep extends StatelessWidget {
  final bool isDark;
  final String os;
  final String version;
  final Map<String, dynamic> osData;
  final VoidCallback onBack;
  const _DownloadStep({
    required this.isDark,
    required this.os,
    required this.version,
    required this.osData,
    required this.onBack,
  });
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> versions = {};
    versions = Map<String, dynamic>.from(osData['versions'] ?? {});
    final versionData = versions[version] ?? {};
    final downloadLink = versionData['iso'] ?? '';
    final hasLink =
        downloadLink != null && downloadLink.toString().trim().isNotEmpty;
    return Column(
      key: const ValueKey('downloadStep'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.deepPurple,
              ),
              onPressed: onBack,
            ),
            const SizedBox(width: 8),
            Text(
              'Téléchargement de $os $version',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.deepPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 320,
            height: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF34373B) : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white54 : Colors.black54,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasLink)
                  Text(
                    'Vous êtes sur le point de télécharger un iSO de $os $version.',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  )
                else
                  Text(
                    "Aucun lien de téléchargement n'est disponible pour cette version.",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: hasLink
                      ? () async {
                          final url = Uri.parse(downloadLink);
                          final messenger = ScaffoldMessenger.maybeOf(context);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            if (messenger != null) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Could not launch download link.',
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 10,
                  ),
                  child: Text(
                    hasLink ? "Télécharger l'iSO" : 'Indisponible',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
