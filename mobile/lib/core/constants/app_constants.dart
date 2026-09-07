class AppConstants {
  static const String appName     = 'PropVault';
  static const String apiBase     = 'https://api.propvault.in/api/v1';
  static const String razorpayKey = 'rzp_live_YOUR_KEY_HERE';

  static const List<String> propertyTypes = [
    'Apartment', 'Villa', 'Plot', 'Commercial', 'Independent House', 'Penthouse'
  ];
  static const List<String> amenities = [
    'Swimming Pool', 'Gym', 'Parking', 'Lift', 'Power Backup', 'Security',
    'Garden', 'Club House', 'Play Area', 'Intercom', 'Air Conditioning',
    'Internet', 'Gas Pipeline', 'Rainwater Harvesting',
  ];
  static const List<String> furnishing = ['Unfurnished', 'Semi-Furnished', 'Fully Furnished'];
}
