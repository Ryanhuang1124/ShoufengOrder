import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class AccountContent extends StatefulWidget {
  @override
  _AccountContentState createState() => _AccountContentState();
}

class _AccountContentState extends State<AccountContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: Colors.black),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height / 200,
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 100,
                    ),
                    Text(
                      '結算',
                      style: TextStyle(
                          fontFamily: 'Yuanti',
                          fontSize: 24,
                          color: Colors.white),
                    )
                  ],
                ),
              ), // TopRow
              Expanded(
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 50,
                    ),
                    Expanded(
                      child: StaggeredGridView.countBuilder(
                        crossAxisCount: 4,
                        itemCount: 20,
                        itemBuilder: (BuildContext context, int index) =>
                            Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.all(
                              Radius.circular(12),
                            ),
                          ),
                          child: Center(
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Text('$index'),
                            ),
                          ),
                        ),
                        staggeredTileBuilder: (int index) =>
                            StaggeredTile.count(2, index.isEven ? 2 : 1),
                        mainAxisSpacing: 6.0,
                        crossAxisSpacing: 6.0,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 50,
                    ),
                  ],
                ),
              ), //Staggered ListView
              Container(),
            ], //BottomRow
          ),
        ),
      ),
    );
  }
}
