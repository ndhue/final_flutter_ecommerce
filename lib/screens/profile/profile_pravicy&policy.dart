import 'package:final_ecommerce/utils/constants.dart';
import 'package:flutter/material.dart';

class PravicyAndPolicy extends StatefulWidget {
  const PravicyAndPolicy({super.key});

  @override
  _PravicyAndPolicyState createState() => _PravicyAndPolicyState();
}

class _PravicyAndPolicyState extends State<PravicyAndPolicy> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Privacy and Policy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'images/pravicy_policy.jpg', // Sửa tên file ảnh
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              _buildText(
                'Chính sách bảo hành & Đổi trả',
                subtitle:
                    'Đổi trả trong vòng 7 ngày nếu sản phẩm lỗi, hỏng, không đúng mô tả.\n'
                    'Không áp dụng cho các sản phẩm không có chính sách đổi trả (ví dụ: thực phẩm, mỹ phẩm đã mở nắp).',
                icon: Icons.assignment_return,
              ),
              _buildText(
                'Chính sách bảo mật và quyền riêng tư',
                subtitle: 'Chúng tôi cam kết bảo vệ dữ liệu cá nhân của bạn. Chúng tôi đảm bảo sẽ không cung cấp thông tin cá nhân của bạn cho bất kỳ bên thứ 3 nào. \n'
                          'Người mua hàng  vá bán hàng phải tuân thủ một số quy định về bảo mật của bên chúng tôi để hạn chế ít nhất các trường hợp lừa đảo \n'
                          'Người dùng hệ thống nên sử dụng chính sách bảo mật 2 lớp để tối ưu chế độ bảo mật',
                icon: Icons.privacy_tip,
              ),
              _buildText(
                'Điều khoản và dịch vụ',
                subtitle: 'Qúy khách vui lòng đọc kỹ điều khoản trước khi sử dụng dịch vụ. \n'
                          'Các trường hợp gặp lỗi về hệ thống chúng tôi sẽ cố gắng nhanh chóng tiến hành sửa chửa.\n'
                          'Nếu có thắc mắc gì thêm về hệ thống, khách hàng có thể liên hệ trực tiếp với chúng tôi thông qua Helps And Support',
                icon: Icons.description,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildText(String label, {String? subtitle, IconData? icon}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10), // Thêm padding cho đẹp
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        if (subtitle != null && subtitle.isNotEmpty) const SizedBox(height: 8),
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            trailing: icon != null ? Icon(icon, color: Colors.blue) : null,
            subtitle: Text(subtitle ?? '', style: TextStyle(fontSize: 16),),
          ),
        ),
      ],
    ),
  );
}
