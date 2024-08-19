import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        return MyAppState();
      },
      child: MaterialApp(
        title: 'Namer App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: "TimesNewRoman",
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];
  GlobalKey? historyListKey;
  void getNext() {
    history.insert(0,current);
    var animatedList  = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);

    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
  void removeFavourite(WordPair pair){
    favorites.remove(pair);
    notifyListeners();
  }

}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavouritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    // The container for the current page, with its background color and subtle switching animation

    var mainArea = ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: AnimatedSwitcher(
        duration: Duration(microseconds: 200),
        child: page,
      ),
    );
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          //Using a more mobile-friendly design for narrow screens
          return Column(
            children: [
              Expanded(child: mainArea),
              SafeArea(
                  child: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.favorite), label: 'Favourites')
                ],
                currentIndex: selectedIndex,
                onTap: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ))
            ],
          );
        } else {
          return Row(
            children: [
              SafeArea(
                  child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favourites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              )),
              Expanded(
                  child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ))
            ],
          );
        }
      }),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(flex: 3, child: HistoryListView()),
          SizedBox(
            height: 10,
          ),
          BigCard(pair: pair),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                label: const Text('Like'),
                icon: Icon(icon),
              ),
              const SizedBox(
                width: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: const Text('Next'))
            ],
          ),
          Spacer(flex: 2,),
        ],
      ),
    );
  }
}

class FavouritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return const Center(
        child: Text('No favourites yet'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('you have '
              '${appState.favorites.length} favourites:'),
        ),
        Expanded(child: GridView(gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          childAspectRatio: 400 / 80,
        ),
        children: [
 for (var pair in appState.favorites)
          ListTile(
            leading: IconButton(onPressed: (){
              appState.removeFavourite(pair);
            }, icon: 
            const Icon(Icons.favorite)),
            title: Text(pair.asLowerCase),
          ),
        ],
        )
        ),

       
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      elevation: 10,
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: Duration(milliseconds: 200),
          child: MergeSemantics(
            child: Wrap(
              children:[ 
                Text(
                pair.first,
                style: style.copyWith(
                  fontWeight: FontWeight.w100
                ),
                semanticsLabel: pair.asPascalCase,
              ),
              Text(
                pair.second,
                style: style.copyWith(fontWeight: FontWeight.bold),
              )
              ]
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);
  @override
  State<HistoryListView> createState() {
    return _HistoryListView();
  }
}

class _HistoryListView extends State<HistoryListView> {

  final _key =
      GlobalKey(); // used to fade out the history items at the top, to suggest continuation

  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0,0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  @override
  Widget build(BuildContext context){
    final appState = context.watch<MyAppState>();
    appState.historyListKey = _key;
    return ShaderMask(
      shaderCallback: (bounds){
      return _maskingGradient.createShader(bounds);
    },
    blendMode: BlendMode.dstIn,
    child: AnimatedList(
      key: _key,
      reverse: true,
      padding: EdgeInsets.only(top: 100),
      initialItemCount: appState.history.length,
      itemBuilder: (context,index,animation){
        final pair = appState.history[index];
        return SizeTransition(
          sizeFactor: animation,
          child: Center(
            child: TextButton.icon(icon: appState.favorites.contains(pair) ? Icon(Icons.favorite, size: 12,) : SizedBox(), onPressed: (){
              appState.removeFavourite(pair);
            }, label: Text(
              pair.asLowerCase,
              semanticsLabel: pair.asPascalCase,
            )),
          ),
          );
      },
    ),
    );
  }
}
