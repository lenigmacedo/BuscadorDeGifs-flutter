import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future<Map> _getSearch() async {
    http.Response response;

    if (_search == null || _search.isEmpty)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=VIDIXLZkf3CAXferkAKwKjVymqGkUxr3&limit=30&rating=G");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=VIDIXLZkf3CAXferkAKwKjVymqGkUxr3&q=$_search&limit=29&offset=$_offset&rating=G&lang=pt");

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _getSearch().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network("https://i.giphy.com/igQ371jTOwsHuFDdQW.gif"),
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 40),
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                onSubmitted: (text) {
                  setState(() {
                    _search = text;
                    _offset = 0;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Pesquisar ...",
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 30,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 30),
            height: 1,
            color: Colors.grey,
          ),
          Expanded(
            child: FutureBuilder(
                future: _getSearch(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 300,
                        height: 300,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 4.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError)
                        return Container();
                      else
                        return Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: _createGifTable(context, snapshot));
                  }
                }),
          )
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data["data"].length)
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]
                    ["fixed_height_downsampled"]["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data["data"][index])));
              },
              onLongPress: () {
                Share.share(snapshot.data["data"][index]["images"]
                    ["fixed_height_downsampled"]["url"]);
              },
            );
          else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 80,
                    ),
                    Text(
                      "Carregar mais gifs...",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset += 29;
                  });
                },
              ),
            );
        });
  }

  Widget saveFavorite(){
    //TODO salvar a uma lista de favoritos
  }

}
