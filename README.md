# FiguraMusicListener
Script that connects to LastFM API to put what you're listening to below your nameplate. Utilizes [4p5's Promises](https://discord.com/channels/1129805506354085959/1188720241824505886/1188720241824505886) to make the web request. 

## Setup Instructions
Your avatar's bbmodel needs to have three groups: World, inside of which is Camera, inside of which is text. These should not be inside any other parent-typed folders and all groups should have pivots at (0, 0, 0).

To generate your LastFM Api key, go to [Their website](https://www.last.fm/api/account/create). Once you have your API key and have connected it to whatever music software you use, put it in the ConfigAPI: `/figura run config:setName("API_Key") config:save("1", "YOUR_API_KEY_HERE")`. 

## Screenshots
![image](https://github.com/user-attachments/assets/0da07445-853c-461b-9256-0596018b3bb7)
![image](https://github.com/user-attachments/assets/9a08cb84-66ab-4bd8-8741-ae48c11f9339)
![image](https://github.com/user-attachments/assets/e499fe55-b3bf-454a-9c25-fff3f1777c99)
