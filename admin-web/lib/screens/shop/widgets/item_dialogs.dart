// lib/screens/shop/widgets/item_dialogs.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/shop_item.dart';

class AddItemDialog extends StatefulWidget {
  final String type;

  const AddItemDialog({Key? key, required this.type}) : super(key: key);

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  PlatformFile? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter un ${_getTypeName(widget.type)}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.type != 'title')
                ElevatedButton(
                  onPressed: _pickFile,
                  child: Text(_selectedFile != null
                      ? 'Fichier sélectionné: ${_selectedFile!.name}'
                      : 'Sélectionner une image'),
                ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Nom requis';
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Prix (coins)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Prix requis';
                  final price = int.tryParse(value!);
                  if (price == null || price < 0) return 'Prix invalide';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Ajouter'),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.type != 'title' && _selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une image')),
        );
        return;
      }

      Navigator.of(context).pop({
        'file': _selectedFile,
        'name': _nameController.text,
        'price': int.parse(_priceController.text),
      });
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'profile_picture':
        return 'photo de profil';
      case 'banner':
        return 'bannière';
      case 'title':
        return 'titre';
      default:
        return type;
    }
  }
}

class EditItemDialog extends StatefulWidget {
  final ShopItem item;

  const EditItemDialog({Key? key, required this.item}) : super(key: key);

  @override
  State<EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<EditItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController =
        TextEditingController(text: widget.item.price.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier l\'item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom'),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Nom requis';
                return null;
              },
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Prix (coins)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Prix requis';
                final price = int.tryParse(value!);
                if (price == null || price < 0) return 'Prix invalide';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop({
                'name': _nameController.text,
                'price': int.parse(_priceController.text),
              });
            }
          },
          child: const Text('Modifier'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
