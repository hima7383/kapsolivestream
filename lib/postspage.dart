import 'package:flutter/material.dart';
import 'package:tikvid/contoller/postsrepo.dart';
import 'package:tikvid/externaluserprofile.dart';
import 'package:video_player/video_player.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({Key? key}) : super(key: key);

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen>
    with SingleTickerProviderStateMixin {
  final PostRepository _postRepository = PostRepository();
  late Future<PostsResponse> _postsFuture;
  late Future<ReelsResponse> _reelsFuture;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _hasMore = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _postsFuture = _loadPosts();
    _reelsFuture = _loadReels();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _postRepository.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<PostsResponse> _loadPosts() async {
    try {
      final response = await _postRepository.getPosts(page: _currentPage);
      _hasMore = response.pagination.currentPage < response.pagination.totalPages;
      return response;
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  Future<ReelsResponse> _loadReels() async {
    try {
      final response = await _postRepository.getReels(page: _currentPage);
      _hasMore = response.pagination.currentPage < response.pagination.totalPages;
      return response;
    } catch (e) {
      throw Exception('Failed to load reels: $e');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _hasMore) {
      setState(() {
        _currentPage++;
        if (_tabController.index == 0) {
          _postsFuture = _loadPosts();
        } else {
          _reelsFuture = _loadReels();
        }
      });
    }
  }

  void _refreshContent() {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
      if (_tabController.index == 0) {
        _postsFuture = _loadPosts();
      } else {
        _reelsFuture = _loadReels();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Posts'),
            Tab(text: 'Reels'),
          ],
          onTap: (index) {
            setState(() {
              _currentPage = 1;
              _hasMore = true;
              _refreshContent();
            });
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(),
          _buildReelsTab(),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    return RefreshIndicator(
      onRefresh: () async => _refreshContent(),
      backgroundColor: Colors.black,
      color: Colors.red,
      child: FutureBuilder<PostsResponse>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.red));
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(context, 'Failed to load posts', _refreshContent);
          }

          if (!snapshot.hasData || snapshot.data!.posts.isEmpty) {
            return _buildEmptyWidget(context, 'No posts available');
          }

          return ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: snapshot.data!.posts.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == snapshot.data!.posts.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                );
              }

              final post = snapshot.data!.posts[index];
              return PostCard(post: post);
            },
          );
        },
      ),
    );
  }

  Widget _buildReelsTab() {
    return RefreshIndicator(
      onRefresh: () async => _refreshContent(),
      backgroundColor: Colors.black,
      color: Colors.red,
      child: FutureBuilder<ReelsResponse>(
        future: _reelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.red));
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(context, 'Failed to load reels', _refreshContent);
          }

          if (!snapshot.hasData || snapshot.data!.reels.isEmpty) {
            return _buildEmptyWidget(context, 'No reels available');
          }

          return ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: snapshot.data!.reels.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == snapshot.data!.reels.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                );
              }

              final reel = snapshot.data!.reels[index];
              return ReelCard(reel: reel);
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context, String message) {
    return Center(
      child: Text(
        message,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: Colors.white),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              post.content,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
          if (post.media.isNotEmpty) _buildMediaGallery(),
          _buildPostFooter(context),
        ],
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(userId: post.user.id),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundColor: Colors.red,
        child: Text(
          post.user.username?.substring(0, 1).toUpperCase() ?? 'U',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        post.user.username ?? 'Unknown User',
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: Colors.white),
      ),
      subtitle: Text(
        _formatDate(post.createdAt),
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.grey),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        onPressed: () {},
      ),
    );
  }

  Widget _buildMediaGallery() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: post.media.length == 1
            ? Image.network(
                post.media.first.url,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 300,
                    color: Colors.grey[800],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.red,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: post.media.length > 2 ? 2 : post.media.length,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1,
                ),
                itemCount: post.media.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    post.media[index].url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[800],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildPostFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${post.likes.length}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.comment, color: Colors.grey, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${post.commentsCount}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
              Text(
                '${post.shares} shares',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
          const Divider(color: Colors.grey, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                icon: Icons.favorite_outline,
                label: 'Like',
                onPressed: () {},
              ),
              _buildActionButton(
                icon: Icons.comment_outlined,
                label: 'Comment',
                onPressed: () {},
              ),
              _buildActionButton(
                icon: Icons.share,
                label: 'Share',
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class ReelCard extends StatefulWidget {
  final Reel reel;

  const ReelCard({Key? key, required this.reel}) : super(key: key);

  @override
  State<ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<ReelCard> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.reel.url.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.reel.url.first)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReelHeader(context),
          if (widget.reel.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.reel.caption,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white),
              ),
            ),
          if (widget.reel.url.isNotEmpty) _buildVideoPlayer(),
          _buildReelFooter(context),
        ],
      ),
    );
  }

  Widget _buildReelHeader(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(userId: widget.reel.userId),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundColor: Colors.red,
        child: Text(
          widget.reel.userId.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        widget.reel.userId,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: Colors.white),
      ),
      subtitle: Text(
        _formatDate(widget.reel.createdAt),
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.grey),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        onPressed: () {},
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_controller.value.isInitialized)
                VideoPlayer(_controller)
              else
                Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                ),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
                onPressed: () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                      _isPlaying = false;
                    } else {
                      _controller.play();
                      _isPlaying = true;
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReelFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.red, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.reel.likes.length}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.comment, color: Colors.grey, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.reel.commentsCount}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
              Text(
                '${widget.reel.shares} shares',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
          const Divider(color: Colors.grey, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                icon: Icons.favorite_outline,
                label: 'Like',
                onPressed: () {},
              ),
              _buildActionButton(
                icon: Icons.comment_outlined,
                label: 'Comment',
                onPressed: () {},
              ),
              _buildActionButton(
                icon: Icons.share,
                label: 'Share',
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 40),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}