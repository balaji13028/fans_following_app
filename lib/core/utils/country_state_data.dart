/// Country, State, and District data
/// This is a simplified version. For production, consider using an API or comprehensive data source.

class CountryStateData {
  // Sample countries with states and districts
  static const Map<String, Map<String, List<String>>> countryStateDistrict = {
    'India': {
      'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad'],
      'Karnataka': ['Bangalore', 'Mysore', 'Hubli', 'Mangalore', 'Belgaum'],
      'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Salem', 'Tiruchirappalli'],
      'Delhi': ['New Delhi', 'Central Delhi', 'North Delhi', 'South Delhi'],
      'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Bhavnagar'],
    },
    'United States': {
      'California': ['Los Angeles', 'San Francisco', 'San Diego', 'Sacramento', 'San Jose'],
      'New York': ['New York City', 'Buffalo', 'Rochester', 'Albany', 'Syracuse'],
      'Texas': ['Houston', 'Dallas', 'Austin', 'San Antonio', 'Fort Worth'],
      'Florida': ['Miami', 'Tampa', 'Orlando', 'Jacksonville', 'Tallahassee'],
    },
    'United Kingdom': {
      'England': ['London', 'Manchester', 'Birmingham', 'Liverpool', 'Leeds'],
      'Scotland': ['Edinburgh', 'Glasgow', 'Aberdeen', 'Dundee', 'Inverness'],
      'Wales': ['Cardiff', 'Swansea', 'Newport', 'Wrexham', 'Bangor'],
    },
  };

  static List<String> getCountries() {
    return countryStateDistrict.keys.toList();
  }

  static List<String> getStates(String country) {
    return countryStateDistrict[country]?.keys.toList() ?? [];
  }

  static List<String> getDistricts(String country, String state) {
    return countryStateDistrict[country]?[state] ?? [];
  }
}

