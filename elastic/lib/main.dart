import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/search_provider.dart';
import 'widgets/search_bar.dart';
import 'widgets/filter_modal.dart';
import 'screens/search_screen.dart';
import 'widgets/festival_card.dart';
import 'services/elastic_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async{
  await dotenv.load(fileName: "assets/.env", ); 
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchProvider(),
      child: MaterialApp(
        title: 'Elasticsearch Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isTestingConnection = true;
  bool _connectionSuccess = false;
  String _connectionMessage = "Testing Elasticsearch connection...";

  @override
  void initState() {
    super.initState();
    _testElasticConnection();
  }

  Future<void> _testElasticConnection() async {
    final elasticService = ElasticService();
    
    try {
      final isConnected = await elasticService.testConnection();
      
      setState(() {
        _isTestingConnection = false;
        _connectionSuccess = isConnected;
        _connectionMessage = isConnected 
          ? "Connection successful! Showing data from Elasticsearch."
          : "Connection failed. Using local data instead.";
      });
      
    } catch (e) {
      setState(() {
        _isTestingConnection = false;
        _connectionSuccess = false;
        _connectionMessage = "Error connecting to Elasticsearch: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elasticsearch Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isTestingConnection 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(_connectionMessage),
              ],
            ),
          )
        : Consumer<SearchProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _connectionMessage,
                      style: TextStyle(
                        color: _connectionSuccess ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                    child: CustomSearchBar(
                      onFilterTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => const FilterModal(),
                        );
                      },
                      onSearchTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: provider.allFestivals.isEmpty
                        ? const Center(
                            child: Text('No festivals available'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.allFestivals.length,
                            itemBuilder: (context, index) {
                              final festival = provider.allFestivals[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: FestivalCard(
                                  festival: festival,
                                  searchQuery: '',
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
    );
  }
}
