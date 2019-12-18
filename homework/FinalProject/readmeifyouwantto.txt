  
As shown in the presentation, all filters work well. 

If you're wondering how the distance variable was calculated, we used the "Street2Coords" API from the DataScienceToolKit to convert
the user inputted address to coordinates. This API returned a JSON file with the lat/long coords. We then used a function called "distm"
from the "geosphere" library to calcualte the distance between the user location and every row in the dataset. 
