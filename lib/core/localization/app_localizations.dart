class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'language': 'Language',
      'milk_card': 'Milk Card',
      'customers': 'Customers',
      'dashboard': 'Dashboard',
      'settings': 'Settings',
      'select_customer': 'Select Customer',
      'session': 'Session',
      'morning': 'Morning',
      'evening': 'Evening',
      'quantity': 'Quantity',
      'mark_as_given': 'Mark as Given',
      'attendance_success': 'Delivery logged successfully!',
      'select_language': 'Select Language',
      'english': 'English',
      'tamil': 'தமிழ் (Tamil)',
      'continue_btn': 'Continue',
      'today_deliveries': 'Today\'s Deliveries',
      'quick_actions': 'Quick Actions',
      'total_liters': 'Total Liters',
      'pending_amount': 'Pending Amount',
      'search_customers': 'Search customers...',
      'add_customer': 'Add Customer',
      'save': 'Save',
    },
    'ta': {
      'language': 'மொழி',
      'milk_card': 'பால் கணக்கு (Milk Card)',
      'customers': 'வாடிக்கையாளர்கள் (Customers)',
      'dashboard': 'முகப்பு (Dashboard)',
      'settings': 'அமைப்புகள் (Settings)',
      'select_customer': 'வாடிக்கையாளரைத் தேர்ந்தெடுக்கவும்',
      'session': 'வேளை (Session)',
      'morning': 'காலை (Morning)',
      'evening': 'மாலை (Evening)',
      'quantity': 'அளவு (Quantity)',
      'mark_as_given': 'கொடுத்துவிட்டேன் (Mark as Given)',
      'attendance_success': 'வெற்றிகரமாக பதிவு செய்யப்பட்டது!',
      'select_language': 'மொழியைத் தேர்ந்தெடுக்கவும்',
      'english': 'English',
      'tamil': 'தமிழ் (Tamil)',
      'continue_btn': 'தொடரவும்',
      'today_deliveries': 'இன்றைய விநியோகங்கள்',
      'quick_actions': 'விரைவான செயல்கள்',
      'total_liters': 'மொத்த லிட்டர்',
      'pending_amount': 'நிலுவைத் தொகை',
      'search_customers': 'வாடிக்கையாளர்களைத் தேடு...',
      'add_customer': 'புதிய வாடிக்கையாளர்',
      'save': 'சேமி',
    },
  };

  static String tr(String languageCode, String key) {
    if (_localizedValues.containsKey(languageCode)) {
      return _localizedValues[languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
    }
    return _localizedValues['en']?[key] ?? key;
  }
}
