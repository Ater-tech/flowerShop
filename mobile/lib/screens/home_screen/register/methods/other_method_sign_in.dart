import 'package:flutter/material.dart';

Column otherMethodsSignUp() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Text("--OR--", style: TextStyle(color: Colors.white)),
      SizedBox(height: 10),
      Text("Sign in with", style: TextStyle(color: Colors.white)),
      SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(6),
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 10,
                  ),
                ],

                // image: DecorationImage(
                //   image: AssetImage("assets/brands/facebook.png"),
                //   // fit: BoxFit.cover,
                // ),
              ),
              child: ClipRRect(
                child: Image.asset("assets/brands/facebook.png"),
              ),
            ),
          ),
          InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.all(6),
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
                // image: DecorationImage(
                //   image: AssetImage("assets/brands/google.png"),
                //   fit: BoxFit.cover,
                // ),
              ),
              child: ClipRRect(child: Image.asset("assets/brands/google.png")),
            ),
          ),
        ],
      ),
    ],
  );
}
