# BackTap

"Back Tap" is a feature in iOS 14+ and iPhone 8+.  It can be use to trigger events on the iPhone, but is not available in code for app development.

I created this app to demonstrate how you can detect taps on the back of an iPhone in code using the z-accelerometer.  In the examples below, I am using a normal tap strength.

Here is a plot of z-acceleration (z-accel) versus time.  I tapped the back of the phone twice with the screen facing up, and twice with the screen facing down.  As you can see, the nominal z-accel is -1 for the screen facing up, and +1 for the screen facing down.

<img width="500" height="231" alt="Accel plot bigger" src="https://github.com/user-attachments/assets/e234f5d9-96d1-4add-8639-98ba351e40b5" />

In order to get the nominal z-accel to be zero for all orientations, I passed the samples through a washout filter (aka high-pass filter).  The washout filter approximates the rate of change of z-accel.  If the acceleration isn't changing, the output is zero.

Here is a plot of z-accel and filtered z-accel, while tapping the back twice facing up and twice facing down.  The filter amplifies the slightest motion, but keeps the z-accel centered near zero.

<img width="500" height="231" alt="Filtered accel plot bigger" src="https://github.com/user-attachments/assets/cbc4f065-bd82-4258-b134-9fe848fd444e" />

## Tap Detection

Taps are detected by looking for filtered points above a threshold, with neighboring points that are at least some separation below the peak point.  I used 2.0 for the peak threshold and 1.5 for the separation requirement.

Here's a plot of the same taps with the threshold detection turned on.  I colored the filtered points green, if a tap is detected.  For the most part, the taps are correctly detected, but the plot shows a false positive near the end of the plot.

<img width="500" height="231" alt="Tap detection plot" src="https://github.com/user-attachments/assets/e2126bfd-1090-4308-9099-ccab11977648" />

Here's a plot where I continuously tapped the back of the phone, without flipping the phone over.  It shows reliable detections.

<img width="500" height="231" alt="Continuous taps" src="https://github.com/user-attachments/assets/452caac7-aa93-4542-87f7-a2d26beeb442" />

Here's a plot where I shook the phone to cause accels near the detection threshold.  No taps were made.  No taps were detected (good).

<img width="500" height="231" alt="Shaking phone" src="https://github.com/user-attachments/assets/617b661a-3abb-4601-9713-3098607d420b" />
