import 'package:flutter/material.dart';
import 'package:second_api/Api_service/api_service.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  final ApiService apiService = ApiService();
  final TextEditingController searchController = TextEditingController();

  List movies = [];
  List filteredMovies = [];

  bool isLoading = true;
  String? errorMessage;

  static const Color bgColor = Color(0xFF0B0B10);
  static const Color cardColor = Color(0xFF181820);
  static const Color accentColor = Colors.redAccent;

  @override
  void initState() {
    super.initState();
    getMovies();
    searchController.addListener(_filterMovies);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterMovies() {
    final query = searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredMovies = movies;
      } else {
        filteredMovies = movies.where((movie) {
          return movie.title.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> getMovies() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await apiService.fetchMovies();

      setState(() {
        movies = data;
        filteredMovies = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Couldn't load movies.\nPlease try again.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          "Movies",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!isLoading &&
                errorMessage == null &&
                movies.isNotEmpty)
              _buildSearchBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: TextField(
          controller: searchController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
          cursorColor: accentColor,
          decoration: InputDecoration(
            hintText: "Search for a movie...",
            hintStyle: const TextStyle(
              color: Colors.white38,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Colors.white54,
            ),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
              onPressed: () {
                searchController.clear();
              },
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white54,
              ),
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: accentColor,
          strokeWidth: 3,
        ),
      );
    }

    if (errorMessage != null) {
      return _buildError();
    }

    if (filteredMovies.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: accentColor,
      backgroundColor: cardColor,
      onRefresh: getMovies,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: filteredMovies.length,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 14,
          childAspectRatio: 0.62,
        ),
        itemBuilder: (context, index) {
          return _MovieCard(
            movie: filteredMovies[index],
          );
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 42,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: getMovies,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isSearching = searchController.text.isNotEmpty;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearching
                ? Icons.search_off_rounded
                : Icons.movie_filter_outlined,
            size: 52,
            color: Colors.white24,
          ),
          const SizedBox(height: 14),
          Text(
            isSearching
                ? "No movies found"
                : "No movies available",
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isSearching) ...[
            const SizedBox(height: 6),
            const Text(
              "Try searching for another movie",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final dynamic movie;

  const _MovieCard({
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _MovieDetailsPage(
              movie: movie,
            ),
          ),
        );
      },
      child: Hero(
        tag: "movie_${movie.title}",
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF181820),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  movie.posterUrl,
                  fit: BoxFit.cover,
                  loadingBuilder:
                      (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.redAccent,
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white24,
                        size: 40,
                      ),
                    );
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ),
                Positioned(
                  left: 11,
                  right: 11,
                  bottom: 12,
                  child: Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MovieDetailsPage extends StatelessWidget {
  final dynamic movie;

  const _MovieDetailsPage({
    required this.movie,
  });

  void _showWatchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            32,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF181820),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                movie.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                  ),
                  label: const Text(
                    "Watch Now",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.download_rounded,
                    color: Colors.white70,
                  ),
                  label: const Text(
                    "Download",
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.white24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B10),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: "movie_${movie.title}",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    movie.posterUrl,
                    height: 360,
                    width: 240,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        height: 360,
                        width: 240,
                        color: const Color(0xFF181820),
                        child: const Icon(
                          Icons.movie_outlined,
                          color: Colors.white24,
                          size: 55,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                movie.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Overview",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              movie.overView,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            14,
          ),
          child: SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                _showWatchSheet(context);
              },
              icon: const Icon(
                Icons.play_arrow_rounded,
              ),
              label: const Text(
                "Watch Now",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}