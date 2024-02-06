// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:movie_application/bloc/get_movie_videos_bloc.dart';
import 'package:movie_application/model/movie.dart';
import 'package:movie_application/model/video_response.dart';
import 'package:movie_application/screens/video_player.dart';
import 'package:movie_application/style/theme.dart' as Style;
import 'package:movie_application/widgets/casts.dart';
import 'package:movie_application/widgets/movie_info.dart';
import 'package:movie_application/widgets/similar_movies.dart';

import '../model/video.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    Key? key,
    required this.movie,
  }) : super(key: key);

  final Movie movie;

  @override
  State<DetailScreen> createState() => _DetailScreenState(movie);
}

class _DetailScreenState extends State<DetailScreen> {
  final Movie movie;
  _DetailScreenState(this.movie);

  void initState() {
    super.initState();
    movieVideosBloc.getMovieVideos(movie.id);
  }

  @override
  void dispose() {
    super.dispose();
    movieVideosBloc.drainStream();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VideoResponse>(
      stream: movieVideosBloc.subject.stream,
      builder: (context, AsyncSnapshot<VideoResponse> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.error.isEmpty && snapshot.data!.error.length > 0) {
            return _buildErrorWidget(snapshot.data!.error);
          }
          return _buildVideoWidget(snapshot.data!);
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        } else {
          return _buildLoadingWidget();
        }
      },
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [],
    ));
  }

  Widget _buildErrorWidget(String error) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Error occured: $error"),
      ],
    ));
  }

  Widget _buildVideoWidget(VideoResponse data) {
    List<Video> videos = data.videos;
    return Material(
      type: MaterialType.transparency,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Style.Colors.mainColor,
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  movie.title.length > 40
                      ? "${movie.title.substring(0, 37)}..."
                      : movie.title,
                  style: const TextStyle(
                      fontSize: 12.0, fontWeight: FontWeight.normal),
                ),
                background: Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                                "https://image.tmdb.org/t/p/original/${movie.backPoster}")),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              stops: const [
                                0.1,
                                0.5
                              ],
                              colors: [
                                Colors.black.withOpacity(0.9),
                                Colors.black.withOpacity(0.0)
                              ]),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,bottom: 0,right: 0,left: 0,
                        child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerScreen(
                              controller: YoutubePlayerController(
                                initialVideoId: videos[0].key,
                                flags: const YoutubePlayerFlags(
                                  autoPlay: true,
                                  mute: true,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(FontAwesomeIcons.playCircle,color: Style.Colors.secondColor,size: 40,),
                    ))
                  ],
                )),
          ),
          SliverPadding(
              padding: const EdgeInsets.all(0.0),
              sliver: SliverList(
                  delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        movie.rating.toString(),
                        style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      RatingBar(
                        itemSize: 10.0,
                        initialRating: movie.rating / 2,
                        ratingWidget: RatingWidget(
                          empty: const Icon(
                            EvaIcons.star,
                            color: Style.Colors.secondColor,
                          ),
                          full: const Icon(
                            EvaIcons.star,
                            color: Style.Colors.secondColor,
                          ),
                          half: const Icon(
                            EvaIcons.star,
                            color: Style.Colors.secondColor,
                          ),
                        ),
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      )
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10.0, top: 20.0),
                  child: Text(
                    "OVERVIEW",
                    style: TextStyle(
                        color: Style.Colors.titleColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.0),
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    movie.overview,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12.0, height: 1.5),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                MovieInfo(
                  id: movie.id,
                ),
                Casts(
                  id: movie.id,
                ),
                SimilarMovies(id: movie.id)
              ])))
        ],
      ),
    );
  }
}
