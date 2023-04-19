import 'package:flutter/material.dart';

class RouteDirectory extends StatelessWidget {
  static const routeName = '/routedirectory';
  const RouteDirectory({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.white,

      ),
      home: const HomePage(),
      routes: {
        '/description1': (context) => const DescriptionPage(
              title: '07B | Banawa-Colon',
              description: 'Banawa to Colon jeepney',
            ),
        '/description2': (context) => const DescriptionPage(
              title: '06B | Guadalupe-Colon',
              description: 'Guadalupe to Colon jeepney',
            ),
        '/description3': (context) => const DescriptionPage(
              title: '12L | Labangon-Ayala',
              description: 'Labangon to Ayala jeepney',
            ),
        '/description4': (context) => const DescriptionPage(
              title: '06H | Guadalupe-SM Cebu',
              description: 'Guadalupe to SM Cebu jeepney',
            ),
         '/description5': (context) => const DescriptionPage(
              title: '06H | Guadalupe-SM Cebu',
              description: 'Guadalupe to SM Cebu jeepney',
            ),
         '/description6': (context) => const DescriptionPage(
              title: '06H | Guadalupe-SM Cebu',
              description: 'Guadalupe to SM Cebu jeepney',
            ),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  static var routeName;

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
          },
        ),
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Search Route',
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
              'asset/logo/gajeep_logo1.png',
              height: 200,
              width: 200,
            )
            ),
            const Text(
              'Route Lists',
              style: TextStyle(
              fontSize: 24,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/description1'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: Colors.black,
                    )
                  )
                ),
                child: const Text('07B | Banawa-Colon'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/description2'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: Colors.black,
                    )
                  )
                ),
                child: const Text('06B | Guadalupe-Colon'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/description3'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: Colors.black,
                    )
                  )
                ),
                child: const Text('12L | Labangon-Ayala'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/description4'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: Colors.black,
                    )
                  )
                ),
                child: const Text('06H | Guadalupe-SM'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/description5'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: Colors.black,
                    )
                  )
                ),
                child: const Text('07B | Banawa-Colon'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 300,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/description6'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(
                      color: Colors.black,
                    )
                  )
                ),
                child: const Text('07B | Banawa-Colon'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DescriptionPage extends StatelessWidget {
  final String title;
  final String description;

  const DescriptionPage({Key? key, required this.title, required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(description),
      ),
    );
  }
}