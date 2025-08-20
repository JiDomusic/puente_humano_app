import 'package:flutter/material.dart';
import '../core/services/countries_service.dart';

class CountryCitySelector extends StatefulWidget {
  final String? initialCountry;
  final String? initialCity;
  final Function(String country, String city) onSelectionChanged;
  final bool isRequired;

  const CountryCitySelector({
    super.key,
    this.initialCountry,
    this.initialCity,
    required this.onSelectionChanged,
    this.isRequired = true,
  });

  @override
  State<CountryCitySelector> createState() => _CountryCitySelectorState();
}

class _CountryCitySelectorState extends State<CountryCitySelector> {
  String? selectedCountry;
  String? selectedCity;
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCountry = widget.initialCountry;
    selectedCity = widget.initialCity;
    _countryController.text = selectedCountry ?? '';
    _cityController.text = selectedCity ?? '';
  }

  @override
  void dispose() {
    _countryController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Column(
      children: [
        // Selector de País
        _buildCountryField(isMobile),
        SizedBox(height: isMobile ? 12 : 16),
        
        // Selector de Ciudad
        _buildCityField(isMobile),
      ],
    );
  }

  Widget _buildCountryField(bool isMobile) {
    return TextFormField(
      controller: _countryController,
      decoration: InputDecoration(
        labelText: 'País ${widget.isRequired ? '*' : ''}',
        hintText: 'Buscar país...',
        prefixIcon: const Icon(Icons.public),
        suffixIcon: selectedCountry != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _clearCountry(),
              )
            : const Icon(Icons.arrow_drop_down),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      readOnly: true,
      onTap: () => _showCountryPicker(),
      validator: widget.isRequired
          ? (value) => value?.isEmpty ?? true ? 'Por favor selecciona un país' : null
          : null,
    );
  }

  Widget _buildCityField(bool isMobile) {
    return TextFormField(
      controller: _cityController,
      decoration: InputDecoration(
        labelText: 'Ciudad ${widget.isRequired ? '*' : ''}',
        hintText: selectedCountry != null 
            ? 'Buscar ciudad en $selectedCountry...' 
            : 'Primero selecciona un país',
        prefixIcon: const Icon(Icons.location_city),
        suffixIcon: selectedCity != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _clearCity(),
              )
            : const Icon(Icons.arrow_drop_down),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: selectedCountry != null ? Colors.grey[50] : Colors.grey[100],
      ),
      readOnly: true,
      enabled: selectedCountry != null,
      onTap: selectedCountry != null ? () => _showCityPicker() : null,
      validator: widget.isRequired
          ? (value) => value?.isEmpty ?? true ? 'Por favor selecciona una ciudad' : null
          : null,
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CountrySearchModal(
        onCountrySelected: (country) {
          setState(() {
            selectedCountry = country;
            selectedCity = null; // Reset city when country changes
            _countryController.text = country;
            _cityController.text = '';
          });
          Navigator.pop(context);
          _updateSelection();
        },
      ),
    );
  }

  void _showCityPicker() {
    if (selectedCountry == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CitySearchModal(
        country: selectedCountry!,
        onCitySelected: (city) {
          setState(() {
            selectedCity = city;
            _cityController.text = city;
          });
          Navigator.pop(context);
          _updateSelection();
        },
      ),
    );
  }

  void _clearCountry() {
    setState(() {
      selectedCountry = null;
      selectedCity = null;
      _countryController.clear();
      _cityController.clear();
    });
    _updateSelection();
  }

  void _clearCity() {
    setState(() {
      selectedCity = null;
      _cityController.clear();
    });
    _updateSelection();
  }

  void _updateSelection() {
    if (selectedCountry != null && selectedCity != null) {
      widget.onSelectionChanged(selectedCountry!, selectedCity!);
    }
  }
}

class _CountrySearchModal extends StatefulWidget {
  final Function(String) onCountrySelected;

  const _CountrySearchModal({required this.onCountrySelected});

  @override
  State<_CountrySearchModal> createState() => _CountrySearchModalState();
}

class _CountrySearchModalState extends State<_CountrySearchModal> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _filteredCountries = CountriesService.getAllCountries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      _filteredCountries = CountriesService.searchCountries(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
            child: Row(
              children: [
                const Icon(Icons.public, color: Colors.blue),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Seleccionar País',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Search field
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar país...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFFF5F5F5),
              ),
              onChanged: _filterCountries,
            ),
          ),
          
          // Countries list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                return ListTile(
                  leading: const Icon(Icons.flag, color: Colors.green),
                  title: Text(country),
                  subtitle: Text('${CountriesService.getCitiesForCountry(country).length} ciudades'),
                  onTap: () => widget.onCountrySelected(country),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CitySearchModal extends StatefulWidget {
  final String country;
  final Function(String) onCitySelected;

  const _CitySearchModal({
    required this.country,
    required this.onCitySelected,
  });

  @override
  State<_CitySearchModal> createState() => _CitySearchModalState();
}

class _CitySearchModalState extends State<_CitySearchModal> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _filteredCities = CountriesService.getCitiesForCountry(widget.country);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities(String query) {
    setState(() {
      _filteredCities = CountriesService.searchCities(widget.country, query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
            child: Row(
              children: [
                const Icon(Icons.location_city, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Seleccionar Ciudad',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'en ${widget.country}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Search field
          Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar ciudad en ${widget.country}...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
              ),
              onChanged: _filterCities,
            ),
          ),
          
          // Cities list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
              itemCount: _filteredCities.length,
              itemBuilder: (context, index) {
                final city = _filteredCities[index];
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: Text(city),
                  subtitle: Text(widget.country),
                  onTap: () => widget.onCitySelected(city),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}