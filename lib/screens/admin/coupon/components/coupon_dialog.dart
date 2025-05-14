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
  FocusNode valueFocusNode = FocusNode();
  late bool disable;
  CouponType _selectedType = CouponType.percent;

  @override
  void initState() {
    super.initState();
    isEditing = widget.isEditing;
    coupon = widget.coupon;
    _selectedType =
        widget.isEditing
            ? widget.coupon?.type ?? CouponType.percent
            : CouponType.percent;

    codeController.text = widget.isEditing ? widget.coupon?.code ?? '' : '';
    maxUsesController.text =
        widget.isEditing ? widget.coupon?.maxUses.toString() ?? '' : '';
    valueController.text =
        widget.isEditing
            ? (widget.coupon?.type == CouponType.fixed
                ? FormatHelper.formatCurrency(widget.coupon!.value.toInt())
                : (widget.coupon!.value * 100).toStringAsFixed(1))
            : '';
    disable = widget.isEditing ? widget.coupon?.disable ?? false : false;
  }

  void updateCoupon() {
    final couponProvider = context.read<CouponProvider>();
    final rawValue = valueController.text.replaceAll(RegExp(r'[^\d.]'), '');

    double finalValue = double.tryParse(rawValue) ?? 0.0;

    if (_selectedType == CouponType.percent) {
      finalValue = finalValue / 100; // Để giá trị phần trăm theo thập phân
    }

    couponProvider.updateCoupon(widget.coupon!.id, {
      'code': codeController.text,
      'maxUses': int.tryParse(maxUsesController.text) ?? coupon?.maxUses,
      'value': finalValue, // Lưu giá trị phần trăm đã nhập
      'disable': disable,
      'type': _selectedType == CouponType.fixed ? 'fixed' : 'percent',
    });
  }

  void createCoupon() {
    final couponProvider = context.read<CouponProvider>();
    final rawValue = valueController.text.replaceAll(RegExp(r'[^\d.]'), '');

    double finalValue = double.tryParse(rawValue) ?? 0.0;

    if (_selectedType == CouponType.percent) {
      finalValue = finalValue / 100; // Để giá trị phần trăm theo thập phân
    }

    final newCoupon = Coupon(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      code: codeController.text,
      maxUses: int.tryParse(maxUsesController.text) ?? 0,
      value: finalValue, // Lưu giá trị phần trăm đã nhập
      disable: disable,
      createdAt: Timestamp.fromDate(DateTime.now()),
      timesUsed: 0,
      ordersApplied: [],
      type: _selectedType,
    );
    couponProvider.addCoupon(newCoupon);
  }

  @override
  void dispose() {
    valueFocusNode.dispose();
    codeController.dispose();
    maxUsesController.dispose();
    valueController.dispose();
    super.dispose();
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
                  } if (int.parse(value) <= 0) {
                    return 'Max Uses must be greater than 0';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: valueController,
                focusNode: valueFocusNode,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Value',
                  suffixText: _selectedType == CouponType.percent ? '%' : '₫',
                ),
                onTap: () {
                  valueController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: valueController.text.length,
                  );
                },
                onEditingComplete: () {
                  if (_selectedType == CouponType.percent) {
                    final raw = valueController.text.replaceAll(
                      RegExp(r'[^\d.]'),
                      '',
                    );
                    if (raw.isNotEmpty &&
                        double.tryParse(raw) != null &&
                        !raw.contains('.0')) {
                      valueController.text =
                          raw; // Ensure it's a valid decimal (not an integer)
                    } else {
                      // Optionally, show an error message or clear the field if invalid
                    }
                  }
                  FocusScope.of(context).unfocus();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Value is required';
                  }

                  if (_selectedType == CouponType.percent) {
                    final rawValue = value.replaceAll(RegExp(r'[^\d.]'), '');
                    if (double.tryParse(rawValue) == null ||
                        rawValue == '0' ||
                        rawValue.contains('.0')) {
                      return 'Please enter a valid decimal number for percentage (not integer)';
                    }
                  }

                  if (_selectedType == CouponType.fixed) {
                    final rawValue = value.replaceAll(RegExp(r'[^\d]'), '');
                    if (int.tryParse(rawValue) == null) {
                      return 'Please enter a valid number';
                    }
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
                    child: Text('Fixed Amount (₫)'),
                  ),
                  DropdownMenuItem(
                    value: CouponType.percent,
                    child: Text('Percentage (%)'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                    valueController.text = '';
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
