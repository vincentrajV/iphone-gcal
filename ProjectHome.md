### Description ###
One of the iPhone's biggest limitations is that 3rd party apps don't have access to the iPhone's calendar contents.  By using the Google Data APIs and Google Sync, you can now bridge that gap.  This project shows how to use Google's Objective-C client libraries to create, retrieve, update and delete Google Calendar contents, which Google Sync then synchronizes with the iPhone's built-in calendar application, iCal.  This also leverages the fact that the user's Google calendar account may contain any number of separate calendars.  All calendars' contents are fetched and rendered.

### Origin ###
This project was originally created as demo material for a tech talk I gave at Google on May 6th 2009 and at Symantec on May 13th, but it has the potential to serve as the basis of any iPhone application that wishes to access Google calendar contents, and indirectly, the iPhone's calendar contents.

### Intended Use ###
You're welcome to use the provided source in your iPhone projects, but I should warn you that Apple tends to reject apps that duplicate iPhone's functionality.  Therefore I doubt anyone would be able to take it verbatim and submit it as an app.  However, I could see this very useful to apps that wish to contribute calendar events specific to their particular application.  A few examples might be:
  * game applications can schedule online games with friends, by also accessing the iPhone's contacts.
  * social events aggregation services (such as www.zvents.com) could provide search capabilities, and create calendar events for items the user selects.
  * configure multiple calendars to show friends' events intermixed with the user's events.
  * many, many more possibilities...

**Contact Me:** [Dan.Bourque@gmail.com](mailto://Dan.Bourque@gmail.com?subject=iphone-gcal%20project)

![http://lh5.ggpht.com/_NEp5_4j68SQ/Sf8k0xUekBI/AAAAAAAAI_0/nJVidWn4xng/iPhone_gCal_1.png](http://lh5.ggpht.com/_NEp5_4j68SQ/Sf8k0xUekBI/AAAAAAAAI_0/nJVidWn4xng/iPhone_gCal_1.png)
![http://lh4.ggpht.com/_NEp5_4j68SQ/Sf8k0scCxII/AAAAAAAAI_s/tHRKdxmVvYs/iPhone_gCal_2.png](http://lh4.ggpht.com/_NEp5_4j68SQ/Sf8k0scCxII/AAAAAAAAI_s/tHRKdxmVvYs/iPhone_gCal_2.png)
![http://lh5.ggpht.com/_NEp5_4j68SQ/Sf8k0YJgBDI/AAAAAAAAI_k/ddAgCkpI1H4/iPhone_gCal_3.png](http://lh5.ggpht.com/_NEp5_4j68SQ/Sf8k0YJgBDI/AAAAAAAAI_k/ddAgCkpI1H4/iPhone_gCal_3.png)

<a href='http://www.youtube.com/watch?feature=player_embedded&v=OcoPjwP8P9E' target='_blank'><img src='http://img.youtube.com/vi/OcoPjwP8P9E/0.jpg' width='640' height=500 /></a>