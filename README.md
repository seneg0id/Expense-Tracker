# jupiter_clone

Jupiter is a personal finance management application that simplifies the process of tracking and categorizing expenses. In this assignment, you will design and develop a similar app that can take an excel file as input and categorize expenses based on their purpose.

## Getting Started

First connect your mobile device to your pc using any cable.

To run the app:
    get all the dependencies using
        - flutter pub get
    run the app using
        - flutter run

After running flutter run command app directly opens in phone and user can sign in or sign up to use the app.

After user is signed in, details of the user are stored locally in the app. When the user logs out, we update the details of user in firebase storage.
When the user signs in again their details are imported from firebase storage based on their uid.

User can add their expenses into the app manually or from an excel file.