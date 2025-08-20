class CountriesService {
  static final Map<String, List<String>> _countriesCities = {
    'Argentina': [
      'Buenos Aires', 'Córdoba', 'Rosario', 'Mendoza', 'Tucumán', 'La Plata',
      'Mar del Plata', 'Salta', 'Corrientes', 'Bahía Blanca', 'Resistencia',
      'Neuquén', 'Formosa', 'San Juan', 'San Luis', 'Catamarca', 'La Rioja',
      'Jujuy', 'Río Gallegos', 'Ushuaia', 'Puerto Madryn', 'Villa Mercedes',
      'Paraná', 'Santa Fe', 'Posadas', 'Comodoro Rivadavia'
    ],
    'México': [
      'Ciudad de México', 'Guadalajara', 'Monterrey', 'Puebla', 'Tijuana',
      'León', 'Juárez', 'Torreón', 'Querétaro', 'San Luis Potosí', 'Mérida',
      'Mexicali', 'Aguascalientes', 'Cuernavaca', 'Saltillo', 'Hermosillo',
      'Culiacán', 'Chihuahua', 'Morelia', 'Veracruz', 'Cancún', 'Acapulco',
      'Tampico', 'Xalapa', 'Oaxaca', 'Villahermosa', 'Tuxtla Gutiérrez'
    ],
    'Colombia': [
      'Bogotá', 'Medellín', 'Cali', 'Barranquilla', 'Cartagena', 'Cúcuta',
      'Bucaramanga', 'Pereira', 'Santa Marta', 'Ibagué', 'Pasto', 'Manizales',
      'Neiva', 'Villavicencio', 'Armenia', 'Valledupar', 'Montería', 'Sincelejo',
      'Popayán', 'Tunja', 'Florencia', 'Quibdó', 'Riohacha', 'Arauca',
      'Yopal', 'Mocoa', 'San Andrés', 'Leticia'
    ],
    'Chile': [
      'Santiago', 'Valparaíso', 'Concepción', 'La Serena', 'Antofagasta',
      'Temuco', 'Rancagua', 'Talca', 'Arica', 'Chillán', 'Iquique',
      'Los Ángeles', 'Puerto Montt', 'Calama', 'Copiapó', 'Osorno',
      'Quillota', 'Valdivia', 'Punta Arenas', 'Castro', 'Ovalle'
    ],
    'Perú': [
      'Lima', 'Arequipa', 'Trujillo', 'Chiclayo', 'Piura', 'Iquitos',
      'Cusco', 'Huancayo', 'Chimbote', 'Pucallpa', 'Tacna', 'Ica',
      'Juliaca', 'Sullana', 'Ayacucho', 'Chincha Alta', 'Huánuco',
      'Tarapoto', 'Puno', 'Tumbes', 'Talara', 'Jaén', 'Huaraz'
    ],
    'Ecuador': [
      'Quito', 'Guayaquil', 'Cuenca', 'Santo Domingo', 'Ambato', 'Manta',
      'Portoviejo', 'Machala', 'Loja', 'Riobamba', 'Esmeraldas', 'Ibarra',
      'Milagro', 'Quevedo', 'Latacunga', 'Babahoyo', 'Tulcán', 'Pasaje',
      'Azogues', 'Nueva Loja', 'Macas', 'Puyo'
    ],
    'Bolivia': [
      'La Paz', 'Santa Cruz de la Sierra', 'Cochabamba', 'Sucre', 'Potosí',
      'Tarija', 'Oruro', 'Trinidad', 'Cobija', 'Riberalta', 'Montero',
      'Villamontes', 'Yacuiba', 'Warnes', 'Llallagua', 'Tupiza'
    ],
    'Paraguay': [
      'Asunción', 'Ciudad del Este', 'San Lorenzo', 'Luque', 'Capiatá',
      'Lambaré', 'Fernando de la Mora', 'Limpio', 'Ñemby', 'Encarnación',
      'Pedro Juan Caballero', 'Coronel Oviedo', 'Concepción', 'Villarrica'
    ],
    'Uruguay': [
      'Montevideo', 'Salto', 'Paysandú', 'Las Piedras', 'Rivera', 'Maldonado',
      'Tacuarembó', 'Melo', 'Mercedes', 'Artigas', 'Minas', 'San José de Mayo',
      'Durazno', 'Florida', 'Treinta y Tres', 'Rocha', 'Colonia del Sacramento'
    ],
    'Venezuela': [
      'Caracas', 'Maracaibo', 'Valencia', 'Barquisimeto', 'Maracay',
      'Ciudad Guayana', 'San Cristóbal', 'Maturín', 'Barcelona', 'Puerto La Cruz',
      'Petare', 'Turmero', 'Ciudad Bolívar', 'Merida', 'Santa Teresa del Tuy',
      'Valera', 'Punto Fijo', 'Acarigua', 'Los Teques', 'Guanare'
    ],
    'España': [
      'Madrid', 'Barcelona', 'Valencia', 'Sevilla', 'Zaragoza', 'Málaga',
      'Murcia', 'Palma', 'Las Palmas de Gran Canaria', 'Bilbao', 'Alicante',
      'Córdoba', 'Valladolid', 'Vigo', 'Gijón', 'Hospitalet de Llobregat',
      'A Coruña', 'Vitoria-Gasteiz', 'Granada', 'Elche', 'Oviedo', 'Badalona',
      'Cartagena', 'Terrassa', 'Jerez de la Frontera', 'Sabadell', 'Móstoles',
      'Santa Cruz de Tenerife', 'Pamplona', 'Almería', 'Alcalá de Henares',
      'Fuenlabrada', 'Leganés', 'Santander', 'Castellón de la Plana', 'Burgos'
    ],
    'Estados Unidos': [
      'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia',
      'San Antonio', 'San Diego', 'Dallas', 'San Jose', 'Austin', 'Jacksonville',
      'Fort Worth', 'Columbus', 'Charlotte', 'San Francisco', 'Indianapolis',
      'Seattle', 'Denver', 'Washington DC', 'Boston', 'El Paso', 'Nashville',
      'Detroit', 'Oklahoma City', 'Portland', 'Las Vegas', 'Memphis', 'Louisville',
      'Baltimore', 'Milwaukee', 'Albuquerque', 'Tucson', 'Fresno', 'Sacramento',
      'Mesa', 'Kansas City', 'Atlanta', 'Long Beach', 'Colorado Springs', 'Raleigh',
      'Miami', 'Virginia Beach', 'Omaha', 'Oakland', 'Minneapolis', 'Tulsa'
    ],
    'Brasil': [
      'São Paulo', 'Rio de Janeiro', 'Brasília', 'Salvador', 'Fortaleza',
      'Belo Horizonte', 'Manaus', 'Curitiba', 'Recife', 'Goiânia', 'Belém',
      'Porto Alegre', 'Guarulhos', 'Campinas', 'São Luís', 'São Gonçalo',
      'Maceió', 'Duque de Caxias', 'Natal', 'Teresina', 'Campo Grande',
      'Nova Iguaçu', 'São Bernardo do Campo', 'João Pessoa', 'Santo André',
      'Osasco', 'Jaboatão dos Guararapes', 'Contagem', 'São José dos Campos',
      'Uberlândia', 'Sorocaba', 'Cuiabá', 'Aparecida de Goiânia', 'Aracaju',
      'Feira de Santana', 'Londrina', 'Juiz de Fora', 'Belford Roxo'
    ],
  };

  static List<String> getAllCountries() {
    return _countriesCities.keys.toList()..sort();
  }

  static List<String> getCitiesForCountry(String country) {
    return _countriesCities[country] ?? [];
  }

  static List<String> searchCountries(String query) {
    if (query.isEmpty) return getAllCountries();
    
    return getAllCountries()
        .where((country) => country.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static List<String> searchCities(String country, String query) {
    final cities = getCitiesForCountry(country);
    if (query.isEmpty) return cities;
    
    return cities
        .where((city) => city.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static List<String> searchAllCities(String query) {
    if (query.isEmpty) return [];
    
    final allCities = <String>[];
    for (final cities in _countriesCities.values) {
      allCities.addAll(cities);
    }
    
    return allCities
        .where((city) => city.toLowerCase().contains(query.toLowerCase()))
        .toSet()
        .toList()
      ..sort();
  }

  static String? getCountryForCity(String city) {
    for (final entry in _countriesCities.entries) {
      if (entry.value.contains(city)) {
        return entry.key;
      }
    }
    return null;
  }
}