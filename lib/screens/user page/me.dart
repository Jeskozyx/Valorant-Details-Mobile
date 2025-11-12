import 'package:flutter/material.dart';
import 'package:tugas_akhir_valorant/database/db_helper.dart';
import 'package:tugas_akhir_valorant/form%20kesan%20pesan/kesan_pesan.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, dynamic>> _feedbackList = [];

  @override
  void initState() {
    super.initState();
    _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    final data = await DBHelper().getAllFeedback();
    setState(() {
      _feedbackList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1823),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "PROFIL SAYA",
          style: TextStyle(
            fontFamily: 'Teko',
            fontSize: 28,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 80,
                backgroundColor: Color(0xFFFF4655),
                child: CircleAvatar(
                  radius: 76,
                  // Pastikan Anda memiliki gambar 'profile.png' di folder assets/images/
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                  backgroundColor: Color(0xFF1B252F),
                ),
              ),
              const SizedBox(height: 40),
              _buildInfoCard(
                icon: Icons.person_outline,
                title: "Nama",
                value: "Muhammad Sulthan Al Azzam",
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: Icons.badge_outlined,
                title: "NIM",
                value: "124230127",
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: Icons.school_outlined,
                title: "Kelas",
                value: "PAM-A",
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: Icons.games_outlined,
                title: "Hobi",
                value: "Bermain Game & Ngoding",
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                icon: Icons.ac_unit_sharp,
                title: "Favorit Lagu",
                value: "If I Had A Gun...",
              ),
              const SizedBox(height: 40),
              const Text(
                "KESAN & PESAN",
                style: TextStyle(
                  fontFamily: 'Teko',
                  fontSize: 24,
                  letterSpacing: 2,
                  color: Color(0xFFFF4655),
                ),
              ),
              const SizedBox(height: 16),
              _buildFeedbackList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KesanPesanPage()),
          );
          if (result == true) {
            _loadFeedback(); // Muat ulang data jika ada data baru
          }
        },
        backgroundColor: const Color(0xFFFF4655),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildFeedbackList() {
    if (_feedbackList.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada kesan dan pesan.",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _feedbackList.length,
      itemBuilder: (context, index) {
        final feedback = _feedbackList[index];
        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    icon: Icons.lightbulb_outline,
                    title: "Kesan",
                    value: feedback['kesan'] ?? '-',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.message_outlined,
                    title: "Pesan",
                    value: feedback['pesan'] ?? '-',
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _showDeleteConfirmation(feedback['id']),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B252F),
          title: const Text(
            "Hapus Item",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Apakah Anda yakin ingin menghapus kesan dan pesan ini?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.white70),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                "Hapus",
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () async {
                await DBHelper().deleteFeedback(id);
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item berhasil dihapus.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  _loadFeedback(); // Muat ulang daftar setelah menghapus
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF4655), size: 28),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
