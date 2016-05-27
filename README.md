# YelpCodepath

Yelp is a copy of the real yelp app!

Submitted by: Yat Choi

Time spent: ~20 hours spent in total

## User Stories

The following **required** functionality is complete:

* [x] Table rows should be dynamic height according to the content height.
* [x] Custom cells should have the proper Auto Layout constraints.
* [x] Search bar should be in the navigation bar (doesn't have to expand to show location like the real Yelp app does).
* [x] Filter page. Unfortunately, not all the filters in the real Yelp App, are supported in the Yelp API.
* [x] The filters table should be organized into sections as in the mock.
* [x] Clicking on the "Search" button should dismiss the filters page and trigger the search w/ the new filter settings.
* [x] Distance filter should expand as in the real Yelp app.
* [x] Categories should show a subset of the full list with a "See All" row to expand.

The following **optional** features are implemented:
* [x] Infinite scroll for restaurant results
* [x] Implement map view of restaurant results
* [x] implement a custom switch
* [x] Implement the restaurant detail page.

The following **additional** features are implemented:

* [x] Restaurant Detail page pops open Eat24 / SeatMe if available
* [x] Restaurant Detail page has a map view that automatically zooms into the proper scale between the restaurant and user's current location
* [x] If user location is not available, just zooms to the restaurant pin
* [x] Restaurant Detail page shows a user review

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='http://imgur.com/OzfLPI7.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

The biggest challenge I had was just getting AutoLayout to play nicely. I got the chance to do some
programmatic AutoLayout as well with regards to the custom switch elements.

Another challenging aspect were all the map views. It was interesting implementing the move to location
and zoom functions depending on whether or not the user location was available. I also learned more about
the View lifecycle process because the location manager doesn't have a location for the user until after
viewDidLoad, so I had to implement an observer to watch for that value being set. I also made sure that
only happened once so that when the user moves the map, it doesn't constantly recenter.

Overall this was a really fun assignment, and I learned a lot. I think I got a good grasp of the
more logistical stuff and the delegate pattern. Most of my time was spent on the styling aspects.

## License

    Copyright 2016 Yat Choi

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
