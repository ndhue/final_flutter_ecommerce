import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_ecommerce/models/models_export.dart';
import 'package:final_ecommerce/providers/coupon_provider.dart';
import 'package:final_ecommerce/utils/constants.dart';
import 'package:final_ecommerce/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CouponDialog extends StatefulWidget {
  final bool isEditing;
  final Coupon? coupon;

  const CouponDialog({super.key, required this.isEditing, this.coupon});

  @override
  State<CouponDialog> createState() => _CouponDialogState();
}

class _CouponDialogState extends State<CouponDialog> {
  late bool isEditing;
  late Coupon? coupon;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController codeController = TextEditingController();
  TextEditingController maxUsesController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  late bool disable;
  CouponType _selectedType = CouponType.percent;

  @override
  void initState() {
    super.initState();
    _selectedType =
        widget.isEditing
            ? widget.coupon?.type ?? CouponType.percent
            : CouponType.percent;
    isEditing = widget.isEditing;
    coupon = widget.coupon;

    codeController.text = widget.isEditing ? widget.coupon?.code ?? '' : '';
    maxUsesController.text =
        widget.isEditing ? widget.coupon?.maxUses.toString() ?? '' : '';
    valueController.text =
        widget.isEditing ? widget.coupon?.value.toString() ?? '' : '';
    disable = widget.isEditing ? widget.coupon?.disable ?? false : false;
  }

  void updateCoupon() {
    final couponProvider = context.read<CouponProvider>();
    couponProvider.updateCoupon(widget.coupon!.id, {
      'code': codeController.text,
      'maxUses': int.tryParse(maxUsesController.text) ?? coupon?.maxUses,
      'value':
          double.tryParse(
            valueController.text.replaceAll(RegExp(r'[.,\\s₫]'), ''),
          ) ??
          coupon?.value,

      'disable': disable,
      'type': _selectedType == CouponType.fixed ? 'fixed' : 'percent',
    });
  }

  void createCoupon() {
    final couponProvider = context.read<CouponProvider>();

    final newCoupon = Coupon(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      code: codeController.text,
      maxUses: int.tryParse(maxUsesController.text) ?? 0,
      value: double.tryParse(valueController.text) ?? 0.0,
      disable: disable,
      createdAt: Timestamp.fromDate(DateTime.now()),
      timesUsed: 0,
      ordersApplied: [],
      type: _selectedType,
    );
    couponProvider.addCoupon(newCoupon);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isEditing ? 'Edit Coupon' : 'Add Coupon',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Code is required';
                  } else if (value.length != 6) {
                    return 'Code must be exactly 6 characters';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: maxUsesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Max Uses'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Max Uses is required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Value'),
                onChanged: (value) {
                  // Remove any formatting to get the raw number
                  final rawValue = value.replaceAll(RegExp(r'[^\d]'), '');
                  if (rawValue.isNotEmpty) {
                    final formattedValue = FormatHelper.formatCurrency(
                      int.parse(rawValue),
                    ); // Your format helper
                    valueController.value = TextEditingValue(
                      text: formattedValue,
                      selection: TextSelection.collapsed(
                        offset: formattedValue.length,
                      ),
                    );
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Value is required';
                  }
                  // Remove formatting to validate the raw number
                  final rawValue = value.replaceAll(RegExp(r'[^\d]'), '');
                  if (double.tryParse(rawValue) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<CouponType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(
                    value: CouponType.fixed,
                    child: Text('Percentage (%)'),
                  ),
                  DropdownMenuItem(
                    value: CouponType.percent,
                    child: Text('Percentage (%)'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Disable'),
                value: disable,
                onChanged: (value) {
                  setState(() {
                    disable = value;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: defaultPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.isEditing ? updateCoupon() : createCoupon();
                          Navigator.pop(context);
                        }
                      },
                      child: Text(widget.isEditing ? 'Save' : 'Add'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
