# TATA Retail GST Billing App

A Flutter-based GST billing application for TATA Retail Solutions that automates GST calculations and streamlines the billing process.

## Features

- Google Authentication
- Modern Dashboard with Quick Actions
- New Bill Creation with GST Calculations
- Product Catalog Management
- Transaction History
- Reports and Analytics

## GST Features

- Multiple GST Rate Support (5%, 12%, 18%, 28%)
- Automated CGST and SGST Calculations
- Itemized Bill View with Totals
- Invoice Generation

## Getting Started

### Prerequisites

- Flutter SDK
- Firebase Account
- Google Cloud Project with People API enabled

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/tata-retail-gst-billing.git
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Add your Firebase configuration to `lib/firebase_options.dart`
   - Enable Google Sign-In in Firebase Console
   - Add your web domain to authorized domains

4. Run the app:
```bash
flutter run -d chrome --web-port 5000
```

## Project Structure

```
lib/
├── screens/
│   ├── dashboard/
│   ├── new_bill/
│   ├── products/
│   ├── reports/
│   └── transactions/
├── services/
└── main.dart
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
