import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Form1Crud extends StatefulWidget {
  const Form1Crud({super.key});

  @override
  State<Form1Crud> createState() => _Form1CrudState();
}

class _Form1CrudState extends State<Form1Crud> {
  final _namaController = TextEditingController();
  final _nrpController = TextEditingController();
  final _prodiController = TextEditingController();
  final _ipkController = TextEditingController();

  String? _idToEdit;

  Future<void> _submitData() async {
    final nama = _namaController.text.trim();
    final nrp = _nrpController.text.trim();
    final prodi = _prodiController.text.trim();
    final ipk = _ipkController.text.trim();

    if (nama.isEmpty || nrp.isEmpty || prodi.isEmpty || ipk.isEmpty) {
      _showMessage('Semua data wajib diisi!');
      return;
    }

    try {
      final double parsedIpk = double.parse(ipk);
      if (parsedIpk < 0 || parsedIpk > 4) {
        _showMessage('IPK harus antara 0.0 hingga 4.0');
        return;
      }

      final data = {
        'nama': nama,
        'nrp': nrp,
        'prodi': prodi,
        'ipk': parsedIpk,
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (_idToEdit == null) {
        await FirebaseFirestore.instance.collection('mahasiswa').add(data);
        _showMessage('Data berhasil ditambahkan');
      } else {
        await FirebaseFirestore.instance
            .collection('mahasiswa')
            .doc(_idToEdit)
            .update(data);
        _showMessage('Data berhasil diperbarui');
        _idToEdit = null;
      }

      _clearForm();
    } catch (e) {
      _showMessage('IPK harus berupa angka desimal');
    }
  }

  void _clearForm() {
    _namaController.clear();
    _nrpController.clear();
    _prodiController.clear();
    _ipkController.clear();
  }

  void _fillForm(DocumentSnapshot doc) {
    setState(() {
      _idToEdit = doc.id;
      _namaController.text = doc['nama'];
      _nrpController.text = doc['nrp'];
      _prodiController.text = doc['prodi'];
      _ipkController.text = doc['ipk'].toString();
    });
  }

  void _hapusData(String id) async {
    await FirebaseFirestore.instance.collection('mahasiswa').doc(id).delete();
    _showMessage('Data berhasil dihapus');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Data Mahasiswa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInputField('Nama Mahasiswa', _namaController),
            _buildInputField('NRP', _nrpController),
            _buildInputField('Program Studi', _prodiController),
            _buildInputField('IPK', _ipkController, keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitData,
              child: Text(_idToEdit == null ? 'Add' : 'Update'),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Text('Daftar Mahasiswa', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('mahasiswa')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Text('Terjadi error');
                  if (!snapshot.hasData) return const CircularProgressIndicator();

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) return const Text('Belum ada data');

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      return Card(
                        child: ListTile(
                          title: Text(doc['nama']),
                          subtitle: Text(
                            'NRP: ${doc['nrp']}\nProdi: ${doc['prodi']}\nIPK: ${doc['ipk'].toString()}',
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _fillForm(doc),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _hapusData(doc.id),
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
      ),
    );
  }
}
