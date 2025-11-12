import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tugas_akhir_valorant/model/bundles_models.dart';
import 'package:tugas_akhir_valorant/model/weapons_model.dart';
import 'package:tugas_akhir_valorant/services/weapons_services.dart';
import 'package:tugas_akhir_valorant/database/db_helper.dart';

class BundleDetailPage extends StatefulWidget {
  final BundlesModel bundle;

  const BundleDetailPage({super.key, required this.bundle});

  @override
  State<BundleDetailPage> createState() => _BundleDetailPageState();
}

class _BundleDetailPageState extends State<BundleDetailPage> {
  late Future<List<WeaponsModel>> _futureWeapons;
  Skin? _selectedSkin;
  List<Skin> _availableSkins = [];
  final DBHelper _dbHelper = DBHelper();
  int _availableVP = 0;
  int _bundlePrice = 5010; // Default harga bundle

  @override
  void initState() {
    super.initState();
    _futureWeapons = WeaponService().getWeapons();
    _loadAvailableVP();
    _bundlePrice = _getBundlePrice(widget.bundle.displayName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh VP saat halaman dibuka kembali
    _loadAvailableVP();
  }

  Future<void> _loadAvailableVP() async {
    final vp = await _dbHelper.getAvailableVP();
    if (mounted) {
      setState(() {
        _availableVP = vp;
      });
    }
  }

  // Mendapatkan harga bundle berdasarkan nama
  int _getBundlePrice(String bundleName) {
    final name = bundleName.toUpperCase();
    // Mapping harga bundle berdasarkan nama (bisa disesuaikan)
    if (name.contains('XENOHUNTER') ||
        name.contains('RGX 11Z PRO') ||
        name.contains('DIVERGENCE') ||
        name.contains('SPECTRUM') ||
        name.contains('DIVERGENCE')) {
      return 5012; // Ultra/Premium bundle
    } else if (name.contains('STANDARD') || name.contains('BASIC')) {
      return 3300; // Standard bundle
    } else {
      // Default harga berdasarkan jumlah skin
      return 3100; // Harga default
    }
  }

  List<Skin> _filterSkinsByBundleName(List<WeaponsModel> weapons) {
    final List<Skin> matchedSkins = [];
    final String bundleName = widget.bundle.displayName.toUpperCase();

    for (var weapon in weapons) {
      for (var skin in weapon.skins) {
        if (skin.displayName.toUpperCase().contains(bundleName)) {
          matchedSkins.add(skin);
        }
      }
    }

    return matchedSkins;
  }

  Widget _buildImageErrorPlaceholder() {
    return Container(
      color: Colors.white.withOpacity(0.05),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white30,
          size: 60,
        ),
      ),
    );
  }

  Widget _buildImageLoadingIndicator(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) return child;
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFFF4655)),
    );
  }

  Future<void> _purchaseBundle() async {
    // Tampilkan dialog konfirmasi
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B252F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Konfirmasi Pembelian",
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Anda akan membeli bundle:",
                style: GoogleFonts.rajdhani(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.bundle.displayName.toUpperCase(),
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFFFF4655),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/vp.png', width: 24, height: 24),
                  const SizedBox(width: 8),
                  Text(
                    '$_bundlePrice VP',
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "Batal",
                style: GoogleFonts.rajdhani(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Beli",
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFFFF4655),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Proses pembelian
      final success = await _dbHelper.purchaseBundle(
        widget.bundle.displayName,
        _bundlePrice,
      );

      if (mounted) {
        if (success) {
          // Refresh VP
          await _loadAvailableVP();

          // Tampilkan dialog sukses
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFF1B252F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Text(
                  "Pembelian Berhasil!",
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFFFF4655),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                content: Text(
                  "Bundle berhasil dibeli. VP Anda telah dikurangi.",
                  style: GoogleFonts.rajdhani(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "OK",
                      style: GoogleFonts.rajdhani(
                        color: const Color(0xFFFF4655),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          // Tampilkan dialog error
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFF1B252F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Text(
                  "VP Tidak Cukup",
                  style: GoogleFonts.rajdhani(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                content: Text(
                  "VP Anda tidak cukup untuk membeli bundle ini. Silakan top up terlebih dahulu.",
                  style: GoogleFonts.rajdhani(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "OK",
                      style: GoogleFonts.rajdhani(
                        color: const Color(0xFFFF4655),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1823),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.bundle.displayName.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Tungsten-Bold',
            fontSize: 30,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4655).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFF4655), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/vp.png', width: 20, height: 20),
                const SizedBox(width: 6),
                Text(
                  '$_availableVP',
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<WeaponsModel>>(
        future: _futureWeapons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF4655)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Failed to load skins.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontFamily: 'Teko',
                  fontSize: 20,
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No weapons found.",
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Teko',
                  fontSize: 22,
                ),
              ),
            );
          }

          _availableSkins = _filterSkinsByBundleName(snapshot.data!)
              .where(
                (skin) =>
                    skin.displayIcon != null && skin.displayIcon!.isNotEmpty,
              )
              .toList();

          if (_availableSkins.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No matching skins found",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontFamily: 'Teko',
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "for ${widget.bundle.displayName}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontFamily: 'Teko',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          // Initialize selected skin if not set
          if (!mounted) return const SizedBox.shrink();
          if (_selectedSkin == null && _availableSkins.isNotEmpty) {
            _selectedSkin = _availableSkins.first;
          }

          if (_selectedSkin == null) {
            return const SizedBox.shrink();
          }

          final String mainImageUrl = _selectedSkin!.displayIcon ?? '';

        return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: mainImageUrl.isEmpty
                          ? _buildImageErrorPlaceholder()
                          : Image.network(
                              mainImageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: _buildImageLoadingIndicator,
                              errorBuilder: (context, _, __) =>
                                  _buildImageErrorPlaceholder(),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _selectedSkin!.displayName.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Tungsten-Bold',
                          fontSize: 26,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("SKINS",
                          style: TextStyle(
                              fontFamily: 'Tungsten-Bold',
                              fontSize: 18,
                              color: Color(0xFFFF4655))),
                    ),
                    const Divider(color: Color(0xFFFF4655), thickness: 2),
                    const SizedBox(height: 10),

                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _availableSkins.length,
                        itemBuilder: (context, i) {
                          final skin = _availableSkins[i];
                          final bool isSelected =
                              skin.uuid == _selectedSkin?.uuid;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedSkin = skin),
                            child: Container(
                              width: 90,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFF4655)
                                      : Colors.white.withOpacity(0.2),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  skin.displayIcon ?? '',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, _, __) =>
                                      _buildImageErrorPlaceholder(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFFFF4655).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/vp.png',
                              width: 24, height: 24),
                          const SizedBox(width: 8),
                          Text('$_bundlePrice VP',
                              style: const TextStyle(
                                  fontFamily: 'Tungsten-Bold',
                                  fontSize: 22,
                                  color: Color(0xFFFF4655))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _availableVP >= _bundlePrice
                            ? _purchaseBundle
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _availableVP >= _bundlePrice
                              ? const Color(0xFFFF4655)
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _availableVP >= _bundlePrice
                              ? "BUY BUNDLE"
                              : "INSUFFICIENT VP",
                          style: const TextStyle(
                              fontFamily: 'Tungsten-Bold',
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
