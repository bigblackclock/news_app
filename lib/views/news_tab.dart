import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app/data/article.dart';
import 'package:news_app/views/article_web_view.dart';
import 'package:news_app/services/news_api.dart';
import 'package:intl/intl.dart';

final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

class NewsTab extends StatefulWidget {
  final String source;
  NewsTab({Key key, this.source}) : super(key: key);
  @override
  _NewsTabState createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> with AutomaticKeepAliveClientMixin {
  bool isLoading = true;
  int totalResults;
  List<Article> articles;
  bool isError = false;
  String errorMessage = '';

  Future<void> loadArticles() =>
      NewsAPI().getTopHeadlinesFromSource(widget.source).then(
          (response) => setState(() {
                isLoading = false;
                isError = false;
                totalResults = response.totalResults;
                articles = response.articles;
              }),
          onError: (error) => setState(() {
                isLoading = false;
                isError = true;
                errorMessage = '$error';
              }));

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    loadArticles();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: loadArticles,
            child: isError
                ? SingleChildScrollView(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Error loading data.\nPlease check your internet connection!',
                      style: Theme.of(context).textTheme.bodyText1,
                      textAlign: TextAlign.center,
                    ),
                  )
                : OrientationBuilder(
                    builder: (context, orientation) => GridView.count(
                        childAspectRatio: 0.85,
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        crossAxisCount:
                            orientation == Orientation.portrait ? 1 : 2,
                        children: articles
                            .map((article) => _buildArticleCard(article))
                            .toList()),
                  )
            // ListView.builder(
            //     itemCount: totalResults,
            //     itemBuilder: (BuildContext context, int index) =>
            //         _buildArticleCard(articles[index]),
            // ),
            );
  }

  Widget _buildPublishedAtRow(DateTime datetime) => Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'Date : ${_dateFormat.format(datetime)}',
              softWrap: true,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Expanded(
            child: Text(
              'Time : ${datetime.hour}:${datetime.minute} ${datetime.timeZoneName}',
              softWrap: true,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ],
      );
  Widget _buildArticleCard(Article article) => Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        elevation: 5,
        color: Colors.grey[400],
        child: InkWell(
          splashColor: Colors.grey[500],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    ArticleWebView(title: article.title, url: article.url),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: article.description != '' ? 7: 5,
                  child: SizedBox.expand(
                    child: CachedNetworkImage(
                      fit: BoxFit.fitWidth,
                      imageUrl: article.urlToImage,
                      progressIndicatorBuilder:
                          (context, _, downloadProgress) => Center(
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress)),
                      errorWidget: (context, _, __) =>
                          Center(child: Icon(Icons.error)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.only(top: 16, bottom: 8),
                    child: Center(
                      child: Text(
                        '\"${article.title}\"',
                        maxLines: article.description != '' ? 3: 4,
                        softWrap: true,
                        style: Theme.of(context)
                            .textTheme
                            .headline3
                            .copyWith(fontSize: 24, color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                if (article.description != '')
                  Expanded(
                    flex: 2,
                    child: Container(
                      child: Text(
                        article.description,
                        maxLines: 3,
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                Expanded(
                  flex: 1,
                  child: Container(
                      padding: EdgeInsets.only(top: 8),
                      child: _buildPublishedAtRow(article.publishedAt)),
                )
              ],
            ),
          ),
        ),
      );
}