import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isProcessing = false;
  String? _paymentStatus;
  Timer? _pollingTimer;
  int _pollingAttempts = 0;
  static const int _maxPollingAttempts = 12; // poll max 1 min (5s * 12)

  Future<void> _processPayment(BuildContext context) async {
    setState(() => _isProcessing = true);

    try {
      final email = FirebaseAuth.instance.currentUser?.email ?? '';

      if (email.isEmpty) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ User email not found. Please login again.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('https://sslc.onrender.com/initiate-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': 100.00, 'email': email}),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final paymentUrl = data['GatewayPageURL'];
        final tranId = data['transactionId'];

        if (paymentUrl != null && tranId != null) {
          await _redirectToPayment(paymentUrl);
          _startPaymentStatusPolling(tranId);
        } else {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Invalid payment URL or transaction ID'),
            ),
          );
        }
      } else {
        setState(() => _isProcessing = false);

        String errorMsg = 'Failed to initiate payment';

        try {
          final errorData = jsonDecode(response.body);
          if (errorData['error'] != null) {
            errorMsg += ': ${errorData['error']}';
          }
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $errorMsg (Status code: ${response.statusCode})'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Error: ${e.toString()}')));
    }
  }

  Future<void> _redirectToPayment(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Could not launch payment URL')),
      );
    }
  }

  void _startPaymentStatusPolling(String tranId) {
    _pollingAttempts = 0;
    _pollingTimer?.cancel();

    setState(() {
      _paymentStatus = null;
      _isProcessing = true;
    });

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      _pollingAttempts++;

      if (_pollingAttempts > _maxPollingAttempts) {
        timer.cancel();
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏱️ Payment timed out. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        final response = await http.get(
          Uri.parse('https://sslc.onrender.com/payment-status/$tranId'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final status = data['status'] as String?;

          if (status == 'VALID' ||
              status == 'FAILED' ||
              status == 'CANCELLED') {
            timer.cancel();
            setState(() {
              _paymentStatus = status;
              _isProcessing = false;
            });

            String message;
            Color color;

            switch (status) {
              case 'VALID':
                message = '✅ Payment successful! Enjoy premium.';
                color = Colors.green;
                break;
              case 'FAILED':
                message = '❌ Payment failed. Please try again.';
                color = Colors.red;
                break;
              case 'CANCELLED':
                message = '⚠️ Payment cancelled.';
                color = Colors.orange;
                break;
              default:
                message = 'Unknown payment status: $status';
                color = Colors.grey;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: color),
            );
          }
          // else keep polling if status is pending or unknown
        } else {
          print('Payment status poll failed: ${response.statusCode}');
        }
      } catch (e) {
        print('Error polling payment status: $e');
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade600),
          const SizedBox(width: 15),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Premium'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Icon(Icons.star, size: 60, color: Colors.amber),
                      const SizedBox(height: 20),
                      Text(
                        'Premium Membership',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Unlock all premium features',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Premium Benefits:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _buildFeatureRow(Icons.assignment, 'Access to all assignments'),
              _buildFeatureRow(Icons.note, 'View all class notes'),
              _buildFeatureRow(Icons.lock_open, 'No restrictions'),
              const Spacer(),
              if (_paymentStatus != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Payment Status: $_paymentStatus',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          _paymentStatus == 'VALID'
                              ? Colors.green
                              : (_paymentStatus == 'FAILED'
                                  ? Colors.red
                                  : Colors.orange),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Only 100 BDT/month',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed:
                            _isProcessing
                                ? null
                                : () => _processPayment(context),
                        child:
                            _isProcessing
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  'Subscribe Now',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
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
